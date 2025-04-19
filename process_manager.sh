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
    if [[ "$process_identifier" =~ ^[0-9]+$ ]]; then
      echo "Error: Process with PID '$pid' is not running or does not exist."
    else
      echo "Error: Process '$process_identifier' (PID: $pid) is not running or does not exist."
    fi
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
    if [[ "$process_identifier" =~ ^[0-9]+$ ]]; then
      echo "Error: Process with PID '$pid' is not running or does not exist."
    else
      echo "Error: Process '$process_identifier' (PID: $pid) is not running or does not exist."
    fi
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
    if [[ "$process_identifier" =~ ^[0-9]+$ ]]; then
      echo "Error: Process with PID '$pid' is not running or does not exist."
    else
      echo "Error: Process '$process_identifier' (PID: $pid) is not running or does not exist."
    fi
  fi
}

# Interactive menu
while true; do
  echo ""
  echo "Process Manager Menu:"
  echo "1. Start a process"
  echo "2. List processes"
  echo "3. Stop a process"
  echo "4. Kill a process"
  echo "5. Terminate a process"
  echo "6. Exit"
  read -p "Select an option (1-6): " choice

  case "$choice" in
    1)
      read -p "Enter command to run: " command
      read -p "Enter process name: " process_name
      start_process "$command" "$process_name"
      ;;
    2)
      list_processes
      ;;
    3)
      read -p "Enter process name or PID to stop: " process_identifier
      stop_process "$process_identifier"
      ;;
    4)
      read -p "Enter process name or PID to kill: " process_identifier
      kill_process "$process_identifier"
      ;;
    5)
      read -p "Enter process name or PID to terminate: " process_identifier
      terminate_process "$process_identifier"
      ;;
    6)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option. Please select a number between 1 and 6."
      ;;
  esac
done

exit 0