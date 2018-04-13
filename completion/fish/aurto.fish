## Tab completion for aurto

complete -c aurto -x -n '__fish_use_subcommand' -a 'add' -d 'Add & build aur packages by name'
complete -c aurto -x -n '__fish_seen_subcommand_from add'

complete -c aurto -x -n '__fish_use_subcommand' -a 'addpkg' -d 'Add prebuilt aur package files'
complete -c aurto -r -n '__fish_seen_subcommand_from addpkg'

complete -c aurto -x -n '__fish_use_subcommand' -a 'remove' -d 'Remove aur packages by name'
complete -c aurto -x -n '__fish_seen_subcommand_from remove' -a '(pacman -Slq aurto 2>/dev/null)'
