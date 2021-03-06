Function before_exit() {
  echo "__SH__SCRIPT_END_SUCCESS__";
}

Function exec_cmd([string]$cmd) {
  $cmd_uuid = [guid]::NewGuid().Guid
  $cmd_start_timestamp = Get-Date -format "%s"
  Write-Output "__SH__CMD__START__|{`"type`":`"cmd`",`"sequenceNumber`":`"$cmd_start_timestamp`",`"id`":`"$cmd_uuid`"}|$cmd"

  # TODO: export current_cmd and current_cmd_uuid

  Invoke-Expression $cmd

  # TODO: unset current_grp and current_grp_uuid

  # TODO: Get the real exit code from the command and set group_status
  $cmd_status = 0

  $cmd_end_timestamp = Get-Date -format "%s"
  Write-Output ""
  Write-Output "__SH__CMD__END__|{`"type`":`"cmd`",`"sequenceNumber`":`"$cmd_end_timestamp`",`"id`":`"$cmd_uuid`",`"exitcode`":`"$cmd_status`"}|$cmd"
}

Function exec_grp([string]$group_name, [string]$group_message,[Bool]$is_shown = $TRUE) {
  if (-not ($group_message)) {
    group_message=$group_name
  }

  $group_uuid = [guid]::NewGuid().Guid
  # TODO: migrate to unix time if this does not work
  $group_start_timestamp = Get-Date -format "%s"
  Write-Output ""
  Write-Output "__SH__GROUP__START__|{`"type`":`"grp`",`"sequenceNumber`":`"$group_start_timestamp`",`"id`":`"$group_uuid`",`"is_shown`":`"$is_shown`"}|$group_message"

  # TODO: export current_grp and current_grp_uuid

  Invoke-Expression $group_name

  # TODO: unset current_grp and current_grp_uuid

  # TODO: Get the real exit code from the command and set group_status
  $group_status = 0

  # TODO: migrate to unix time if this does not work
  $group_end_timestamp = Get-Date -format "%s"
  Write-Output "__SH__GROUP__END__|{`"type`":`"grp`",`"sequenceNumber`":`"$group_end_timestamp`",`"id`":`"$group_uuid`",`"is_shown`":`"$is_shown`",`"exitcode`":`"$group_status`"}|$group_message"
}
