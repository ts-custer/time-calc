#!/bin/bash


#
# Usage: time_calc.sh  [HH,MM  [HH,MM  [HH,MM...]]]
#
# This script prints out the sum of the entered times.
#


function print_display_time()
{
  if [ "${minutes}" -lt 0 ]
  then
    local min=$(( ${minutes} * -1 ))
  else
    local min=${minutes}
  fi

  local display_hours=$(( min / 60 ))
  local display_minutes=$(( min % 60 ))

  if [ ${display_minutes} -lt 10 ]
  then
    display_minutes="0${display_minutes}"
  else
    display_minutes="${display_minutes}"
  fi

  if [ "${minutes}" -lt 0 ]
  then
    echo "SUM= -${display_hours}:${display_minutes}"
  else
    echo "SUM= ${display_hours}:${display_minutes}"
  fi
}

function is_integer_number()
{
  case ${1} in
    ''|*[!0-9]*)
      echo 0
      ;;
    *)
      echo 1
      ;;
  esac
}

function parse()
{
  local input="${1}"

  if [[ ! "$input" == *","* ]]
  then
    echo "Wrong input \"${1}\". Delimiter ',' is missing!"
    return
  fi

  local sign="+"
  if [[ "$input" == "-"* ]]
  then
    input="${input##-}"
    sign="-"
  fi

  local hours_to_add=$(echo "${input}" | cut -d',' -f 1)
  local minutes_to_add=$(echo "${input}" | cut -d',' -f 2)

  if [ ${#minutes_to_add} -ne 2 ]
  then
    echo "Wrong input \"${1}\". 'MM' part must consist of two digits!"
    return
  fi

  if [ $(is_integer_number "${hours_to_add}") -ne 1 ]
  then
    echo "Wrong input \"${1}\". 'HH' part is not an integer number!"
    return
  fi

  if [ $(is_integer_number "${minutes_to_add}") -ne 1 ]
  then
    echo "Wrong input \"${1}\". 'MM' part is not an integer number!"
    return
  fi

  if [ "${minutes_to_add}" -ge 60 ]
  then
    echo "Wrong input \"${1}\". Maximal value of 'MM' is 59!"
    return
  fi

  # remove the leading zeros of hours_to_add and minutes_to_add
  hours_to_add="${hours_to_add#"${hours_to_add%%[!0]*}"}"
  minutes_to_add="${minutes_to_add#"${minutes_to_add%%[!0]*}"}"

  if [[ ${#hours_to_add} -eq 0 ]]
  then
    hours_to_add=0
  fi

  if [[ ${#minutes_to_add} -eq 0 ]]
  then
    minutes_to_add=0
  fi

  echo "${sign}_${hours_to_add}_${minutes_to_add}"
}


function add_input()
{
  local sign_hours_minutes=$(parse "${1}")

  if [[ ! "$sign_hours_minutes" == *"_"* ]]
  then
    echo "${sign_hours_minutes}"
    return
  fi

  local sign=$(echo "${sign_hours_minutes}" | cut -d'_' -f 1)
  local hours_to_add=$(echo "${sign_hours_minutes}" | cut -d'_' -f 2)
  local minutes_to_add=$(echo "${sign_hours_minutes}" | cut -d'_' -f 3)

  if [[ "${sign}" == "+" ]]
  then
    minutes=$(( $minutes + ${hours_to_add} * 60 + ${minutes_to_add} ))
  else
    minutes=$(( $minutes - ${hours_to_add} * 60 - ${minutes_to_add} ))
  fi
}

minutes=0

for input in "${@}"
do
  add_input "${input}"
done

print_display_time

while true; do
  echo -n "Input of HH,MM:  "
  read -r input
  add_input "${input}"
  print_display_time
done
