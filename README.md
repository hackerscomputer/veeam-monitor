# veeam-monitor
Build to monitor Veeam Endpoint/Agent event with Atera/IT Automation/Threshold

Read last Veeam Endpoint/Agent event, process and generate new, single, event on "Veeam Monitor" Event folder. 

For example run "veeam-monitor.exe 3" generate:
  "Info" "Last Backup: xxx hour/day ago"
if Backup is not older then 3 day otherwise it generate 
  "Error" "Last Backup: xxx hour/day ago"

It also handle some warning and error and no backup information

It also return same information as script output to handle in report view

Inside "Veeam Monitor" Event Folder there is always one single event

Atera: Run script with X day parameter in IT Automation, then set in Threshold Profiles
   Create critical alert for Veeam Monitor/900 event source
   Create warning alert for Veeam Monitor/900 event source
