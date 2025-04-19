#!/bin/bash

# process_manager.sh - A simple process manager script

# Associative array to store process information (PID and command)
declare -A processes

# Function to start a new process
start_process() {
  local command="$1"
  local process_name="$2"
  if [[ -z "$command" ]] || [[ -z "$process_name" ]]; then
    echo "Error: start_process requires a command and a process name."
    return 1
  fi
  eval "$command &"
  local pid=$!
  processes["$process_name"]="$pid:$command"
  echo "Started process '$process_name' with PID $pid"
}

# Function to list managed processes
list_processes() {
  if [[ ${#processes[@]} -eq 0 ]]; then
      echo "No managed processes."
      return
  fi
  echo "Managed Processes:"
  for process_name in "${!processes[@]}"; do
    local pid=$(echo "${processes[$process_name]}" | cut -d ':' -f 1)
    local command=$(echo "${processes[$process_name]}" | cut -d ':' -f 2-)
    echo "  Name: $process_name, PID: $pid, Command: $command"
  done
}

# Function to stop a process (SIGTERM)
stop_process() {
  local process_identifier="$1"
  local pid=""
  if [[ -z "$process_identifier" ]]; then
    echo "Error: stop_process requires a process name or PID."
    return 1
  fi
  if [[ "$process_identifier" =~ ^[0-9]+$ ]]; then
    pid="$process_identifier"
  else
    if [[ -n "${processes[$process_identifier]}" ]]; then
        pid=$(echo "${processes[$process_identifier]}" | cut -d ':' -f 1)
    else
        echo "Error: Process name '$process_identifier' not found."
        return 1
    fi
  fi

  if [[ -z "$pid" ]]; then
      echo "Error: Could not get PID for process $process_identifier"
      return 1
  fi
  
  if kill -0 "$pid" 2>/dev/null; then
    kill -s SIGTERM "$pid"
    echo "Sent SIGTERM to process $process_identifier (PID: $pid)"
  else
      echo "Error: Process $process_identifier (PID: $pid) not running or not found"
  fi

}

# Function to kill a process (SIGKILL)
kill_process() {
  local process_identifier="$1"
  local pid=""
  if [[ -z "$process_identifier" ]]; then
    echo "Error: kill_process requires a process name or PID."
    return 1
  fi

  if [[ "$process_identifier" =~ ^[0-9]+$ ]]; then
    pid="$process_identifier"
  else
      if [[ -n "${processes[$process_identifier]}" ]]; then
          pid=$(echo "${processes[$process_identifier]}" | cut -d ':' -f 1)
      else
          echo "Error: Process name '$process_identifier' not found."
          return 1
      fi
  fi

  if [[ -z "$pid" ]]; then
      echo "Error: Could not get PID for process $process_identifier"
      return 1
  fi

  if kill -0 "$pid" 2>/dev/null; then
      kill -s SIGKILL "$pid"
      echo "Sent SIGKILL to process $process_identifier (PID: $pid)"
  else
      echo "Error: Process $process_identifier (PID: $pid) not running or not found"
  fi
}

# Function to terminate a process (SIGINT)
terminate_process() {
  local process_identifier="$1"
  local pid=""

    if [[ -z "$process_identifier" ]]; then
    echo "Error: terminate_process requires a process name or PID."
    return 1
  fi
  if [[ "$process_identifier" =~ ^[0-9]+$ ]]; then
    pid="$process_identifier"
  else
      if [[ -n "${processes[$process_identifier]}" ]]; then
          pid=$(echo "${processes[$process_identifier]}" | cut -d ':' -f 1)
      else
          echo "Error: Process name '$process_identifier' not found."
          return 1
      fi
  fi

  if [[ -z "$pid" ]]; then
      echo "Error: Could not get PID for process $process_identifier"
      return 1
  fi
  
  if kill -0 "$pid" 2>/dev/null; then
        kill -s SIGINT "$pid"
        echo "Sent SIGINT to process $process_identifier (PID: $pid)"
  else
        echo "Error: Process $process_identifier (PID: $pid) not running or not found"
  fi
}

# Main script logic
case "$1" in
  start)
    start_process "$2" "$3"
    ;;
  list)
    list_processes
    ;;
  stop)
    stop_process "$2"
    ;;
  kill)
    kill_process "$2"
    ;;
  terminate)
    terminate_process "$2"
    ;;
  *)
    echo "Usage: $0 {start <command> <process_name> | list | stop <process_name_or_pid> | kill <process_name_or_pid> | terminate <process_name_or_pid>}"
    exit 1
    ;;
esac

exit 0