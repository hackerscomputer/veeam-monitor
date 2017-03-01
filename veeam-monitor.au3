#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Res_Description=Veeam Monitor
#AutoIt3Wrapper_Res_Fileversion=1.0.0.17
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=Y
#AutoIt3Wrapper_Res_ProductVersion=1.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <EventLog.au3>
#include <GUIConstantsEx.au3>
#include <Constants.au3>
#include <Misc.au3>
#AutoIt3Wrapper_Change2CUI=Y

Global $g_idMemo, $text_message, $var_veeam = '1'
Local $veeam_msg = '', $veeam_status = 9, $veeam_date, $veeam_type

;====================================================================================
; Initialize Event Folder Veeam Monitor
;====================================================================================
RegWrite("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\EventLog\Veeam Monitor\Veeam Monitor", "CustomSource", "REG_DWORD", "1")
RegWrite("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\EventLog\Veeam Monitor\Veeam Monitor", "EventMessageFile", "REG_EXPAND_SZ", "%SystemRoot%\System32\EventCreate.exe")
RegWrite("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\EventLog\Veeam Monitor", "Sources", "REG_MULTI_SZ", "Veeam Monitor")
RegWrite("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\EventLog\Veeam Monitor", "File", "REG_EXPAND_SZ", "%SystemRoot%\system32\winevt\Logs\Veeam Monitor.evtx")
RegWrite("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\EventLog\Veeam Monitor", "Retention", "REG_DWORD", "0")
RegWrite("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\EventLog\Veeam Monitor", "MaxSize", "REG_DWORD", "524288")

;====================================================================================
;       command line parameters
;       $CmdLine[1] = $veeam_error = day after last successful backup result in error
;====================================================================================
Global $veeam_error = 1
If $CmdLine[0] <> 0 Then
	$veeam_error = $CmdLine[1]
EndIf

_Veeam()

;====================================================================================
;       Read Veeam Status
;       $veeam_status = 1 - ok, Backup Completed
;       $veeam_status = 2 - warning, Backup is running
;       $veeam_status = 3 - warning, Backup error!
;====================================================================================
Func _Veeam()
	Local $temp_value = ''
	If $var_veeam <> '' Then
		Local $veeam_msg = '', $veeam_status = 9, $veeam_date, $veeam_day,  $veeam_type
		;Leggi Log Backup
		Dim $Obj_WMIService = ObjGet('winmgmts:{impersonationLevel=impersonate}!\\' & @ComputerName & '\root\cimv2');
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Dim $Col_Items = $Obj_WMIService.ExecQuery("Select * from Win32_NTLogEvent "  _
                 & "Where Logfile = 'Veeam Endpoint Backup' OR Logfile = 'Veeam Agent'" )

			Local $Obj_Items
			For $Obj_Items In $Col_Items
				$veeam_date	= $Obj_Items.TimeGenerated
				$veeam_msg	= $Obj_Items.Message
				$veeam_type = $Obj_Items.EventType
				ExitLoop
			Next
		EndIf

		$veeam_day = _DateDiff('d', WMIDateStringToDate($veeam_date), _NowCalc())

		; EventType 1=Error, 2=Warning, 3=Information
		;
		Select
			; Error
			Case $veeam_type = 1
				; Error detail
				$aArray = StringRegExp($veeam_msg, 'Job details:[^\r\n]+', $STR_REGEXPARRAYFULLMATCH)
				If UBound($aArray) > 0 then
					For $i = 0 To UBound($aArray) - 1
						$text_message = $aArray[$i]
					Next
				Else
					$aArray = StringRegExp($veeam_msg, '[^\r\n]+with Failed', $STR_REGEXPARRAYFULLMATCH)
					If UBound($aArray) > 0 then
						For $i = 0 To UBound($aArray) - 1
							$text_message = $aArray[$i]
						Next
					Else
						$text_message = "Generic Failed"
					EndIf
				EndIf
				_CreateEventLog($veeam_type,900,@CRLF & $text_message)

			;Warning
			Case $veeam_type = 2
				; Warning detail
				$aArray = StringRegExp($veeam_msg, 'Job details:[^\r\n]+', $STR_REGEXPARRAYFULLMATCH)
				If UBound($aArray) > 0 then
					For $i = 0 To UBound($aArray) - 1
						$text_message = $aArray[$i]
					Next
				Else
					$aArray = StringRegExp($veeam_msg, '[^\r\n]+with Warning', $STR_REGEXPARRAYFULLMATCH)
					If UBound($aArray) > 0 then
						For $i = 0 To UBound($aArray) - 1
							$text_message = $aArray[$i]
						Next
					Else
						$text_message = "Generic Warning"
					EndIf
				EndIf
				_CreateEventLog($veeam_type,900,@CRLF & $text_message)

			;Information
			Case $veeam_type = 3
				If StringInStr($veeam_msg, "has been started") OR StringInStr($veeam_msg, "Restore point") Then
					$text_message = "Backup is running"
					_CreateEventLog($veeam_type,900,@CRLF & $text_message)
				Else
					If StringInStr($veeam_msg, "Success") Then
						$veeam_day = _DateDiff('h', WMIDateStringToDate($veeam_date), _NowCalc())
						if $veeam_day = 0 then $veeam_day = 1
						if $veeam_day < 24 Then
							$text_message = "Last Backup: "&$veeam_day&" hour ago"
							_CreateEventLog($veeam_type,900,@CRLF & $text_message)
						Else
							$veeam_day = round($veeam_day/24)
							$text_message = "Last Backup: "&$veeam_day&" day ago"
							If $veeam_day > $veeam_error Then
								_CreateEventLog(1,900,@CRLF & $text_message)
							Else
								_CreateEventLog($veeam_type,900,@CRLF & $text_message)
							EndIf
						EndIf
					Else
						_CreateEventLog(2,900,@CRLF & "No backup information")
					EndIf
				EndIf
		EndSelect
	EndIf
EndFunc



Func WMIDateStringToDate($dtmDate)    ; yyyy/mm/dd hh:mm:ss
    Return (StringLeft($dtmDate, 4) & "/" & StringMid($dtmDate, 5, 2) _
         & "/" & StringMid($dtmDate, 7, 2) & " " & StringMid($dtmDate, 9, 2) _
         & ":" & StringMid($dtmDate, 11, 2) & ":" & StringMid($dtmDate,13, 2))
EndFunc


; Create Event Log | 1=Error, 2=Warning, 4=Information
Func _CreateEventLog($Type,$EventID,$Desc)
	If $Type = 3 Then $Type = 4
	local $aEmpty[1] = [0]
	$hEventLog = _EventLog__Open("", "Veeam Monitor")
	_EventLog__Clear($hEventLog, "")
	_EventLog__Report($hEventLog, $Type, 0, $EventID, 0,StringReplace(StringReplace($Desc,@CRLF,""),"|",""), $aEmpty)
	_EventLog__Close($hEventLog)
	ConsoleWrite(StringReplace($Desc,@CRLF,"")&@CRLF)
EndFunc
