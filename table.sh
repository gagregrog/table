#~/usr/bin/env bash

set -euo pipefail


#####################################
# CLI ARGS
#####################################

SCENE=flip
while [[ $# -gt 0 ]]; do
  case $1 in
    --fps)
      fps="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--scan)
      SCENE=scan
      shift # past argument
      ;;
    -f|--flip)
      SCENE=flip
      shift # past argument
      ;;
    -h|--help)
      SCENE=help
      shift # past argument
      ;;
    *)
      echo Unknown argument: $1
      exit 1
      ;;
  esac
done


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
  if [ $SCENE != "help" ]; then
    tput rmcup # replace screen
    tput cnorm # show cursor
    stty ${stty_orig} # enable normal keypress echo
  fi
  exit
}


#####################################
# FACES
#####################################

faceRight="( °□°)"
faceLeft="(°□° )"
flipTableRight="(╯°□°）╯︵ ┻━┻"
fixTableLeft="┬─┬ノ( º _ ºノ)"
table="┬─┬"


#####################################
# MATH
#####################################

function divide() {
  awk "BEGIN {print $1 / $2}"
}

function getCenterStart() {
  local item="$1"
  local itemLength=${#item}
  local center=$((cols / 2))
  if [ $((center % 2)) -eq 1 ]; then
    ((center++))
  fi
  local halfLength=$((itemLength / 2))
  echo $((center - halfLength))
}


#####################################
# DEFAULTS / CONSTANTS
#####################################

cols=$(tput cols)
rows=$(tput lines)
middleY=$(($rows / 2))
middleX=$(($cols / 2))
fps=${fps:-"60"}
delay=$(divide 1 $fps)


#####################################
# HELP
#####################################

function help() {
cat << EOF

####################################################
# table.sh                           $flipTableRight
####################################################

Everybody's favorite table flipper, lightly animated

Options:
  --fps [value]         running speed
  --flip                run the flip scene (default)
  --scan                run the scan scene
  -h, --help            display this help
EOF
}


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
# SCENES
#####################################

function scan() {
  local actorRight=${1:-"$faceRight"}
  local actorLeft=${2:-"$faceLeft"}
  local waitFor=${3:-"$delay"}
  local row=0
  while [ "$row" -le "$rows" ]; do
    if [ $((row % 2)) -eq "0" ]; then
      scanRight "$actorRight" $row $waitFor
    else
      scanLeft "$actorLeft" $row $waitFor
    fi
    ((row++))
    sleep $waitFor
  done
}

function flip() {
  local tableStart=$(getCenterStart $table)
  local eyeSleep=1
  tput cup $middleY $tableStart
  echo $table
  enterLeft "$faceRight"
  moveRight "$faceRight" 0 $tableStart
  local actorStart=$((tableStart - ${#faceRight}))
  sleep $eyeSleep
  tput cup $middleY $actorStart
  echo $faceLeft
  sleep $eyeSleep
  tput cup $middleY $actorStart
  echo $faceRight
  sleep $eyeSleep
  tput cup $middleY $actorStart
  echo $flipTableRight
  sleep 0.1
  tput cup $middleY $((actorStart + 8))
  echo " " # cleanup the little ︵
  sleep 0.5
  tput cup $middleY $actorStart
  echo "           " # cleanup the arms
  moveLeft "$faceLeft" $actorStart 0
  exitLeft "$faceLeft"
}


#####################################
# MAIN
#####################################

if [ $SCENE != "help" ]; then
  setup
fi

case $SCENE in
  help)
    help
    ;;
  scan)
    scan
    ;;
  flip)
    flip
    ;;
  *)
    echo Unknown scene: $SCENE
    exit 1
    ;;
esac
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
