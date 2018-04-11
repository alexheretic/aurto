function _aurto_no_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'aurto' ]
    return 0
  end
  return 1
end

complete -f -c aurto -n '_aurto_no_command' -a 'add addpkg remove'
