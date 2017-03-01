# veeam-monitor
Build to monitor Veeam Endpoint/Agent event with Atera and IT Automation

Read last Veeam Endpoint/Agent event, process and generate new, single, event on "Veeam Monitor" Event folder. 

For example run "veeam-monitor.exe 3" generate:
  "Info" "Last Backup: xxx hour/day ago"
if Backup is not older then 3 day otherwise it generate 
  "Error" "Last Backup: xxx hour/day ago"

It also handle some warning and error and no backup information

It also return same information as script output to handle in report view

Inside "Veeam Monitor" Event Folder there is always one single event
