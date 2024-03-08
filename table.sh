#~/usr/bin/env bash

set -euo pipefail

#####################################
# SETUP / TEARDOWN
#####################################

stty_orig=$(stty -g) # capture the original keypress settings

function setup() {
  tput civis # invisible cursor
  tput smcup # save screen
  stty -echo # hide user input
}

trap cleanup 1 2 3 6 EXIT # replace screen on exit

function cleanup() {
  tput rmcup # replace screen
  tput cnorm # show cursor
  stty ${stty_orig} # enable normal keypress echo
  exit
}

#####################################
# MATH
#####################################

function divide() {
  awk "BEGIN {print $1 / $2}"
}


#####################################
# FACES
#####################################

faceRight="( °□°)"
faceLeft="(°□° )"
flipTable="(╯°□°）╯︵ ┻━┻"
fixTable="┬─┬ノ( º _ ºノ)"
table="┬─┬"


#####################################
# DEFAULTS / CONSTANTS
#####################################

cols=$(tput cols)
rows=$(tput lines)
middleY=$(($rows / 2))
middleX=$(($cols / 2))
fps=${1:-"60"} # fps is first arg, defaulting to 60
delay=$(divide 1 $fps)


#####################################
# MOVEMENT
#####################################

function enterLeft() {
  local actor="$1"
  local y=${2:-"$middleY"}
  local waitFor=${3:-"$delay"}
  local drawn=1
  while [ "$drawn" -le $((${#actor} - 1)) ]; do
    tput cup $y 0
    echo "${actor: ((0 - $drawn))}"
    ((drawn++))
    sleep $waitFor
  done
}

function moveRight() {
  local actor="$1"
  local from=${2:-"0"}
  local to=${3:-"$cols"}
  local y=${4:-"$middleY"}
  local waitFor=${5:-"$delay"}
  local x="$from"
  local toActual=$(($to - ${#actor}))
  local spacer=""
  while [ "$x" -le "$toActual" ]; do
    if [ "$x" -eq "0" ]; then
      tput cup $y $x
    else
      tput cup $y $((x - 1))
      spacer=" "
    fi
    echo "$spacer$actor"
    ((x++))
    sleep $waitFor
  done
}

function exitRight() {
  local actor="$1"
  local y=${2:-"$middleY"}
  local waitFor=${3:-"$delay"}
  local remaining=${#actor}
  local x=$(($cols - $remaining))
  while [ "$remaining" -gt "0" ]; do
    tput cup $y $x
    echo " ${actor:0:((remaining - 1))}"
    ((remaining--))
    ((x++))
    sleep $waitFor
  done
}

function scanRight() {
  local actor="$1"
  local y=${2:-"$middleY"}
  local waitFor=${3:-"$delay"}
  enterLeft "$actor" $y $waitFor
  moveRight "$actor" 0 $cols $y $waitFor
  exitRight "$actor" $y $waitFor
}


function enterRight() {
  local actor="$1"
  local y=${2:-"$middleY"}
  local waitFor=${3:-"$delay"}
  local drawn=1
  while [ "$drawn" -lt ${#actor} ]; do
    tput cup $y $((cols - drawn))
    echo "${actor:0:drawn}"
    ((drawn++))
    sleep $waitFor
  done
}

function moveLeft() {
  local actor="$1"
  local from=${2:-$((cols - ${#actor}))}
  local to=${3:-"0"}
  local y=${4:-"$middleY"}
  local waitFor=${5:-"$delay"}
  local x="$from"
  local space=""
  while [ "$x" -ge "$to" ]; do
    tput cup $y $x
    echo "$actor$space"
    space=" "
    ((x--))
    sleep $waitFor
  done
}

function exitLeft() {
  local actor="$1"
  local y=${2:-"$middleY"}
  local waitFor=${3:-"$delay"}
  local remaining=$((${#actor} - 1))
  while [ "$remaining" -ge "0" ]; do
    tput cup $y 0
    if [ "$remaining" -eq "0" ]; then
      echo " "
    else
      echo "${actor: ((0 - remaining))} "
    fi
    ((remaining--))
    sleep $waitFor
  done
}

function scanLeft() {
  local actor="$1"
  local y=${2:-"$middleY"}
  local waitFor=${3:-"$delay"}
  enterRight "$actor" $y $waitFor
  moveLeft "$actor" $((cols - ${#actor})) 0 $y $waitFor
  exitLeft "$actor" $y $waitFor
}


#####################################
# MAIN
#####################################

setup
scanRight "$faceRight"
sleep 0.25
scanLeft "$faceLeft"
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
