#!/bin/bash

usage="Usage: $(basename $0) [--path dirpath] [--mask maskfile] [--number number_cores] command"
if [ -z "$1" ]; then
   echo "$usage"
   exit 1
fi
dirpath=$(pwd)
mask="*"
number_cores=$(sysctl -n hw.ncpu)                        #  MacOS
#number_cores=$(grep processor /proc/cpuinfo | wc -l)    #  Linux
command=""
command_got=false
while (( "$#" )); do
  case "$1" in
    --path)
      if [ $command_got != "true" ]; then
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
          dirpath=$2
          shift 2
        else
          echo -e "Error: Argument for $1 is missing\n$usage" >&2
          exit 1
        fi
      else
        command="$command $1"
        shift
      fi
      ;;
    --mask)
      if [ $command_got != "true" ]; then
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
          mask=$2
          shift 2
        else
          echo -e "Error: Argument for $1 is missing\n$usage" >&2
          exit 1
        fi
      else
        command="$command $1"
        shift
      fi
      ;;
    --number)
      if [ $command_got != "true" ]; then
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
          number_cores=$2
          shift 2
        else
          echo -e "Error: Argument for $1 is missing\n$usage" >&2
          exit 1
        fi
      else
        command="$command $1"
        shift
      fi
      ;;
    -*|--*=)
      if [ $command_got != "true" ]; then
        echo -e"Error: Unsupported flag $1\n$usage" >&2
        exit 1
      else
        command="$command $1"
        shift
      fi
      ;;
    *) 
      if [ ! -z "$1" ]; then
        command="$command $1"
        command_got=true
        shift
      else
        if [ -z "$command" ]; then
          echo -e "Command is missing\n$usage" >&2
          exit 1
        fi
      fi
      ;;
  esac
done

echo "$command"
files=($(find "$dirpath" -maxdepth 1 -mindepth 1 -type f -name "$mask"))
files_size="${#files[@]}"
if [ "$files_size" -lt "$number_cores" ]; then
  for (( i = 0; i < files_size; i++ )); do
    echo "$command ${files[i]} &" | bash >> /dev/null
  done
else
  
  command_list=()
  comm_next=0
  for (( i = 0; i < "$files_size"; i++ )); do
    if [ -z "${command_list[$comm_next]}" ]; then
      command_list[$comm_next]="$command ${files[i]} "
    else
      command_list[$comm_next]="${command_list[$comm_next]} && $command ${files[i]} "
    fi
    if [ $comm_next -eq $((number_cores - 1)) ]; then
      comm_next=0
    else
      comm_next=$((comm_next+=1))
    fi
  done
  for (( i = 0; i < "${#command_list[@]}"; i++ )); do
    echo "${command_list[$i]} &" | bash >> /dev/null
  done
fi