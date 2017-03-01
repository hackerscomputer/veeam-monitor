# veeam-monitor
Create to Monitor Veeam Endpoint (Agent/Backup) Event with Atera:

Read last Veeam Endpoint Backup Event, process and generate new, single, event on "Veeam Monitor" Event Folder. 

For example run "veeam-monitor.exe 3" generate "Info" Event "Last Backup: xxx hour/day ago" if Backup is not older then 3 day otherwise it generate Error Event. It also handle some warning and error

Inside "Veeam Monitor" Event Folder there is always one single event

