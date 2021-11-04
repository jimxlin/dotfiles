#==============================================================================
# Disk usage per directory, in Mac OS X and Linux
#==============================================================================

function usage() {
  case $OSTYPE in
  *'darwin'*)
    du -hd 1 "$@"
    ;;
  *'linux'*)
    du -h --max-depth=1 "$@"
    ;;
  esac
}

#==============================================================================
# Make one or more directories and cd into the last one
#==============================================================================

function mkcd() {
  # mkcd foo
  # mkcd /tmp/img/photos/large
  # mkcd foo foo1 foo2 fooN
  # mkcd /tmp/img/photos/large /tmp/img/photos/self /tmp/img/photos/Beijing
  mkdir -p -- "$@" && cd -- "${!#}" || return
}

#==============================================================================
# Use mankier.com to explain other commands
#==============================================================================

explain() {
  if [ "$#" -eq 0 ]; then
    while read -p "Command: " cmd; do
      curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$cmd"
    done
    echo "Bye!"
  elif [ "$#" -eq 1 ]; then
    curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$1"
  else
    echo "Usage"
    echo "explain                  interactive mode."
    echo "explain 'cmd -o | ...'   one quoted command to explain it."
  fi
}

#==============================================================================
# Simplify `curl cht.sh/<query>` to `cht.sh <query>`
#==============================================================================

function cht.sh() {
  # [ ( topic [sub-topic] ) | ~keyword ] [ :list | :help | :learn ]'
  # Separate arguments with '/', preserving spaces within them
  local query=$(
    IFS=/
    echo "$*"
  )
  curl "cht.sh/${query}"
}

#==============================================================================
# Extract any compressed file
#==============================================================================

extract() {
  local opt
  local OPTIND=1
  while getopts "hv" opt; do
    case "$opt" in
    h)
      cat <<End-Of-Usage
Usage: ${FUNCNAME[0]} [option] <archives>
    options:
        -h  show this message and exit
        -v  verbosely list files processed
End-Of-Usage
      return
      ;;
    v)
      local -r verbose='v'
      ;;
    ?)
      extract -h >&2
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  [ $# -eq 0 ] && extract -h && return 1
  while [ $# -gt 0 ]; do
    if [[ ! -f "$1" ]]; then
      echo "extract: '$1' is not a valid file" >&2
      shift
      continue
    fi

    local -r filename=$(basename -- $1)
    local -r filedirname=$(dirname -- $1)
    local targetdirname=$(sed 's/\(\.tar\.bz2$\|\.tbz$\|\.tbz2$\|\.tar\.gz$\|\.tgz$\|\.tar$\|\.tar\.xz$\|\.txz$\|\.tar\.Z$\|\.7z$\|\.nupkg$\|\.zip$\|\.war$\|\.jar$\)//g' <<<$filename)
    if [ "$filename" = "$targetdirname" ]; then
      # archive type either not supported or it doesn't need dir creation
      targetdirname=""
    else
      mkdir -v "$filedirname/$targetdirname"
    fi

    if [ -f "$1" ]; then
      case "$1" in
      *.tar.bz2 | *.tbz | *.tbz2) tar "x${verbose}jf" "$1" -C "$filedirname/$targetdirname" ;;
      *.tar.gz | *.tgz) tar "x${verbose}zf" "$1" -C "$filedirname/$targetdirname" ;;
      *.tar.xz | *.txz) tar "x${verbose}Jf" "$1" -C "$filedirname/$targetdirname" ;;
      *.tar.Z) tar "x${verbose}Zf" "$1" -C "$filedirname/$targetdirname" ;;
      *.bz2) bunzip2 "$1" ;;
      *.deb) dpkg-deb -x${verbose} "$1" "${1:0:-4}" ;;
      *.pax.gz)
        gunzip "$1"
        set -- "$@" "${1:0:-3}"
        ;;
      *.gz) gunzip "$1" ;;
      *.pax) pax -r -f "$1" ;;
      *.pkg) pkgutil --expand "$1" "${1:0:-4}" ;;
      *.rar) unrar x "$1" ;;
      *.rpm) rpm2cpio "$1" | cpio -idm${verbose} ;;
      *.tar) tar "x${verbose}f" "$1" -C "$filedirname/$targetdirname" ;;
      *.xz) xz --decompress "$1" ;;
      *.zip | *.war | *.jar | *.nupkg) unzip "$1" -d "$filedirname/$targetdirname" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7za x -o"$filedirname/$targetdirname" "$1" ;;
      *) echo "'$1' cannot be extracted via extract" >&2 ;;
      esac
    fi

    shift
  done
}

#==============================================================================
# Docker and docker-compose helper functions
#==============================================================================

function docker-remove-most-recent-container() {
  # attempt to remove the most recent container from docker ps -a
  docker ps -ql | xargs docker rm
}

function docker-remove-most-recent-image() {
  # attempt to remove the most recent image from docker images
  docker images -q | head -1 | xargs docker rmi
}

function docker-remove-stale-assets() {
  # attempt to remove exited containers and dangling images
  docker ps --filter status=exited -q | xargs docker rm --volumes
  docker images --filter dangling=true -q | xargs docker rmi
}

function docker-enter() {
  # enter the specified docker container using bash
  docker exec -it "$@" /bin/bash
}

function docker-remove-images() {
  # attempt to remove images with supplied tags or all if no tags are supplied
  if [ -z "$1" ]; then
    docker rmi $(docker images -q)
  else
    DOCKER_IMAGES=""
    for IMAGE_ID in $@; do DOCKER_IMAGES="$DOCKER_IMAGES\|$IMAGE_ID"; done
    # Find the image IDs for the supplied tags
    ID_ARRAY=($(docker images | grep "${DOCKER_IMAGES:2}" | awk {'print $3'}))
    # Strip out duplicate IDs before attempting to remove the image(s)
    docker rmi $(echo ${ID_ARRAY[@]} | tr ' ' '\n' | sort -u | tr '\n' ' ')
  fi
}

function docker-image-dependencies() {
  # attempt to create a Graphiz image of the supplied image ID dependencies
  if hash dot 2>/dev/null; then
    OUT=$(mktemp -t docker-viz-XXXX.png)
    docker images -viz | dot -Tpng >$OUT
    case $OSTYPE in
    linux*)
      xdg-open $OUT
      ;;
    darwin*)
      open $OUT
      ;;
    esac
  else
    echo >&2 "Can't show dependencies; Graphiz is not installed"
  fi
}

function docker-runtime-environment() {
  # attempt to list the environmental variables of the supplied image ID
  docker run "$@" env
}

function docker-archive-content() {
  # show the content of the provided Docker image archive
  if [ -n "$1" ]; then
    tar -xzOf $1 manifest.json | jq '[.[] | .RepoTags] | add'
  fi
}

function docker-compose-fresh() {
  # Shut down, remove and start again the docker-compose setup, then tail the logs
  # param: name of the docker-compose.yaml file to use (optional), default: docker-compose.yaml
  local DCO_FILE_PARAM=""
  if [ -n "$1" ]; then
    echo "Using docker-compose file: $1"
    DCO_FILE_PARAM="--file $1"
  fi

  docker-compose $DCO_FILE_PARAM stop
  docker-compose $DCO_FILE_PARAM rm -f
  docker-compose $DCO_FILE_PARAM up -d
  docker-compose $DCO_FILE_PARAM logs -f --tail 100
}

#==============================================================================
# Add completion for all aliases to commands with completion functions
#==============================================================================

function _bash-it-array-contains-element() {
  local e
  for e in "${@:2}"; do
    [[ "$e" == "$1" ]] && return 0
  done
  return 1
}

function alias_completion {
  local namespace="alias_completion"
  local tmp_file completion_loader alias_name alias_tokens line completions
  local alias_arg_words new_completion compl_func compl_wrapper

  # parse function based completion definitions, where capture group 2 => function and 3 => trigger
  local compl_regex='complete( +[^ ]+)* -F ([^ ]+) ("[^"]+"|[^ ]+)'
  # parse alias definitions, where capture group 1 => trigger, 2 => command, 3 => command arguments
  local alias_regex="alias( -- | )([^=]+)='(\"[^\"]+\"|[^ ]+)(( +[^ ]+)*)'"

  # create array of function completion triggers, keeping multi-word triggers together
  eval "completions=($(complete -p | sed -Ene "/$compl_regex/s//'\3'/p"))"
  ((${#completions[@]} == 0)) && return 0

  # create temporary file for wrapper functions and completions
  tmp_file="$(mktemp -t "${namespace}-${RANDOM}XXXXXX")" || return 1

  completion_loader="$(complete -p -D 2>/dev/null | sed -Ene 's/.* -F ([^ ]*).*/\1/p')"

  # read in "<alias> '<aliased command>' '<command args>'" lines from defined aliases
  # some aliases do have backslashes that needs to be interpreted
  # shellcheck disable=SC2162
  while read line; do
    eval "alias_tokens=($line)" 2>/dev/null || continue # some alias arg patterns cause an eval parse error
    # shellcheck disable=SC2154 # see `eval` above
    alias_name="${alias_tokens[0]}" alias_cmd="${alias_tokens[1]}" alias_args="${alias_tokens[2]# }"

    # skip aliases to pipes, boolean control structures and other command lists
    # (leveraging that eval errs out if $alias_args contains unquoted shell metacharacters)
    eval "alias_arg_words=($alias_args)" 2>/dev/null || continue
    # avoid expanding wildcards
    read -a alias_arg_words <<<"$alias_args"

    # skip alias if there is no completion function triggered by the aliased command
    if ! _bash-it-array-contains-element "$alias_cmd" "${completions[@]}"; then
      if [[ -n "$completion_loader" ]]; then
        # force loading of completions for the aliased command
        eval "$completion_loader $alias_cmd"
        # 124 means completion loader was successful
        [[ $? -eq 124 ]] || continue
        completions+=("$alias_cmd")
      else
        continue
      fi
    fi
    new_completion="$(complete -p "$alias_cmd" 2>/dev/null)"

    # create a wrapper inserting the alias arguments if any
    if [[ -n $alias_args ]]; then
      compl_func="${new_completion/#* -F /}"
      compl_func="${compl_func%% *}"
      # avoid recursive call loops by ignoring our own functions
      if [[ "${compl_func#_"$namespace"::}" == "$compl_func" ]]; then
        compl_wrapper="_${namespace}::${alias_name}"
        echo "function $compl_wrapper {
                        local compl_word=\$2
                        local prec_word=\$3
                        # check if prec_word is the alias itself. if so, replace it
                        # with the last word in the unaliased form, i.e.,
                        # alias_cmd + ' ' + alias_args.
                        if [[ \$COMP_LINE == \"\$prec_word \$compl_word\" ]]; then
                            prec_word='$alias_cmd $alias_args'
                            prec_word=\${prec_word#* }
                        fi
                        (( COMP_CWORD += ${#alias_arg_words[@]} ))
                        COMP_WORDS=($alias_cmd $alias_args \${COMP_WORDS[@]:1})
                        (( COMP_POINT -= \${#COMP_LINE} ))
                        COMP_LINE=\${COMP_LINE/$alias_name/$alias_cmd $alias_args}
                        (( COMP_POINT += \${#COMP_LINE} ))
                        $compl_func \"$alias_cmd\" \"\$compl_word\" \"\$prec_word\"
                    }" >>"$tmp_file"
        new_completion="${new_completion/ -F $compl_func / -F $compl_wrapper }"
      fi
    fi

    # replace completion trigger by alias
    if [[ -n $new_completion ]]; then
      new_completion="${new_completion% *} $alias_name"
      echo "$new_completion" >>"$tmp_file"
    fi
  done < <(alias -p | sed -Ene "s/$alias_regex/\2 '\3' '\4'/p")
  # shellcheck source=/dev/null
  source "$tmp_file" && command rm -f "$tmp_file"
}

alias_completion
