#!/bin/bash -e

######################## HEADER SECTION ################################
#
# Prints the command start and end markers with timestamps
# and executes the supplied command
#

before_exit() {
  ## flush any remaining console
  echo $1
  echo $2

  if [ -n "$current_cmd_uuid" ]; then
    current_timestamp=`date +"%s"`
    echo "__SH__CMD__END__|{\"type\":\"cmd\",\"sequenceNumber\":\"$current_timestamp\",\"id\":\"$current_cmd_uuid\",\"exitcode\":\"1\"}|$current_cmd"
  fi

  if [ -n "$current_grp_uuid" ]; then
    current_timestamp=`date +"%s"`
    echo "__SH__GROUP__END__|{\"type\":\"grp\",\"sequenceNumber\":\"$current_timestamp\",\"id\":\"$current_grp_uuid\",\"is_shown\":\"false\",\"exitcode\":\"1\"}|$current_grp"
  fi

  if [ "$is_success" == true ]; then
    echo "__SH__SCRIPT_END_SUCCESS__";
  else
    echo "__SH__SCRIPT_END_FAILURE__";
  fi
}

exec_cmd() {
  cmd=$@
  cmd_uuid=$(cat /proc/sys/kernel/random/uuid)
  cmd_start_timestamp=`date +"%s"`
  echo "__SH__CMD__START__|{\"type\":\"cmd\",\"sequenceNumber\":\"$cmd_start_timestamp\",\"id\":\"$cmd_uuid\"}|$cmd"

  export current_cmd=$cmd
  export current_cmd_uuid=$cmd_uuid

  eval "$cmd"
  cmd_status=$?

  unset current_cmd
  unset current_cmd_uuid

  if [ "$2" ]; then
    echo $2;
  fi

  cmd_end_timestamp=`date +"%s"`
  # If cmd output has no newline at end, marker parsing
  # would break. Hence force a newline before the marker.
  echo ""
  echo "__SH__CMD__END__|{\"type\":\"cmd\",\"sequenceNumber\":\"$cmd_start_timestamp\",\"id\":\"$cmd_uuid\",\"exitcode\":\"$cmd_status\"}|$cmd"
  return $cmd_status
}

exec_grp() {
  # first argument is function to execute
  # second argument is function description to be shown
  # third argument is whether the group should be shown or not
  group_name=$1
  group_message=$2
  is_shown=true
  if [ ! -z "$3" ]; then
    is_shown=$3
  fi

  if [ -z "$group_message" ]; then
    group_message=$group_name
  fi
  group_uuid=$(cat /proc/sys/kernel/random/uuid)
  group_start_timestamp=`date +"%s"`
  echo ""
  echo "__SH__GROUP__START__|{\"type\":\"grp\",\"sequenceNumber\":\"$group_start_timestamp\",\"id\":\"$group_uuid\",\"is_shown\":\"$is_shown\"}|$group_message"
  group_status=0

  export current_grp=$group_message
  export current_grp_uuid=$group_uuid

  {
    eval "$group_name"
  } || {
    group_status=1
  }

  unset current_grp
  unset current_grp_uuid

  group_end_timestamp=`date +"%s"`
  echo "__SH__GROUP__END__|{\"type\":\"grp\",\"sequenceNumber\":\"$group_end_timestamp\",\"id\":\"$group_uuid\",\"is_shown\":\"$is_shown\",\"exitcode\":\"$group_status\"}|$group_message"
  return $group_status
}

######################## END HEADER SECTION ###########################