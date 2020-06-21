#!/bin/bash -x

# FUNCTIONS
function format_time() {
  # Returns seconds to [[[[d and ]hh:]mm:]ss | ss 's'] format
  # I.e.: format_seconds 1000000 -> 11 days and 13:46:40
  local s=$1
  ((s >= 86400)) && printf '%d days and ' $((s / 86400)) # days
  ((s >= 3600)) && printf '%02d:' $((s / 3600 % 24))     # hours
  ((s >= 60)) && printf '%02d:' $((s / 60 % 60))         # minutes
  printf '%02d%s\n' $((s % 60)) "$( ((s < 60 )) && echo ' s.' || echo '')"
}

function printr() {
  # Print array line refreshing one line in array period of time
  # Usage: printr "countdowmn: 5" 2
  local string=$1 interval=$2
  echo "$string"
  sleep "$interval"
  tput cuu1 # mueve el cursor una línea arriba
  tput el   # clear the line
}

function isnumber() {
  (($1)) 2>/dev/null
}

function verify() {
  ! "$1" "$2" >/dev/null
  if ((PIPESTATUS[0] != 0)); then
    echo "${PIPESTATUS[0]}"
    echo "$1 failed or missing"
    exit 1
  fi
}


function time_parser() {
  local unit=${1: -1}
  local value=${1:0:-1}
  #declare -i seconds
  if ! isnumber value; then
    echo "Error: Invalid unit time"
    exit 1
  fi

  case $unit in
    s) seconds="$value" ;;
    m) seconds=$((value * 60)); ;;
    h) seconds=$((value * 3600)) ;;
    d) seconds=$((value * 86400)) ;;
    *)
    echo "Error: Invalid unit time. Use s, m, h or d"
    exit 1
    ;;
  esac
}

# VERIFYING DEPENDENCIES
verify systemctl is-system-running
verify tput -V
verify getopt -V

# PARAMS PARSING
action=poweroff
exc1=0

OPTIONS=rshyt:
LONGOPTIONS=reboot,suspend,hibernate,hybrid-sleep,contdown:

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")

if ((PIPESTATUS[0] != 0)); then
  echo "Error: Invalid parameter"
  echo mecawendios este es el uso
  exit 1
fi

eval set -- "$PARSED"

while true; do
    case $1 in
      -r | --reboot)       action=reboot;       ((exc1++)); shift;;
      -s | --suspend)      action=suspend;      ((exc1++)); shift;;
      -h | --hibernate)    action=hibernate;    ((exc1++)); shift;;
      -y | --hybrid-sleep) action=hybrid-sleep; ((exc1++)); shift;;
      -t | --contdown)
        time="$2"
        shift 2;;
      --) shift ; break ;;
      *) echo "Programing Error"; exit 1;;
    esac
done

if (($# != 1)); then
    time=30s
fi

if ((exc1 > 1)); then
  echo "Error: -h, -i and -s are mutually exclusive and may only be used once" >&2
  exit 1
fi

echo "PARSED $PARSED"

############################
time_parser "$time"
total_seconds=$((EPOCHSECONDS + seconds))

echo "Scheduled $action: $(date -d @"$total_seconds")"

while (("$total_seconds" >= "$EPOCHSECONDS")); do
  r=$((total_seconds - EPOCHSECONDS))
  printr "$action in: $(format_time $r)" 1
done

echo systemctl $action -i
