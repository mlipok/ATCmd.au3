#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

#include "ATCmd.au3"

Global Const $g_sDeviceName = "COM2"
Global Const $_sPIN = "0000"
Global Const $_sPhoneNumber = "+48XXXYYYZZZ"

;~ tested with ZTE MF631 - works well.
;~ tested with LC SIM800C V3 - works well.
;~ tested with HUAWEI E3131 - works well.
;~ tested with HUAWEI E176G - works well.
;~ tested with HUAWEI E369 - Issue: Retry connecting COM14 at 115200 with flow control enabled

;~ tested with HUAWEI E3372S-153 - I had Modem locked AT^CARDLOCK?    >>>>   ^CARDLOCK: 3,0,0  ::: https://m2msupport.net/m2msupport/atcardlock-card-lock-command/
;~ https://texby.com/unlock-codes/huawei/
;~ https://www.autoitscript.com/forum/topic/204097-sending-sms-using-a-usb-gsm-modem-lc-sim800c-v3-and-at-commands/
;~ https://m2msupport.net/m2msupport/at-command-to-enable-error-codes/
;~ https://iot-developer.thalesgroup.com/threads/cme-error-50-when-entering-pin-during-setting-new-modem

_Main()
Exit

Func _Main()
	_Initialization($_sPIN)
	If @error Then Exit

;~ 	$ATCmd_TestingMode = true
;~ 	$ATCmd_TestingMode = False
	_Example1_CheckStatuses()
	For $i = 1 To 1
		_Example2_SMS_Sender()
	Next
	_Example3_ListMessages() ; list messages

;~ 	_ATCmd_Disconnect() ; not needed as UDF uses: OnAutoItExitRegister(__ATCmd_ShutDown)

EndFunc   ;==>_Main

Func _Initialization($sPIN)
	_ATCmd_ErrorLog(_Example_Error_Log_Output)
	_ATCmd_FullLoging(_Example_Error_Log_Output)
	_ATCmd_FullLoging(True)

	Local $aCOMDevices = _ATCmd_ListDevices(False)
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)
	_ArrayDisplay($aCOMDevices, '$aCOMDevices #' & @ScriptLineNumber, "", 0,Default, "FriendlyName|COM port name|Availability")

	_ATCmd_UseUCS2(True)
;~ 	_ATCmd_UsePDU(True)

;~ 	_ATCmd_Connect($g_sDeviceName, $sPIN, 'baud=9600 parity=n data=8 dtr=hs rts=hs')
	_ATCmd_Connect($g_sDeviceName, $sPIN, '')
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

EndFunc   ;==>_Initialization

Func _Example1_CheckStatuses()
	Local $aTemp
	If Not _ATCmd_IsSIMInserted() Then
		_ArrayDisplay($aTemp, "1DArray Info : Test #" & @ScriptLineNumber)
		_ATCmd_ErrorLog(@ScriptLineNumber & ' - ' & _ATCmd_GetLastErrorMessageCR() & @CRLF)
	Else
		$aTemp = _ATCmd_GetAllStatus(True)
		_ArrayDisplay($aTemp, "2DArray Info : Test #" & @ScriptLineNumber)

		; CHECK All Networks
		$aTemp = _ATCmd_GetAllStatus(True, True)
		_ArrayDisplay($aTemp, "2DArray Info + All Networks : Test #" & @ScriptLineNumber)     ;this will check for all networks. It will take many seconds
	EndIf
EndFunc   ;==>_Example1_CheckStatuses

Func _Example2_SMS_Sender()
	_ATCmd_SMS_Sender($_sPhoneNumber, 'ąćęłńóśżźĄĆĘŁŃÓŚŻŹ')
	_ATCmd_ErrorLog(@ScriptLineNumber & '- LastErrorMesage - ' & _ATCmd_GetLastErrorMessageCR())
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

	_ATCmd_SMS_Sender($_sPhoneNumber', '_ATCmd UDF 😱 It Rocks 🤘!!!')
	_ATCmd_ErrorLog(@ScriptLineNumber & '- LastErrorMesage - ' & _ATCmd_GetLastErrorMessageCR())
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

EndFunc   ;==>_Example2_SMS_Sender

Func _Example3_ListMessages()
	Local $aListMessages = _ATCmd_SMS_ListMessages(300)
	_ArrayDisplay($aListMessages, "ListMessages", "", 0, Default, "Entire MESSAGE|<index>|<stat>|<oa/da>|<alpha>|<scts>|<tooa/toda>|<length>|<data>")
EndFunc   ;==>_Example3_ListMessages

Func _Example_Error_Log_Output($sData)
	; https://www.autoitscript.com/forum/topic/181796-consolewrite-only-outputting-asciiansi/?do=findComment&comment=1305658
	ConsoleWrite(BinaryToString(StringToBinary($sData, $SB_UTF8), $SB_ANSI) & @CRLF)
EndFunc   ;==>_Example_Error_Log_Output
