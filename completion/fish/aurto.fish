## Tab completion for aurto

function __aurto_complete_add
  set -l search (commandline -ct)
  if [ (string length $search) -gt 2 ]
    aursearch -nrP "^$search" \
      | jq '.[].results[] | .Name' \
      | cut -d'"' -f2
  end
end

complete -c aurto -x -n '__fish_use_subcommand' -a 'add' -d 'Add & build aur packages by name'
complete -c aurto -x -n '__fish_seen_subcommand_from add'
if type -q aursearch; and type -q jq
  complete -c aurto -x -n '__fish_seen_subcommand_from add' -a '(__aurto_complete_add)'
end

complete -c aurto -x -n '__fish_use_subcommand' -a 'addpkg' -d 'Add prebuilt aur package files'
complete -c aurto -r -n '__fish_seen_subcommand_from addpkg'

complete -c aurto -x -n '__fish_use_subcommand' -a 'remove' -d 'Remove aur packages by name'
complete -c aurto -x -n '__fish_seen_subcommand_from remove' -a '(pacman -Slq aurto 2>/dev/null)'
