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
delay=0.05


#####################################
# MOVEMENT
#####################################

function moveRight() {
  local actor="$1"
  local from=${2:-"0"}
  local to=${3:-"$cols"}
  local y=${4:-"$middleY"}
  local waitFor=${5:-"$delay"}
  local x="$from"
  local toActual=$(($to - ${#actor} - 1))
  while [ "$x" -le "$toActual" ]; do
    tput cup $y $x
    echo " $actor"
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


#####################################
# MAIN
#####################################

setup
moveRight "$faceRight"
exitRight "$faceRight"

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