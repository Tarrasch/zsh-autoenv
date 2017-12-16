Test recursing into parent .autoenv.zsh files.

  $ source $TESTDIR/setup.zsh || return 1

Setup env actions / output.

  $ AUTOENV_LOOK_UPWARDS=1

Create env files in root dir.

  $ echo 'echo ENTERED_root: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv.zsh
  $ echo 'echo LEFT_root: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv_leave.zsh
  $ test_autoenv_auth_env_files

Create env files in sub dir.

  $ mkdir -p sub/sub2/sub3/sub4
  $ cd sub
  ENTERED_root: PWD:sub from:source-parent-until.t to:sub

  $ echo 'echo ENTERED_sub: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv.zsh
  $ echo 'echo LEFT_sub: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv_leave.zsh
  $ test_autoenv_auth_env_files

  $ cd sub2
  ENTERED_sub: PWD:sub2 from:sub to:sub2
  $ echo 'echo ENTERED_sub2: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv.zsh
  $ echo 'echo LEFT_sub2: PWD:${PWD:t} from:${autoenv_from_dir:t} to:${autoenv_to_dir:t}' > .autoenv_leave.zsh
  $ test_autoenv_auth_env_files

The actual tests.

# $ cd sub3
# ENTERED_sub2: PWD:sub3 from:sub2 to:sub3
# $ cd ../..
# LEFT_sub2: PWD:sub from:sub3 to:sub
  $ cd ..

Add sub/sub2/sub3/.autoenv.zsh file, with a call to autoenv_source_parent,
stopping at the parent dir.

  $ echo "echo autoenv_source_parent_from_sub3:\nautoenv_source_parent ..\necho done_sub3\n" > sub2/sub3/.autoenv.zsh
  $ test_autoenv_add_to_env sub2/sub3/.autoenv.zsh
  $ cd sub2/sub3
  autoenv_source_parent_from_sub3:
  ENTERED_sub2: PWD:sub3 from:sub to:sub3
  done_sub3

Look up to `../..` now.

  $ cd ../..
  LEFT_sub2: PWD:sub from:sub3 to:sub
  $ echo "echo autoenv_source_parent_from_sub3:\nautoenv_source_parent ../..\necho done_sub3\n" >| sub2/sub3/.autoenv.zsh
  $ test_autoenv_add_to_env sub2/sub3/.autoenv.zsh
  $ cd sub2/sub3
  autoenv_source_parent_from_sub3:
  ENTERED_sub2: PWD:sub3 from:sub to:sub3
  done_sub3

Remove intermediate .autoenv.zsh from sub2.

  $ cd ../..
  LEFT_sub2: PWD:sub from:sub3 to:sub
  $ rm sub2/.autoenv.zsh

Should source "sub" for ../.. now.

  $ echo "echo autoenv_source_parent_from_sub3:\nautoenv_source_parent ../..\necho done_sub3\n" >| sub2/sub3/.autoenv.zsh
  $ test_autoenv_add_to_env sub2/sub3/.autoenv.zsh
  $ cd sub2/sub3
  autoenv_source_parent_from_sub3:
  ENTERED_sub: PWD:sub3 from:sub to:sub3
  done_sub3

Should source nothing for .. now.

  $ cd ../..
  $ echo "echo autoenv_source_parent_from_sub3:\nautoenv_source_parent ..\necho done_sub3\n" >| sub2/sub3/.autoenv.zsh
  $ test_autoenv_add_to_env sub2/sub3/.autoenv.zsh
  $ cd sub2/sub3
  autoenv_source_parent_from_sub3:
  done_sub3

Look up to "/" (default).

  $ cd ../..
  $ echo "echo autoenv_source_parent_from_sub3:\nautoenv_source_parent /\necho done_sub3\n" >| sub2/sub3/.autoenv.zsh
  $ test_autoenv_add_to_env sub2/sub3/.autoenv.zsh
  $ cd sub2/sub3
  autoenv_source_parent_from_sub3:
  ENTERED_sub: PWD:sub3 from:sub to:sub3
  done_sub3

Handles dirs with spaces.

  $ mkdir "dir with space"
  $ echo "echo entered \$PWD\n" >| "dir with space/.autoenv.zsh"
  $ test_autoenv_add_to_env "dir with space/.autoenv.zsh"
  $ cd "dir with space"
  entered */dir with space (glob)

Handles dirs with spaces outside any root (should not hang).

  $ cd $CRAMTMP || exit
  LEFT_root: * (glob)
  LEFT_sub: * (glob)
  $ mkdir "dir with space"
  $ cd "dir with space"
