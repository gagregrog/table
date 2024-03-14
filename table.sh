#!/usr/bin/env bash

#####################################
# SETUP / TEARDOWN
#####################################

set -euo pipefail
stty_orig=$(stty -g) # capture the original keypress settings

function setup() {
  tput civis # invisible cursor
  tput smcup # save screen
  stty -echo # hide user input
}

trap cleanup 1 2 3 6 EXIT 

function cleanup() {
  scene=${SCENE:-""}
  if [[ $scene != "help" ]]; then
    tput rmcup # replace screen
    tput cnorm # show cursor
    stty ${stty_orig} # enable normal keypress echo
  fi
  exit
}


#####################################
# STRING UTILS
#####################################

function makeString() {
  local char=$1
  local targetLength=$2
  local acc=""
  for ((i=0; i < ${targetLength}; i++)); do
    acc="$acc$char"
  done

  echo "$acc"
}

function contains() {
  local LIST=$1
  local VALUE=$2
  local DELIMITER=${3:-" "}
  [[ "$LIST" =~ ($DELIMITER|^)$VALUE($DELIMITER|$) ]]
}

function strlen() {
  local doublewidth="︶"
  local length=${#1}
  for ((i = 0; i < ${#1}; i++)); do
    local char="${1:i:1}"
    if [[ "$doublewidth" == *"$char"* ]]; then
      ((length++))
    fi
  done
  echo $length
}

function repeat() {
  local char=$1
  local times=$2
  local acc=""
  for ((i = 0; i < $times; i++)); do
    acc="$acc$char"
  done

  echo "$acc"
}

function empty() {
  local source="$1"
  local length=$(strlen "$source")
  repeat " " "$length"
}


#####################################
# MATH UTILS
#####################################

function divide() {
  # rather than (($1 / $2)) which only supports integer results
  # awk division will return decimal results
  awk "BEGIN {print $1 / $2}"
}

function getCenterStart() {
  local item="$1"
  local itemLength=$(strlen "$item")
  local center=$((cols / 2))
  if [ $((center % 2)) -eq 1 ]; then
    ((center++))
  fi
  local halfLength=$((itemLength / 2))
  echo $((center - halfLength))
}


#####################################
# DEFAULT PARTS
#####################################

EYE="°"
MOUTH="□"
CHEEK_LEFT="("
CHEEK_RIGHT=")"
FLIP_ARM="╯"
MOTION="︵"


#####################################
# ACTORS
#####################################

actors="burns diss jake pwny zen"

function configureActor() {
  case $1 in
    burns)
      EYE="◉"
      MOUTH="Д"
      FLIP_ARM="┛"
      MOTION="彡"
      ;;
    diss)
      EYE="ಥ"
      MOUTH="_"
      CHEEK_LEFT="«"
      CHEEK_RIGHT="»"
      ;;
    jake)
      EYE="❍"
      MOUTH="ᴥ"
      FLIP_ARM="┛"
      MOTION="彡"
      ;;
    pwny)
      EYE="⊙"
      MOUTH="▂"
      FLIP_ARM="✖"
      ;;
    zen)
      EYE="︶"
      MOUTH="_"
      FLIP_ARM="╭∩╮"
      ;;
  esac
}


#####################################
# CLI ARGS
#####################################

SCENE=flip
while [[ $# -gt 0 ]]; do
  case $1 in
    # options
    -f|--fps)
      fps="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      SCENE=help
      shift # past argument
      ;;
    # actors
    -a|--actor)
      ACTOR=$2
      if ! contains "$actors" "$ACTOR"; then
        echo Unknown actor: $ACTOR
        echo Choose one of: $(echo $actors | sed 's/ /, /g')
        exit 1
      fi
      configureActor $ACTOR

      shift # past argument
      shift # past value
      ;;
    # actor overrides
    -e|--eye)
      EYE=$2
      shift # past argument
      shift # past value
      ;;
    -m|--mouth)
      MOUTH=$2
      shift # past argument
      shift # past value
      ;;
    -cl|--cheek-left)
      CHEEK_LEFT=$2
      shift # past argument
      shift # past value
      ;;
    -cr|--cheek-right)
      CHEEK_RIGHT=$2
      shift # past argument
      shift # past value
      ;;
    -a|--arm)
      FLIP_ARM=$2
      shift # past argument
      shift # past value
      ;;
    -M|--motion)
      MOTION=$2
      shift # past argument
      shift # past value
      ;;
    # table configuration
    -t|--table-length)
      TABLE_LENGTH=$2
      shift # past argument
      shift # past value
      ;;
    # sceens
    -s|--scan)
      SCENE=scan
      shift # past argument
      ;;
    # uh-oh
    *)
      echo Unknown argument: $1
      exit 1
      ;;
  esac
done


#####################################
# FACES
#####################################

face="$CHEEK_LEFT$EYE$MOUTH$EYE$CHEEK_RIGHT"
faceRight="$CHEEK_LEFT ${face:$(strlen "$CHEEK_LEFT")}"
faceLeft="${face%%$CHEEK_RIGHT*} $CHEEK_RIGHT"


#####################################
# TABLE
#####################################

tableLength=${TABLE_LENGTH:-"1"}

tableEndChar="┬"
tableMiddleChar="─"
tableMiddle=$(makeString "$tableMiddleChar" $tableLength)
table="$tableEndChar$tableMiddle$tableEndChar"

flippedTableEndChar="┻"
flippedTableMiddleChar="─"
flippedTableMiddle=$(makeString "$flippedTableMiddleChar" $tableLength)
tableFlipped="$flippedTableEndChar$flippedTableMiddle$flippedTableEndChar"

faceRightArms="$CHEEK_LEFT$FLIP_ARM${face:$(strlen "$CHEEK_LEFT")} $FLIP_ARM"
flipTableRight="$faceRightArms$MOTION$tableFlipped"


#####################################
# DEFAULTS / GLOBALS
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

############################################################################
# table.sh                                                     $flipTableRight
############################################################################

Everybody's favorite table flipper, lightly animated

Options:
  -f, --fps           [int]            change the running speed (default 60)
  -h, --help                           display this help

Actors:
  --actor             [actor]         choose a specific actor
    actors: $(echo "$actors" | sed 's/ /, /g')

Actor Options:
  -e,  --eye          [char(s)]        customize flip's eyes
  -m,  --mouth        [char(s)]        customize flip's mouth
  -cl, --cheek-left   [char(s)]        customize flip's left cheek
  -cr, --cheek-right  [char(s)]        customize flip's right cheek
  -a,  --arm          [char(s)]        customize flip's flippin' arms
  -M,  --motion       [char(s)]        customize the table flippin' motion

Table Options:
  -t, --table-length  [int]            change the length of the table

Scene Options:
  --scan                               run the scan scene
EOF
}


#####################################
# MOVEMENT
#####################################

function enterLeft() {
  local actor="$1"
  local y=${2:-"$middleY"}
  local waitFor=${3:-"$delay"}
  for ((i=0; i < $((${#actor} - 1)); i++)); do
    tput cup $y 0
    echo "${actor: ((0 - i - 1))}"
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
  local toActual=$(($to - $(strlen "$actor")))
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
  local length=${#actor}
  local firstChar="${actor:0:1}"
  local squeegie=$(empty "$firstChar")
  local extraDisplayChars=$(($(strlen "$actor") - ${#actor}))
  for ((i=0; i < $length; i++)); do
    actor="${actor:0:$((length - i - 1))}"
    local toDraw="$squeegie$actor"
    tput cup $y $((cols - ${#toDraw} - $extraDisplayChars))
    echo "$toDraw"
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
  local length=${#actor}
  for ((i=1; i < $length; i++)); do
    local partial="${actor:0:$i}"
    tput cup $y $((cols - $(strlen "$partial")))
    echo "$partial"
    sleep $waitFor
  done
}

function moveLeft() {
  local actor="$1"
  local from=${2:-$((cols - $(strlen "$actor")))}
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
  local lastChar="${actor: -1}"
  local squeegie=$(empty "$lastChar")
  local length=${#actor}
  for ((i = 0; i < "$length"; i++)); do
    tput cup $y 0
    actor="${actor:1}$squeegie"
    echo "$actor"
    sleep $waitFor
  done
}

function scanLeft() {
  local actor="$1"
  local y=${2:-"$middleY"}
  local waitFor=${3:-"$delay"}
  enterRight "$actor" $y $waitFor
  moveLeft "$actor" $((cols - $(strlen "$actor"))) 0 $y $waitFor
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
  local actorStart=$((tableStart - $(strlen "$faceRight")))
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
  tput cup $middleY $((actorStart + $(strlen "$faceRightArms")))
  empty "$MOTION"
  sleep 0.5
  tput cup $middleY $actorStart
  empty "$faceRightArms"
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

