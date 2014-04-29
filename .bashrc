
# Hexadécimal vers décimal
h2d(){
  echo "ibase=16; $@" | tr -s ' ' ';' | bc
}
# Décimal vers hexadécimal
d2h(){
  echo "obase=16; $@" | tr -s ' ' ';' | bc
}
 
# Binaire vers décimal
b2d(){
  echo "ibase=2; $@" | tr -s ' ' ';' | bc
}
# Décimal vers binaire
d2b(){
  echo "obase=2; $@" | tr -s ' ' ';' | bc
}

## OVERALL CONDITIONALS {{{
_islinux=false
[[ "$(uname -s)" =~ Linux|GNU|GNU/* ]] && _islinux=true

_isarch=false
[[ -f /etc/arch-release ]] && _isarch=true

_isxrunning=false
[[ -n "$DISPLAY" ]] && _isxrunning=true

_isroot=false
[[ $UID -eq 0 ]] && _isroot=true
# }}}
## PS1 CONFIG {{{

  [[ -f $HOME/.dircolors ]] && eval $(dircolors -b $HOME/.dircolors)
  if $_isxrunning; then

    [[ -f $HOME/.dircolors_256 ]] && eval $(dircolors -b $HOME/.dircolors_256)

    export TERM='xterm-256color'

     B='\[\e[1;38;5;33m\]'
    LB='\[\e[1;38;5;81m\]'
    GY='\[\e[1;38;5;242m\]'
     G='\[\e[1;38;5;82m\]'
     P='\[\e[1;38;5;161m\]'
    PP='\[\e[1;38;5;93m\]'
     R='\[\e[1;38;5;196m\]'
     Y='\[\e[1;38;5;214m\]'
     W='\[\e[0m\]'

    get_prompt_symbol() {
      [[ $UID == 0 ]] && echo "#" || echo "\$"
    }

    get_git_branch() {
      # On branches, this will return the branch name
      # On non-branches, (no branch)
      ref="$(git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///')"
      [[ -n $ref ]] && echo "$ref" || echo "(no branch)"
    }

    is_branch1_behind_branch2 () {
      # Find the first log (if any) that is in branch1 but not branch2
      first_log="$(git log $1..$2 -1 2> /dev/null)"
      # Exit with 0 if there is a first log, 1 if there is not
      [[ -n "$first_log" ]]
    }

    branch_exists () {
      # List remote branches | # Find our branch and exit with 0 or 1 if found/not found
      git branch --remote 2> /dev/null | grep --quiet "$1"
    }

    parse_git_ahead () {
      # Grab the local and remote branch
      branch="$(get_git_branch)"
      remote_branch=origin/"$branch"
      # If the remote branch is behind the local branch
      # or it has not been merged into origin (remote branch doesn't exist)
      (is_branch1_behind_branch2 $remote_branch $branch || ! branch_exists $remote_branch) && echo 1
    }

    parse_git_behind () {
      # Grab the branch
      branch=$(get_git_branch)
      remote_branch=origin/$branch
      # If the local branch is behind the remote branch
      is_branch1_behind_branch2 $branch $remote_branch && echo 1
    }

    parse_git_dirty () {
      # If the git status has *any* changes (i.e. dirty)
      [[ -n "$(git status --porcelain 2> /dev/null)" ]] && echo 1
    }

    function get_git_status() {
      # Grab the git dirty and git behind
      dirty_branch="$(parse_git_dirty)"
      branch_ahead="$(parse_git_ahead)"
      branch_behind="$(parse_git_behind)"

      # Iterate through all the cases and if it matches, then echo
      if [[ $dirty_branch == 1 && $branch_ahead == 1 && $branch_behind == 1 ]]; then
        echo "⬢"
      elif [[ $dirty_branch == 1 && $branch_ahead == 1 ]]; then
        echo "▲"
      elif [[ $dirty_branch == 1 && $branch_behind == 1 ]]; then
        echo "▼"
      elif [[ $branch_ahead == 1 && $branch_behind == 1 ]]; then
        echo "⬡"
      elif [[ $branch_ahead == 1 ]]; then
        echo "△"
      elif [[ $branch_behind == 1 ]]; then
        echo "▽"
      elif [[ $dirty_branch == 1 ]]; then
        echo "*"
      fi
    }

    get_git_info () {
      # Grab the branch
      branch="$(git branch --no-color 2> /dev/null | awk '{print $2}')"
      # If there are any branches
      if [[ -n $branch ]]; then
        # Add on the git status
        output=$(get_git_status)
        # Echo our output
        echo -e -n " $branch$output"
      fi
    }

    export PS1="$GY[$Y\u$GY@$P\h$GY:$B\W$LB\$(get_git_info)$GY]$W\$(get_prompt_symbol) "
  else
    export TERM='xterm-color'
  fi
#}}}
## BASH OPTIONS {{{
  shopt -s cdspell                 # Correct cd typos
  shopt -s checkwinsize            # Update windows size on command
  shopt -s histappend              # Append History instead of overwriting file
  shopt -s cmdhist                 # Bash attempts to save all lines of a multiple-line command in the same history entry
  shopt -s extglob                 # Extended pattern
  shopt -s no_empty_cmd_completion # No empty completion
  ## COMPLETION #{{{
    complete -cf sudo
    if [[ -f /etc/bash_completion ]]; then
      . /etc/bash_completion
    fi
  #}}}
#}}}
## EXPORTS {{{
  export PATH=/usr/local/bin:$PATH
  #Ruby support
  if which ruby &>/dev/null; then
    GEM_DIR=$(ruby -rubygems -e 'puts Gem.user_dir')/bin
    if [[ -d "$GEM_DIR" ]]; then
      export PATH=$GEM_DIR:$PATH
    fi
  fi
  ## EDITOR #{{{
    if which vim &>/dev/null; then
      export EDITOR="vim"
    elif which emacs &>/dev/null; then
      export EDITOR="emacs -nw"
    else
      export EDITOR="nano"
    fi
  #}}}
  ## BASH HISTORY #{{{
    # make multiple shells share the same history file
    export HISTSIZE=100000           # bash history will save N commands
    export HISTFILESIZE=${HISTSIZE} # bash will remember N commands
    export HISTCONTROL=ignoreboth   # ingore duplicates and spaces
    export HISTIGNORE='&:ls:ll:la:cd:exit:clear:history'
  #}}}
  ## COLORED MANUAL PAGES #{{{
    # @see http://www.tuxarena.com/?p=508
    # For colourful man pages (CLUG-Wiki style)
    if $_isxrunning; then
      export PAGER=less
      export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
      export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
      export LESS_TERMCAP_me=$'\E[0m'           # end mode
      export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
      export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
      export LESS_TERMCAP_ue=$'\E[0m'           # end underline
      export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline
    fi
  #}}}
#}}}
## ALIAS {{{
  alias freemem='sudo /sbin/sysctl -w vm.drop_caches=3'
  alias matrix='echo -e "\e[32m"; while :; do for i in {1..16}; do r="$(($RANDOM % 2))"; if [[ $(($RANDOM % 5)) == 1 ]]; then if [[ $(($RANDOM % 4)) == 1 ]]; then v+="\e[1m $r   "; else v+="\e[2m $r   "; fi; else v+="     "; fi; done; echo -e "$v"; v=""; done'
  # MODIFIED COMMANDS {{{
  alias rm='rm -fr'
  alias cp='cp -r'
  alias mk='make re;make clean'
  alias cc='gcc -g3'
  alias kk='clang -g3'
  alias ..='cd ..'
  alias df='df -h'
  alias diff='colordiff'              # requires colordiff package
  alias du='du -c -h'
  alias free='free -m'                # show sizes in MB
  alias grep='grep --color=auto'
  alias grep='grep --color=tty -d skip'
  alias nano='nano -w'
  alias ping='ping -c 5'
  alias chrome='google-chrome-stable'
  #AUDIOSAMPLES
    alias clair='aplay ~/samples/clair.wav'
    alias bite='aplay ~/samples/bite.wav'
    alias jm='aplay ~/samples/jm.wav'
    alias 77='aplay ~/samples/77.wav'
    alias clair='aplay ~/samples/clair.wav'
    alias hl='aplay ~/samples/hal.wav'
    alias wd='qmmp ~/samples/weed.mp3'
    #}}}
    # EPITECH MAKEFILE
    alias MAKE='make'
    alias Make='make'
    alias RE='re'
   
   # PRIVILEGED ACCESS {{{
    if ! $_isroot; then
	alias sudo='sudo '
	alias scat='sudo cat'
	alias svim='sudo vim'
	alias root='sudo su'
      alias reboot='sudo reboot'
      alias halt='sudo halt'
    fi
    #}}}
    # PACMAN ALIASES {{{
    # we're on ARCH
    if $_isarch; then
      # we're not root
	if ! $_isroot; then
            alias pacman='sudo pacman'
	fi
	alias pacupg='pacman -Syu'            # Synchronize with repositories and then upgrade packages that are out of date on the local system.
	alias pacupd='pacman -Sy'             # Refresh of all package lists after updating /etc/pacman.d/mirrorlist
	alias pacin='pacman -S'               # Install specific package(s) from the repositories
	alias pacinu='pacman -U'              # Install specific local package(s)
	alias pacre='pacman -R'               # Remove the specified package(s), retaining its configuration(s) and required dependencies
	alias pacun='pacman -Rcsn'            # Remove the specified package(s), its configuration(s) and unneeded dependencies
	alias pacinfo='pacman -Si'            # Display information about a given package in the repositories
	alias pacse='pacman -Ss'              # Search for package(s) in the repositories
	
	alias pacupa='pacman -Sy && sudo abs' # Update and refresh the local package and ABS databases against repositories
	alias pacind='pacman -S --asdeps'     # Install given package(s) as dependencies of another package
	alias pacclean="pacman -Sc"           # Delete all not currently installed package files
	alias pacmake="makepkg -fcsi"         # Make package from PKGBUILD file in current directory
    fi
    #}}}
    # MULTIMEDIA {{{
    if which get_flash_videos &>/dev/null; then
      alias gfv='get_flash_videos -r 720p --subtitles'
    fi
    if which simple-mtpfs &>/dev/null; then
      alias android-connect="simple-mtpfs /media/android"
      alias android-disconnect="fusermount -u /media/android"
    fi
  #}}}
  # LS {{{
    alias ls='ls -hF --color=auto'
    alias lr='ls -R'                    # recursive ls
    alias ll='ls -alh'
    alias la='ll -A'
    alias lm='la | more'
  #}}}
#}}}
    #EPITECH
    alias untar='tar -xvzf'
    alias tmp='rm *~ ; rm *#'
    alias ne='emacs -nw'
    alias v='valgrind'
    alias vf='valgrind --leak-check=full --show-leak-kinds=all'
    alias commit='git config --global user.name "tovazm";git commit -m'
## FUNCTIONS {{{
  # GITPLUS {{{
    #GNOME ONLY
    #disable gnome graphic askpass
    unset SSH_ASKPASS
    gitp(){
      usage(){
        echo "Usage: $0 [options]"
        echo " au, [autoconfig]                  # Autoconfigure git options"
        echo "  a, [add=FILES] [--all]           # Add git files"
        echo "  c, [commit=TEXT] [--undo]        # Add git files"
        echo "  b, [branch=feature,hotfix,*]     # Add/Change Branch"
        echo "  d, [delete] <branch> <name>      # Delete Branch"
        echo "  l, [log]                         # Display Log"
        echo "  m, [merge=feature,hotfix,*]      # Merge branches"
        echo "  p, [push=BRANCH]                 # Push files"
        echo "  P, [pull=BRANCH]                 # Pull files"
        echo "  r, [release]                     # Merge devel branch on master"
        return 1
      }
      case $1 in
        au | autoconfig)
          local NAME=`git config --global user.name`
          local EMAIL=`git config --global user.email`
          local USER=`git config --global github.user`
          local EDITOR=`git config --global core.editor`

          [[ -z $NAME ]] && read -p "Nome: " NAME
          [[ -z $EMAIL ]] && read -p "Email: " EMAIL
          [[ -z $USER ]] && read -p "Username: " USER
          [[ -z $EDITOR ]] && read -p "Editor: " EDITOR

          git config --global user.name $NAME
          git config --global user.email $EMAIL
          git config --global github.user $USER
          git config --global color.ui true
          git config --global color.status auto
          git config --global color.branch auto
          git config --global color.diff auto
          git config --global diff.color true
          git config --global push.default matching
          git config --global core.editor $EDITOR
          git config --global alias.undo-commit 'reset --soft HEAD^'
          if which meld &>/dev/null; then
            git config --global diff.guitool meld
            git config --global merge.tool meld
          elif which kdiff3 &>/dev/null; then
            git config --global diff.guitool kdiff3
            git config --global merge.tool kdiff3
          fi
          git config --global --list
          ;;
        a | add)
          if [[ $2 == --all ]]; then
            git add -A
          else
            git add $2
          fi
          ;;
        c | commit )
          if [[ $2 == --undo ]]; then
            git reset --soft HEAD^
          else
            git commit -am "$2"
          fi
          ;;
        b | branch )
          check_branch=`git branch | grep $2`
          case $2 in
            feature)
              [[ -z $check_branch ]] && git branch -f onfire origin/onfire
              git checkout -b feature --track origin/onfire
              ;;
            hotfix)
              git ckeckout -b hotfix master
              ;;
            *)
              check_branch=`git branch | grep $2`
              [[ -z $check_branch ]] && git branch -f $2 origin/$2
              git checkout -b $2
              ;;
          esac
          ;;
        d | delete)
          case $2 in
            branch)
              git branch -d $3
              git push origin --delete $3
              ;;
            *)
              echo "Invalid argument"
              ;;
          esac
          ;;
        l | log )
          git log
          ;;
        m | merge )
          check_branch=`git branch | grep $2`
          case $2 in
            --fix)
              git mergetool
              ;;
            feature)
              if [[ -z $check_branch ]]; then
                git checkout onfire
                git difftool -g -d onfire..feature
                git merge --no-ff feature
                git branch -d feature
                git commit -am "${3}"
              else
                echo "No onfire branch founded."
              fi
              ;;
            hotfix)
              if [[ -z $check_branch ]]; then
                # get upstream branch
                git checkout -b onfire origin
                git merge --no-ff hotfix
                git commit -am "hotfix: v${3}"
                # get master branch
                git checkout -b master origin
                git merge hotfix
                git commit -am "Hotfix: v${3}"
                git branch -d hotfix
                git tag -a $3 -m "Release: v${3}"
                git push --tags
              else
                echo "No hotfix branch founded."
              fi
              ;;
            *)
              if [[ -z $check_branch ]]; then
                git checkout -b master origin
                git difftool -g -d master..$2
                git merge --no-ff $2
                git branch -d $2
                git commit -am "${3}"
              else
                echo "No onfire branch founded."
              fi
              ;;
          esac
          ;;
        p | push )
          git push origin $2
          ;;
        P | pull )
          git pull origin $2
          ;;
        r | release )
          git checkout origin/master
          git merge --no-ff origin/onfire
          git branch -d onfire
          git tag -a $2 -m "Release: v${2}"
          git push --tags
          ;;
        *)
          usage
      esac
    }
  #}}}
  # TOP 10 COMMANDS {{{
    # copyright 2007 - 2010 Christopher Bratusek
    top10() { history | awk '{a[$2]++ } END{for(i in a){print a[i] " " i}}' | sort -rn | head; }
  #}}}
  # UP {{{
    # Goes up many dirs as the number passed as argument, if none goes up by 1 by default
    up() {
      local d=""
      limit=$1
      for ((i=1 ; i <= limit ; i++)); do
        d=$d/..
      done
      d=$(echo $d | sed 's/^\///')
      if [[ -z "$d" ]]; then
        d=..
      fi
      cd $d
    }
  #}}}

    #FONCTION EXTRACT

    extract () {
	if [ -f $1 ] ; then
	    case $1 in
		*.tar.bz2) tar xvjf $1 ;;
		*.tar.gz) tar xvzf $1 ;;
		*.bz2) bunzip2 $1 ;;
		*.rar) rar x $1 ;;
		*.gz) gunzip $1 ;;
		*.tar) tar xvf $1 ;;
		*.tbz2) tar xvjf $1 ;;
		*.tgz) tar xvzf $1 ;;
		*.zip) unzip $1 ;;
		*.Z) uncompress $1 ;;
		*.7z) 7z x $1 ;;
		*) echo "don't know how to extract '$1'..." ;;
	    esac
	else
	    echo "'$1' is not a valid file!"
	fi
    }
    #}}}
  # CONVERT TO ISO {{{
    to_iso () {
	if [[ $# == 0 || $1 == "--help" || $1 == "-h" ]]; then
        echo -e "Converts raw, bin, cue, ccd, img, mdf, nrg cd/dvd image files to ISO image file.\nUsage: to_iso file1 file2..."
      fi
      for i in $*; do
        if [[ ! -f "$i" ]]; then
          echo "'$i' is not a valid file; jumping it"
        else
          echo -n "converting $i..."
          OUT=`echo $i | cut -d '.' -f 1`
          case $i in
                *.raw ) bchunk -v $i $OUT.iso;; #raw=bin #*.cue #*.bin
          *.bin|*.cue ) bin2iso $i $OUT.iso;;
          *.ccd|*.img ) ccd2iso $i $OUT.iso;; #Clone CD images
                *.mdf ) mdf2iso $i $OUT.iso;; #Alcohol images
                *.nrg ) nrg2iso $i $OUT.iso;; #nero images
                    * ) echo "to_iso don't know de extension of '$i'";;
          esac
          if [[ $? != 0 ]]; then
            echo -e "${R}ERROR!${W}"
          else
            echo -e "${G}done!${W}"
          fi
        fi
      done
    }
  #}}}
  # REMIND ME, ITS IMPORTANT! {{{
    # usage: remindme <time> <text>
    # e.g.: remindme 10m "omg, the pizza"
    remindme() { sleep $1 && zenity --info --text "$2" & }
  #}}}
  # SIMPLE CALCULATOR #{{{
    # usage: calc <equation>
    calc() {
      if which bc &>/dev/null; then
        echo "scale=3; $*" | bc -l
      else
        awk "BEGIN { print $* }"
      fi
    }
  #}}}
  # FILE & STRINGS RELATED FUNCTIONS {{{
    ## Find a file with a pattern in name {{{
      ff() { find . -type f -iname '*'$*'*' -ls ; }
    #}}}
    ## Find a file with pattern $1 in name and Execute $2 on it {{{
      fe() { find . -type f -iname '*'$1'*' -exec "${2:-file}" {} \;  ; }
    #}}}
    ## Move filenames to lowercase {{{
      lowercase() {
        for file ; do
          filename=${file##*/}
          case "$filename" in
          */* ) dirname==${file%/*} ;;
            * ) dirname=.;;
          esac
          nf=$(echo $filename | tr A-Z a-z)
          newname="${dirname}/${nf}"
          if [[ "$nf" != "$filename" ]]; then
            mv "$file" "$newname"
            echo "lowercase: $file --> $newname"
          else
            echo "lowercase: $file not changed."
          fi
        done
      }
  #}}}
    ## Swap 2 filenames around, if they exist {{{
      #(from Uzi's bashrc).
      swap() {
        local TMPFILE=tmp.$$

        [[ $# -ne 2 ]] && echo "swap: 2 arguments needed" && return 1
        [[ ! -e $1 ]] && echo "swap: $1 does not exist" && return 1
        [[ ! -e $2 ]] && echo "swap: $2 does not exist" && return 1

        mv "$1" $TMPFILE
        mv "$2" "$1"
        mv $TMPFILE "$2"
      }
    #}}}
    ## Finds directory sizes and lists them for the current directory {{{
      dirsize () {
        du -shx * .[a-zA-Z0-9_]* 2> /dev/null | egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
        egrep '^ *[0-9.]*M' /tmp/list
        egrep '^ *[0-9.]*G' /tmp/list
        rm -rf /tmp/list
      }
    #}}}
  #}}}
  # SYSTEMD SUPPORT {{{
    if which systemctl &>/dev/null; then
      start() {
        sudo systemctl start $1.service
      }
      restart() {
        sudo systemctl restart $1.service
      }
      stop() {
        sudo systemctl stop $1.service
      }
      enable() {
        sudo systemctl enable $1.service
      }
      status() {
        sudo systemctl status $1.service
      }
      disable() {
        sudo systemctl disable $1.service
      }
    fi
  #}}}
#}}}
