//! Arch Linux binary to return input aur packages along with their
//! mistrusted maintainers. Local trusted users are stored in
//! /etc/aurto/trusted-users.
//!
//! Will output a line per package in PACKAGE_NAME:USERNAME format
//! for each mistrusted package.
//!
//! If package is not found in the AUR will output PACKAGE_NAME::not-in-aur
use std::{
    alloc::System, borrow::Cow, collections::HashSet, env, error::Error, ffi::OsStr, fs,
    path::Path, str,
};

#[global_allocator]
static GLOBAL: System = System;

type Res<T> = Result<T, Box<dyn Error>>;

const AURWEB_INFO: &str = "https://aur.archlinux.org/rpc/?v=5&type=info";
const LOCAL_TRUST_PATH: &str = "/etc/aurto/trusted-users";

fn main() -> Res<()> {
    let mut packages = vec![];
    {
        let mut unique_args = HashSet::new();
        for arg in env::args().skip(1) {
            let pkg = translate_full_package(arg)?;
            if unique_args.insert(pkg.clone()) {
                packages.push(pkg);
            }
        }
    }

    if packages.is_empty() || packages.iter().any(|p| p.starts_with('-')) {
        return print_help();
    }

    let trust_everyone = !Path::new(LOCAL_TRUST_PATH).is_file();
    let trusted = if trust_everyone { HashSet::new() } else { local_trusted_users()? };

    let (pkg_maintainers, not_in_aur) = package_maintainers(&packages)?;

    if !trust_everyone {
        for pkg in pkg_maintainers
            .into_iter()
            .filter(|pkg| !trusted.contains(&pkg.maintainer.to_lowercase()))
        {
            println!("{}:{}", pkg.name, pkg.maintainer);
        }
    }

    for pkg in not_in_aur {
        println!("{}::not-in-aur", pkg);
    }

    Ok(())
}

/// normalises package names & full package archive names -> package names
fn translate_full_package(arg: String) -> Result<String, String> {
    if arg.contains(".pkg.") {
        let archive_name = Path::new(&arg)
            .file_name()
            .and_then(OsStr::to_str)
            .ok_or_else(|| format!("Can't handle arg `{}`", arg))?;
        let mut name_bits: Vec<_> = archive_name.split('-').rev().skip(3).collect();
        name_bits.reverse();
        Ok(name_bits.join("-"))
    } else {
        Ok(arg)
    }
}

fn local_trusted_users() -> Res<HashSet<String>> {
    Ok(fs::read_to_string(LOCAL_TRUST_PATH)?
        .split('\n')
        .map(|user| user.trim().to_lowercase())
        .filter(|user| !user.is_empty())
        .collect())
}

#[derive(Debug)]
struct MaintainedPackage {
    name: String,
    maintainer: String,
}

fn package_maintainers<T: AsRef<str>>(
    packages: &[T],
) -> Res<(Vec<MaintainedPackage>, Vec<String>)> {
    let url = {
        let mut url = AURWEB_INFO.to_owned();
        for pkg in packages
            .iter()
            .flat_map(|p| p.as_ref().split('\n'))
            .map(str::trim)
            .filter(|p| !p.is_empty())
        {
            url = url + "&arg[]=" + &uri_encode_pkg(valid_arch_package_name(pkg)?);
        }
        url
    };

    let mut buf = Vec::new();
    {
        let mut handle = curl::easy::Easy::new();
        handle.url(&url)?;
        let mut transfer = handle.transfer();
        transfer.write_function(|data| {
            buf.extend_from_slice(data);
            Ok(data.len())
        })?;
        transfer.perform()?;
    }

    let mut json = json::parse(str::from_utf8(&buf)?)?;

    let not_in_aur: Vec<_> = {
        let in_aur: HashSet<_> = json["results"]
            .members()
            .filter_map(|info| info["Name"].as_str().map(str::to_lowercase))
            .collect();

        packages
            .iter()
            .map(|p| p.as_ref().to_lowercase())
            .filter(|pkg| !in_aur.contains(pkg))
            .collect()
    };

    let mut maintained_pkgs = vec![];
    for info in json["results"].members_mut() {
        let name = info["Name"].take_string();
        let maintainer = info["Maintainer"].take_string();
        if let (Some(name), Some(maintainer)) = (name, maintainer) {
            maintained_pkgs.push(MaintainedPackage { name, maintainer });
        }
    }

    Ok((maintained_pkgs, not_in_aur))
}

fn valid_arch_package_name(name: &str) -> Result<&str, String> {
    fn valid_char(c: char) -> bool {
        // https://wiki.archlinux.org/index.php/Arch_packaging_standards#Package_naming
        // enforced to ensure a valid url request later
        c.is_alphanumeric() || c == '@' || c == '.' || c == '_' || c == '+' || c == '-'
    }

    if !name.is_empty() && name.chars().all(valid_char) {
        Ok(name)
    } else {
        Err(format!("package name `{}` is invalid", name))
    }
}

fn uri_encode_pkg(pkg_name: &str) -> Cow<'_, str> {
    if pkg_name.contains('@') || pkg_name.contains('+') {
        Cow::Owned(pkg_name.replace('@', "%40").replace('+', "%2B"))
    } else {
        Cow::Borrowed(pkg_name)
    }
}

fn print_help() -> Result<(), Box<dyn Error>> {
    eprintln!("trust-check: output aurto-untrusted package:maintainer");
    eprintln!("  Usage: trust-check PACKAGES...");
    Ok(())
}

#[test]
fn translate_full_package_for_package_name() {
    assert_eq!(translate_full_package("aurto".into()), Ok("aurto".into()));
    assert_eq!(
        translate_full_package("gnome-shell-extension-arch-update".into()),
        Ok("gnome-shell-extension-arch-update".into()),
    );
}

#[test]
fn translate_full_package_for_archive_name() {
    assert_eq!(
        translate_full_package("/home/alex/tmp/aurto-0.6.7-2-any.pkg.tar.gz".into()),
        Ok("aurto".into()),
    );
    assert_eq!(
        translate_full_package("../gnome-shell-extension-arch-update-26-1-any.pkg.tar.gz".into()),
        Ok("gnome-shell-extension-arch-update".into()),
    );
}

#[test]
fn uri_encode_normal_pkg() {
    assert_eq!(&uri_encode_pkg("aurto"), "aurto");
}

#[test]
fn uri_encode_special_pkg() {
    assert_eq!(&uri_encode_pkg("libc++"), "libc%2B%2B");
}
