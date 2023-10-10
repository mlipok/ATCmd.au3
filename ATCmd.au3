#include-once
#Region ; ATCmd.au3 - Header
; #INDEX# ========================================================================
; Title .........: ATCmd.au3 UDF
; AutoIt Version : 3.3.14.5
; Language ......: English
; Description ...: AT Command UDF - for control AT Modems, send SMS, get SMS
; Author ........: mLipok (manager, auxiliary developer), Danyfirex (prime developer)
; Modified ......:
; Date ..........: 2023/10/10
; Version .......: 1.2.1
; Remark ........: This UDF was created by Danyfirex toogether with mLipok at the turn of September and October 2020
; ================================================================================

#cs
	1.0.0
	2020/10/03
	.	First version - Danyfirex + mLipok

	1.0.1
	2020/10/04
	.	Added - Function - _ATCmd_IsPINReady - Danyfirex
	.	Added - Function - _ATCmd_IsPINRequired - Danyfirex
	.	Added - Function - _ATCmd_IsSIMInserted - Danyfirex
	.	Added - Function - _ATCmd_IsSenderSupported - Danyfirex
	.	Added - Function - _ATCmd_OnPINRequest - Danyfirex
	.	Added - Function - _ATCmd_SMS_ListTextMessages - Danyfirex
	.	Added - Function - _ATCmd_SetPIN - Danyfirex
	.	Added - Function - __ATCmd_GetPINCounter - Danyfirex
	-	Added - ENUM - $ATCmd_ERR_PIN - Danyfirex
	-	Added - ENUM - $ATCmd_ERR_SIM - Danyfirex
	.	Changed - __ATCmd_ComposePDU() - using _ATCmd_UseUCS2() internally instead parameter - Danyfirex
	.	Suplemented - #CURRENT# - Danyfirex
	.
	.
	1.0.2
	2020/10/05
	.	Added - ENUM - $ATCmd_MSGLIST_* - mLipok
	.	Added - ENUM - $ATCmd_STATUS__* - mLipok
	-	Added - ENUM - $ATCmd_ERR_PARAMETER - mLipok
	.	Added - _ATCmd_UsePDU() - parameter validation - mLipok
	.	Added - _ATCmd_UseUCS2() - parameter validation - mLipok
	.	Added - more error logs
	.	Changed - MagicNumber replaced with Standard UDF constants - mLipok
	.	Small refactoring - mLipok
	.
	.
	1.0.3
	2020/10/05
	.	CleanUp - Danyfirex
	.
	.
	1.0.4
	2020/10/05
	.	Small refactoring - Danyfirex
	.	CleanUp - Danyfirex
	.
	.
	1.0.5
	2020/10/23
	.	_ATCmd_FullLoging - mLipok
	.	_ATCmd_CMEESetup() ... @WIP - mLipok
	.	$ATCMD_STATUS_11_SUBSCRIBERNUMBER	- mLipok
	.
	.
	1.0.6
	2020/10/25
	.	__ATCmd_CMSErrorParser() - mLipok
	.
	1.2.1
	2023/10/10
	.	$ATCmd_ERR_COMMTIMEOUT - mLipok
	.	$ATCmd_CMGLPDU_* - parameters for _ATCmd_SMS_ListMessages() - mLipok
	.	$ATCmd_CMGLTEXT - list of parameters (an array) for _ATCmd_SMS_ListMessages() - mLipok
	.	$ATCmd_TestingMode - for developer testing - mLipok
	.
	.	__ATCmd_WaitResponse() - reports $ATCmd_ERR_COMMTIMEOUT - mLipok
	.	__ATCmd_WaitResponse() - reports $ATCmd_ERR_COMMERROR - mLipok
	.	__ATCmd_WaitResponse() - refactored for better TimeOut handling - mLipok
	.	__ATCmd_WaitResponse() - refactored for better Error handling - mLipok
	.	__ATCmd_WaitSuccess() - checks __ATCmd_LastSent() and uses _ATCmd_UsePDU() or _ATCmd_UseUCS2() accordingly - mLipok
	.	__ATCmd_UCS2HexToString() - mLipok
	.	__ATCmd_DefaultConfig() - USC2 support - mLipok
	.	_ATCmd_SMS_ListTextMessages() - renamed to: __ATCmd_SMS_ListMessagesToArray() - mLipok
	.	__ATCmd_SMS_ListMessagesToArray() - USC2 support - mLipok
	.
	.	_ATCmd_Connect() - refactored - mLipok
	.	_ATCmd_Connect() - $sPIN parameter added - mLipok
	.	_ATCmd_GetAllStatus() - small fixes - mLipok
	.	_ATCmd_Command() - support for $ATCmd_CTRL_Z - mLipok
	.	_ATCmd_SMS_Sender() - rafactorization - separation of: _ATCmd_UsePDU() and _ATCmd_UseUCS2() - mLipok
	.	_ATCmd_SMS_Sender() - USC2 support - mLipok
	.	_ATCmd_SMS_Sender() - better error handling - mLipok
	.	_ATCmd_SMS_Sender() - uses _ATCmd_Command() instead _COM_SendChar() to send $ATCmd_CTRL_Z - mLipok
	.	_ATCmd_CMEESetup() - removed as not used anymore - mLipok
	.	_ATCmd_CommandSyncOK() is mostly used instead _ATCmd_Command() - mLipok
	@LAST

	* Some resources:
	https://www.nowsms.com/gsm-modem-cms-error-code-list
	https://m2msupport.net/m2msupport/at-command-to-enable-error-codes/
	https://www.micromedia-int.com/en/gsm-2/73-gsm/669-cme-error-gsm-equipment-related-errors
	https://assets.nagios.com/downloads/nagiosxi/docs/ATCommandReference.pdf
	https://www.maritex.com.pl/product/attachment/40451/15b4db6d1a10eada42700f7293353776
	https://www.multitech.net/developer/wp-content/uploads/2010/10/S000463C.pdf
	https://www.telit.com/wp-content/uploads/2017/09/Telit_AT_Commands_Reference_Guide_r24_B.pdf
	https://docs.rs-online.com/5931/0900766b80bec52c.pdf
	https://www.etsi.org/deliver/etsi_ts/127000_127099/
	https://www.etsi.org/deliver/etsi_ts/127000_127099/127007/17.09.00_60/ts_127007v170900p.pdf

	* PDU Format / Testers / Encoders / decoders
	https://m2msupport.net/m2msupport/sms-at-commands/#pduformat
	http://smstools3.kekekasvi.com/topic.php?id=288

	* General note about your handling of AT commands:
	https://stackoverflow.com/questions/15588609/gsm-sm5100b-c-m-e-e-r-r-o-r-4-error/15591673#15591673
#ce

#TODO list
#cs
	1. check for incoming call
	2. disconnect incoming call
	3. send information to rejected incoming call
	4. call forwarding ; https://forum.arduino.cc/t/forwarding-call-by-using-at-command/344410   ; https://ozekisms.com/p_2707-ttransfer-calls-from-sim-card-to-another-phone-number.html
#ce

#EndRegion ; ATCmd.au3 - Header

#Region ; ATCmd.au3 - Options
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Tidy_Parameters=/sort_funcs /reel
#EndRegion ; ATCmd.au3 - Options

#Region ; ATCmd.au3 - Include
; standard include
#include <Array.au3>
#include <StringConstants.au3>

; additional include
#include "ComUDF.au3"
#EndRegion ; ATCmd.au3 - Include

; #CURRENT# =====================================================================================================================
; _ATCmd_Command
; _ATCmd_CommandSync
; _ATCmd_CommandSyncOK
; _ATCmd_Connect
; _ATCmd_Disconnect
; _ATCmd_ErrorLog
; _ATCmd_GetAllStatus
; _ATCmd_GetLastErrorMessage
; _ATCmd_GetLastErrorMessageCR
; _ATCmd_IsPINReady
; _ATCmd_IsPINRequired
; _ATCmd_IsSIMInserted
; _ATCmd_IsSenderSupported
; _ATCmd_ListDevices
; _ATCmd_OnPINRequest
; _ATCmd_SMS_ListMessages
; _ATCmd_SMS_Sender
; _ATCmd_SetPIN
; _ATCmd_UsePDU
; _ATCmd_UseUCS2
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __ATCmd_Bin2Dec
; __ATCmd_ComposePDU
; __ATCmd_DAToPDU
; __ATCmd_Dec2Bin
; __ATCmd_DefaultConfig
; __ATCmd_EncodePhoneNumber
; __ATCmd_GetCOMPortByDeviceName
; __ATCmd_GetPINCounter
; __ATCmd_Instance
; __ATCmd_LastResponse
; __ATCmd_LastSent
; __ATCmd_ShutDown
; __ATCmd_SMS_ListMessagesToArray
; __ATCmd_StringStripCRLFOK
; __ATCmd_StringTo7bitHex
; __ATCmd_StringToUCS2Hex
; __ATCmd_UCS2HexToString
; __ATCmd_WaitResponse
; __ATCmd_WaitSuccess
; ===============================================================================================================================

#Region ; ATCmd.au3 - Declarations
Global Enum _
		$ATCmd_ERR_SUCCESS, _
		$ATCmd_ERR_OPENPORT, _
		$ATCmd_ERR_NOTFOUND, _
		$ATCmd_ERR_NOTCOMPORTS, _
		$ATCmd_ERR_COMMAND, _
		$ATCmd_ERR_PIN, _
		$ATCmd_ERR_SIM, _
		$ATCmd_ERR_PARAMETER, _
		$ATCmd_ERR_COMMERROR, _
		$ATCmd_ERR_COMMTIMEOUT, _
		$ATCmd_ERR__COUNTER

Global Enum _
		$ATCmd_EXT_DEFAULT, _
		$ATCmd_EXT_WAITTIMEOUT

Global Enum _
		$ATCmd_RET_FAILURE, _
		$ATCmd_RET_SUCCESS

Global Enum _ ; __ATCmd_SMS_ListMessagesToArray()
		$ATCmd_MSGTEXT_00_FULL, _ ; Full single message information
		$ATCmd_MSGTEXT_01_IDX, _ ; <index>
		$ATCmd_MSGTEXT_02_STATUS, _ ; <stat>
		$ATCmd_MSGTEXT_03_ADDRESS, _ ; <oa/da>
		$ATCmd_MSGTEXT_04_NAME, _ ; <alpha>
		$ATCmd_MSGTEXT_05_DATE, _ ; <scts>
		$ATCmd_MSGTEXT_06_TYPE, _ ; <tooa/toda> - probably only in PDU mode
		$ATCmd_MSGTEXT_07_LENGTH, _ ; <length> - probably only in PDU mode
		$ATCmd_MSGTEXT_08_MESSAGE, _ ; <data>
		$ATCmd_MSGTEXT__COUNTER

Global Enum _ ; _ATCmd_GetAllStatus()
		$ATCmd_STATUS_00_MANUFACTURER, _ ; Manufacturer name
		$ATCmd_STATUS_01_MODELNAME, _ ;  Model name
		$ATCmd_STATUS_02_SERIALNUMBER, _ ; Product Serial Number
		$ATCmd_STATUS_03_SIM, _ ; SIM card status
		$ATCmd_STATUS_04_PIN, _ ; PIN code status
		$ATCmd_STATUS_05_PINLATTLEFT, _ ; PIN Attempts Left
		$ATCmd_STATUS_06_NETWORKREGSTATUS, _ ; Network Registration Status
		$ATCmd_STATUS_07_OPERATORSELECTION, _ ; Operator Selection
		$ATCmd_STATUS_08_SIGNALSTRENGTH, _ ; Signal Strength
		$ATCmd_STATUS_09_OPERATORLIST, _ ; Operators List
		$ATCmd_STATUS_10_SENDERSUPPORTED, _ ; Sender Supported
		$ATCMD_STATUS_11_SUBSCRIBERNUMBER, _ ; Subscriber Number i.e. the phone number of the device that is stored in the SIM card.
		$ATCmd_STATUS__COUNTER

Global Enum _ ; _ATCmd_SMS_ListMessages()
		$ATCmd_CMGLPDU_UNREAD, _ ; “REC UNREAD” 0 received unread messages
		$ATCmd_CMGLPDU_READ, _ ; “REC READ” 1 received read messages
		$ATCmd_CMGLPDU_UNSENT, _ ; “STO UNSENT” 2 stored unsent messages
		$ATCmd_CMGLPDU_SENT, _ ; “STO SENT” 3 stored sent messages
		$ATCmd_CMGLPDU_ALL, _ ; “ALL” 4 all messages
		$ATCmd_CMGLPDU__COUNTER

Global Const _ ; _ATCmd_SMS_ListMessages()
		$ATCmd_CMGLTEXT[$ATCmd_CMGLPDU__COUNTER] = _
		['"REC UNREAD"', '"REC READ"', '"STO UNSENT"', '"STO SENT"', '"ALL"']

Global Const $ATCmd_CTRL_Z = Chr(26) ; To send the message issue Ctrl-Z char (0x1A hex)

Global $ATCmd_TestingMode = False
If $ATCmd_TestingMode Then ConsoleWrite("-ATCmd- " & @ScriptLineNumber & @CRLF)

#EndRegion ; ATCmd.au3 - Declarations

OnAutoItExitRegister(__ATCmd_ShutDown)

#Region ; ATCmd.au3 - Functions #CURRENT#

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_Command
; Description ...: Send string AT Command
; Syntax ........: _ATCmd_Command($sATCommand)
; Parameters ....: $sATCommand          - a string value.
; Return values .: Success      - $ATCmd_RET_SUCCESS
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........: https://www.groundcontrol.com/AT_Command_Reference_5_9_1_3.htm#AT_plusCMGL
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_Command($sATCommand)
	__ATCmd_LastSent($sATCommand)
	If $sATCommand = $ATCmd_CTRL_Z Then
		_COM_SendChar(__ATCmd_Instance(), $ATCmd_CTRL_Z)
	Else
		_COM_SendString(__ATCmd_Instance(), $sATCommand)
	EndIf

	_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: _ATCmd_Command')
	If @error Then SetError($ATCmd_ERR_COMMAND, @extended, $ATCmd_RET_FAILURE)
	Return SetError(@error, @extended, $ATCmd_RET_SUCCESS)
EndFunc   ;==>_ATCmd_Command

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_CommandSync
; Description ...: Send string AT Command and wait for any response $sBuffer>2
; Syntax ........: _ATCmd_CommandSync($sATCommand)
; Parameters ....: $sATCommand          - a string value.
;                  $iMaxWaitTimeSeconds - [optional] an integer value. Default is 15.
; Return values .: Success      - Response text from device
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:  _ATCmd_Command, __ATCmd_WaitResponse
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_CommandSync($sATCommand, $iMaxWaitTimeSeconds = 15)
	_ATCmd_Command($sATCommand)

	Local $sATResponse = __ATCmd_WaitResponse($iMaxWaitTimeSeconds)
	_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: _ATCmd_CommandSync - ' & _ATCmd_GetLastErrorMessageCR())
	Return SetError(@error, @extended, $sATResponse)
EndFunc   ;==>_ATCmd_CommandSync

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_CommandSyncOK
; Description ...: Send string AT Command and wait for "OK" response
; Syntax ........: _ATCmd_CommandSyncOK($sATCommand)
; Parameters ....: $sATCommand          - a string value.
;                  $iMaxWaitTimeSeconds - [optional] an integer value. Default is 15.
; Return values .: Success      - Response text from device
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......: _ATCmd_Command, __ATCmd_WaitSuccess
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_CommandSyncOK($sATCommand, $iMaxWaitTimeSeconds = 15)
	_ATCmd_Command($sATCommand)
	Local $sATResponse = __ATCmd_WaitSuccess("OK", $iMaxWaitTimeSeconds)
	_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: _ATCmd_CommandSyncOK - ' & _ATCmd_GetLastErrorMessageCR())
	Return SetError(@error, @extended, $sATResponse)
EndFunc   ;==>_ATCmd_CommandSyncOK

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_Connect
; Description ...: Connect to COM Device by COM Index or Device Name
; Syntax ........: _ATCmd_Connect($sCOMPort_DeviceName[, $sPIN = ''])
; Parameters ....: $sCOMPort_DeviceName - a string value.
;                  $sPIN                - [optional] a string value. Default is ''.
; Return values .: Success      - $ATCmd_RET_SUCCESS
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_Connect($sCOMPort_DeviceName, $sPIN = '', $sCOMPortSettings = '')
	_ATCmd_Disconnect()
	Local $sCOMPort = $sCOMPort_DeviceName
	If Not StringRegExp($sCOMPort, 'COM\d{1,3}$') Then $sCOMPort = __ATCmd_GetCOMPortByDeviceName($sCOMPort_DeviceName)

	#TODO check if instace is already saved

	$sCOMPort = $sCOMPort & ($sCOMPortSettings ? " " & $sCOMPortSettings : "")
	_ATCmd_FullLoging('- CONNECTING: ' & $sCOMPort)
	Local $hCOMPort = _COM_OpenPort($sCOMPort)
	_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: Unable to Open Port: ' & $sCOMPort)
	If @error Then Return SetError($ATCmd_ERR_OPENPORT, @extended, $ATCmd_RET_FAILURE)

	__ATCmd_Instance($hCOMPort) ; save COM instance

 	_COM_SetTimeouts($hCOMPort)

;~ 	_ATCmd_CommandSync('ATQ0V1E0' & @CR) ; ATQ0 + ATE0

	#REMARK do not use _ATCmd_CommandSyncOK('ATE0' & @CR) as it will get additional responses from device
	_ATCmd_Command('ATE0' & @CR) ; avoid device's echo for each command sent
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

	_ATCmd_Command('AT^CURC=0' & @CR) ; turn off periodic status messages
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

	_ATCmd_CommandSyncOK('ATQ0' & @CR, 15) ; enables result codes (factory default)
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

	_ATCmd_CommandSyncOK('ATV1' & @CR, 15) ; full headers and trailers and verbose format of result codes (factory default)
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

	_ATCmd_CommandSyncOK('AT+CMEE=2' & @CR) ; Report Mobile Equipment Error ; 2 - enable +CME ERROR: <err> reports, with <err> in verbose format
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

	#TODO revise
;~ 	_ATCmd_CommandSync('AT#SELINT=?' & @CR, 60) ; Test command reports the available range of values for parameter
;~ 	MsgBox($MB_TOPMOST, "TEST", @ScriptLineNumber)
;~ 	_ATCmd_CommandSync('AT#SELINT?' & @CR, 60) ; Read command reports the current interface style.
;~ 	MsgBox($MB_TOPMOST, "TEST", @ScriptLineNumber)

	; Select Active Service Class
	#CS
	Parameter:
	<n>
	0 - data
	1 - fax class 1
	8 - voice
	#CE
	_ATCmd_CommandSync('AT+FCLASS=?' & @CR, 60) ; Test command returns all supported values of the parameters <n>.
	_ATCmd_CommandSync('AT+FCLASS?' & @CR, 60) ; Read command returns the current configuration value of the parameter <n>.

	_ATCmd_CommandSyncOK('AT+GMM' & @CR) ; Model Identification
	_ATCmd_CommandSyncOK('AT+GMR' & @CR) ; Revision Identification
	_ATCmd_CommandSyncOK('AT+GCAP' & @CR) ; Capabilities List
;~ 	_ATCmd_CommandSync('AT%L' & @CR) ; Line Signal Level ; Line land modem
;~ 	_ATCmd_CommandSync('AT%Q' & @CR) ; Line Quality ; Line land modem
	_ATCmd_CommandSyncOK('AT+CREG?' & @CR) ; Checking registration status...
	_ATCmd_CommandSyncOK('AT+CREG=0' & @CR) ; disable network registration unsolicited result code (factory default)
	_ATCmd_CommandSyncOK('AT+CGREG?' & @CR) ; Checking registration status...
	_ATCmd_CommandSyncOK('AT+CGREG=0' & @CR) ; disable network registration unsolicited result code
	_ATCmd_CommandSyncOK('AT+CSCA?' & @CR) ; Checking Service Center Address
	_ATCmd_CommandSyncOK('AT+CMGF?' & @CR) ; Checking SMS Mode...

;~ 	MsgBox($MB_OK + $MB_TOPMOST + $MB_ICONINFORMATION, 'after AT+GMM', _ATCmd_GetLastErrorMessageCR())
	If Not _ATCmd_IsSIMInserted() Then
		#TODO ????
	Else
		If _ATCmd_IsPINRequired() Then
			If $sPIN Then
				_ATCmd_SetPIN($sPIN)
			Else
				_ATCmd_OnPINRequest()
			EndIf
		EndIf

		If _ATCmd_IsPINReady() Then
			__ATCmd_DefaultConfig()     ; try set default setting if PIN is ready
		EndIf

		_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: PIN is not READY - No Set Default Config - Some AT Command related to SIM may not be supported. Attempts left: ' & __ATCmd_GetPINCounter())
		_ATCmd_ErrorLog(@ScriptLineNumber & ' ' & _ATCmd_IsPINReady())

	EndIf

	#TODO PUK needed/requested ?

	Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $ATCmd_RET_SUCCESS)
EndFunc   ;==>_ATCmd_Connect

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_Disconnect
; Description ...: Close Port Handle
; Syntax ........: _ATCmd_Disconnect()
; Parameters ....: None
; Return values .: Success      - True/False
;                  Failure      - $ATCmd_RET_FAILURE  and set @error like _COM_ClosePort
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_Disconnect()
	If __ATCmd_Instance() Then
		_ATCmd_FullLoging('- DISCONNECTING: ' & __ATCmd_Instance())
		_COM_ClosePort(__ATCmd_Instance())
	EndIf
	_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: _ATCmd_Disconnect')
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)
EndFunc   ;==>_ATCmd_Disconnect

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_ErrorLog
; Description ...: Register logger function
; Syntax ........: _ATCmd_ErrorLog($sTextOrFunction[, $iError = @error[, $iExtended = @extended]])
; Parameters ....: $sTextOrFunction     - a string value.
;                  $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: None
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_ErrorLog($sTextOrFunction, $iError = @error, $iExtended = @extended)
	Local Static $fnFunction = Null
	If IsFunc($sTextOrFunction) Then
		$fnFunction = $sTextOrFunction
		Return SetError($iError, $iExtended)
	EndIf
	If $iError And IsFunc($fnFunction) Then $fnFunction("!" & ' @error=' & $iError & ' @extended=' & $iExtended & ' : ' & $sTextOrFunction)
	Return SetError($iError, $iExtended)
EndFunc   ;==>_ATCmd_ErrorLog

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_FullLoging
; Description ...: Enable/Disable Full logging mode
; Syntax ........: _ATCmd_FullLoging([$sTextOrFunction = Default])
; Parameters ....: $sTextOrFunction     - [optional] a string value. Default is Default.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_FullLoging($sTextOrFunction = Default, $iError = @error, $iExtended = @extended)
	Local Static $fnFunction = Null
	If IsFunc($sTextOrFunction) Then
		$fnFunction = $sTextOrFunction
		Return SetError($iError, $iExtended)
	EndIf
	If IsString($sTextOrFunction) And IsFunc($fnFunction) Then $fnFunction($sTextOrFunction)
	Return SetError($iError, $iExtended)
EndFunc   ;==>_ATCmd_FullLoging

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_GetAllStatus
; Description ...: Get Information
; Syntax ........: _ATCmd_GetAllStatus([$bVerbose = False[, $bQueryOperatorList = False]])
; Parameters ....: $bVerbose  Return 2DArray- [optional] a boolean value. Default is False.
;                  $bQueryOperatorList  Query operator list- [optional] a boolean value. Default is False.
; Return values .: Success      - 1DArray|2DArray Information
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......: $bQueryOperatorList  will cause long delay while getting Operator List Available
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_GetAllStatus($bVerbose = False, $bQueryOperatorList = False)
	Local $aStatus[0]
	If $bVerbose Then
		ReDim $aStatus[$ATCmd_STATUS__COUNTER][2]
		$aStatus[$ATCmd_STATUS_00_MANUFACTURER][0] = "Manufacturer"
		$aStatus[$ATCmd_STATUS_01_MODELNAME][0] = "Model"
		$aStatus[$ATCmd_STATUS_02_SERIALNUMBER][0] = "Product Serial Number"
		$aStatus[$ATCmd_STATUS_03_SIM][0] = "SIM"
		$aStatus[$ATCmd_STATUS_04_PIN][0] = "PIN"
		$aStatus[$ATCmd_STATUS_05_PINLATTLEFT][0] = "PIN Attempts Left"
		$aStatus[$ATCmd_STATUS_06_NETWORKREGSTATUS][0] = "Network Registration Status"
		$aStatus[$ATCmd_STATUS_07_OPERATORSELECTION][0] = "Operator Selection"
		$aStatus[$ATCmd_STATUS_08_SIGNALSTRENGTH][0] = "Signal Strength"
		$aStatus[$ATCmd_STATUS_09_OPERATORLIST][0] = "Operators List"
		$aStatus[$ATCmd_STATUS_10_SENDERSUPPORTED][0] = "Sender Supported"
		$aStatus[$ATCMD_STATUS_11_SUBSCRIBERNUMBER][0] = "Subscriber Number"

		$aStatus[$ATCmd_STATUS_00_MANUFACTURER][1] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+CGMI" & @CR))
		$aStatus[$ATCmd_STATUS_01_MODELNAME][1] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+CGMM" & @CR))
		$aStatus[$ATCmd_STATUS_02_SERIALNUMBER][1] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+CGSN" & @CR))
		$aStatus[$ATCmd_STATUS_03_SIM][1] = _ATCmd_IsSIMInserted() ? "OK" : __ATCmd_StringStripCRLFOK(__ATCmd_LastResponse())
		$aStatus[$ATCmd_STATUS_04_PIN][1] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+CPIN?" & @CR))
		$aStatus[$ATCmd_STATUS_05_PINLATTLEFT][1] = __ATCmd_GetPINCounter()
		$aStatus[$ATCmd_STATUS_06_NETWORKREGSTATUS][1] = _ATCmd_CommandSyncOK("AT+CREG?" & @CR)
		$aStatus[$ATCmd_STATUS_07_OPERATORSELECTION][1] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+COPS?" & @CR))
		$aStatus[$ATCmd_STATUS_08_SIGNALSTRENGTH][1] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+CSQ" & @CR))
		$aStatus[$ATCmd_STATUS_09_OPERATORLIST][1] = $bQueryOperatorList ? __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+COPS=?" & @CR, 180)) : "Not requested" ; this may take many seconds
		$aStatus[$ATCmd_STATUS_10_SENDERSUPPORTED][1] = _ATCmd_IsSenderSupported() ? "OK" : "NO"
		$aStatus[$ATCMD_STATUS_11_SUBSCRIBERNUMBER][1] = _ATCmd_CommandSyncOK("AT+CNUM" & @CR)
	Else
		ReDim $aStatus[$ATCmd_STATUS__COUNTER]
		$aStatus[$ATCmd_STATUS_00_MANUFACTURER] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+CGMI" & @CR))
		$aStatus[$ATCmd_STATUS_01_MODELNAME] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+CGMM" & @CR))
		$aStatus[$ATCmd_STATUS_02_SERIALNUMBER] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+CGSN" & @CR))
		$aStatus[$ATCmd_STATUS_03_SIM] = _ATCmd_IsSIMInserted() ? "OK" : __ATCmd_StringStripCRLFOK(__ATCmd_LastResponse())
		$aStatus[$ATCmd_STATUS_04_PIN] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+CPIN?" & @CR))
		$aStatus[$ATCmd_STATUS_05_PINLATTLEFT] = __ATCmd_GetPINCounter()
		$aStatus[$ATCmd_STATUS_06_NETWORKREGSTATUS] = _ATCmd_CommandSyncOK("AT+CREG" & @CR)
		$aStatus[$ATCmd_STATUS_07_OPERATORSELECTION] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+COPS?" & @CR))
		$aStatus[$ATCmd_STATUS_08_SIGNALSTRENGTH] = __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+CSQ" & @CR))
		$aStatus[$ATCmd_STATUS_09_OPERATORLIST] = $bQueryOperatorList ? __ATCmd_StringStripCRLFOK(_ATCmd_CommandSyncOK("AT+COPS=?" & @CR, 180)) : "Not requested" ; this may take many seconds
		$aStatus[$ATCmd_STATUS_10_SENDERSUPPORTED] = _ATCmd_IsSenderSupported() ? "OK" : "NO"
		$aStatus[$ATCMD_STATUS_11_SUBSCRIBERNUMBER] = _ATCmd_CommandSyncOK("AT+CNUM" & @CR)
	EndIf

	Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $aStatus)
EndFunc   ;==>_ATCmd_GetAllStatus

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_GetLastErrorMessage
; Description ...: Get last AT Command sent and device response
; Syntax ........: _ATCmd_GetLastErrorMessage([$iError = @error[, $iExtended = @extended]])
; Parameters ....: $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: String - last ATCommand sent and ATResponse
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_GetLastErrorMessage($iError = @error, $iExtended = @extended)
	Return SetError($iError, $iExtended, StringFormat('ATCommand: [%s]\t ATResponse: [%s]', __ATCmd_LastSent(), __ATCmd_LastResponse()))
EndFunc   ;==>_ATCmd_GetLastErrorMessage

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_GetLastErrorMessageCR
; Description ...: Get last AT Command sent and device response - wrapper for _ATCmd_GetLastErrorMessage string @CRLFs
; Syntax ........: _ATCmd_GetLastErrorMessageCR([$iError = @error[, $iExtended = @extended]])
; Parameters ....: $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: String - last ATCommand Sent and ATResponse
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......: _ATCmd_GetLastErrorMessage
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_GetLastErrorMessageCR($iError = @error, $iExtended = @extended)
	Return SetError($iError, $iExtended, StringStripWS(StringFormat(' ' & _
			@CRLF & '! ATCommand: [%s]' & @CRLF & '! ATResponse: [%s]', _
			StringRegExpReplace(__ATCmd_LastSent(), '\r|\n', ' '), _
			StringRegExpReplace(__ATCmd_LastResponse(), '\r|\n', ' ') _
			), $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))
EndFunc   ;==>_ATCmd_GetLastErrorMessageCR

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_IsPINReady
; Description ...: Set PIN
; Syntax ........: _ATCmd_IsPINReady()
; Parameters ....: None
; Return values .: Success      - $ATCmd_RET_SUCCESS
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_IsPINReady()
	If StringInStr(_ATCmd_CommandSyncOK("AT+CPIN?" & @CR), '+CPIN: READY') Then Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $ATCmd_RET_SUCCESS)
	Return SetError($ATCmd_ERR_PIN, @extended, $ATCmd_RET_FAILURE)
EndFunc   ;==>_ATCmd_IsPINReady

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_IsPINRequired
; Description ...: Check if PIN is required
; Syntax ........: _ATCmd_IsPINRequired()
; Parameters ....: None
; Return values .: Success      - $ATCmd_RET_SUCCESS
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_IsPINRequired()
	If StringInStr(_ATCmd_CommandSyncOK("AT+CPIN?" & @CR), '+CPIN: SIM PIN') Then Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $ATCmd_RET_SUCCESS)
	Return SetError(@error, @extended, $ATCmd_RET_FAILURE)
EndFunc   ;==>_ATCmd_IsPINRequired

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_IsSenderSupported
; Description ...: Check if device support send message
; Syntax ........: _ATCmd_IsSenderSupported()
; Parameters ....: None
; Return values .: Success      - $ATCmd_RET_SUCCESS
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_IsSenderSupported()
	_ATCmd_CommandSyncOK("AT+CSMS?" & @CR)
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

	Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $ATCmd_RET_SUCCESS)
EndFunc   ;==>_ATCmd_IsSenderSupported

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_IsSIMInserted
; Description ...: Check if SIM is inserted
; Syntax ........: _ATCmd_IsSIMInserted()
; Parameters ....: None
; Return values .: Success      - $ATCmd_RET_SUCCESS
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_IsSIMInserted()
	If StringInStr(_ATCmd_CommandSyncOK("AT+CPIN?" & @CR), '+CME ERROR') Then Return SetError($ATCmd_ERR_SIM, $ATCmd_EXT_DEFAULT, $ATCmd_RET_FAILURE)
	Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $ATCmd_RET_SUCCESS)
EndFunc   ;==>_ATCmd_IsSIMInserted

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_ListDevices
; Description ...: Get COM Devices list  2DArray  DevicesName|COMPort
; Syntax ........: _ATCmd_ListDevices([$bIsAvailable = False])
; Parameters ....: $bIsAvailable        - [optional] a boolean value. Default is False. List only device that can be open
; Return values .: Success      - 2DArray DevicesName|COMPort
;                  Failure      - $ATCmd_RET_FAILURE and set @error like _COM_ListPortDevices
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......: _COM_ListPortDevices
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_ListDevices($bIsAvailable = False)
	Local $aCOMDevices = _COM_ListPortDevices($bIsAvailable)
	_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: _ATCmd_ListDevices')
	Return SetError(@error, @extended, $aCOMDevices)
EndFunc   ;==>_ATCmd_ListDevices

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_OnPINRequest
; Description ...: Check If PIN is required and show a InputBox for set it
; Syntax ........: _ATCmd_OnPINRequest([$bRequestAttemptLeft = True])
; Parameters ....: $bRequestAttemptLeft - [optional] a boolean value. Default is True.
; Return values .: Success      - $ATCmd_RET_SUCCESS
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......: _ATCmd_IsPINRequired, _ATCmd_SetPIN
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_OnPINRequest($bRequestAttemptLeft = True)
	If _ATCmd_IsPINRequired() Then
		Local $sPIN = InputBox("PIN Request" & ($bRequestAttemptLeft ? " - Attempts left: " & __ATCmd_GetPINCounter() : ""), _
				"Enter PIN:", "", "", 250, 120)
		If @error Or $sPIN = "" Or StringLen($sPIN) <> 4 Then Return SetError($ATCmd_ERR_PIN, $ATCmd_EXT_DEFAULT, $ATCmd_RET_FAILURE)
		Local $vResult = _ATCmd_SetPIN($sPIN)
		Return SetError(@error, @extended, $vResult)
	EndIf
	Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $ATCmd_RET_SUCCESS)
EndFunc   ;==>_ATCmd_OnPINRequest

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_SetPIN
; Description ...: set SIM PIN
; Syntax ........: _ATCmd_SetPIN($sPIN)
; Parameters ....: $sPIN                - a string value.
; Return values .: Success      - $ATCmd_RET_SUCCESS
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_SetPIN($sPIN)
	_ATCmd_CommandSyncOK('AT+CPIN="' & $sPIN & '"' & @CR)  ;
	__ATCmd_DefaultConfig() ; Reset
	Local $vResult = _ATCmd_IsPINReady()
	Return SetError(@error, @extended, $vResult)
EndFunc   ;==>_ATCmd_SetPIN

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_SMS_ListMessages
; Description ...: List - read stored messages. The messages are read from the memory selected by the +CPMS command
; Syntax ........: _ATCmd_SMS_ListMessages([$iTimeOut = 60])
; Parameters ....: $iTimeOut            - [optional] an integer value. Default is 60.
; Return values .: Success      - 2DArray messages information
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......: Read PDU Not implemented yet.
; Related .......: __ATCmd_SMS_ListMessagesToArray
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_SMS_ListMessages($iTimeOut = 60)
	#TODO $ATCmd_CMGLPDU_* usage
	_ATCmd_CommandSyncOK('AT+CPMS?' & @CR, $iTimeOut)  ; <mem1>,<used1>,total1>,<mem2>,<used2>,<total2>,<mem3>,<used3>,<total3>
	_ATCmd_CommandSyncOK('AT+CMGL=?' & @CR, $iTimeOut) ; list of supported <stat>s
	Local $sATResponse = _ATCmd_UsePDU() ? _ATCmd_CommandSyncOK('AT+CMGL=4' & @CR, $iTimeOut) : _ATCmd_CommandSyncOK('AT+CMGL="ALL"' & @CR, $iTimeOut)  ; List Messages PDU/TEXT respectively
	_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: _ATCmd_SMS_ListMessages')
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

	Local $a_2DListOf_Messages = __ATCmd_SMS_ListMessagesToArray($sATResponse)
	Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $a_2DListOf_Messages)
	#TODO REFACTOR Error handling
EndFunc   ;==>_ATCmd_SMS_ListMessages

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_SMS_Sender
; Description ...: Send Message - Send message using AT Command
; Syntax ........: _ATCmd_SMS_Sender($sPhoneNumber, $sMessage)
; Parameters ....: $sPhoneNumber        - a string value.
;                  $sMessage            - a string value.
; Return values .: Success      - $ATCmd_RET_SUCCESS
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......: PDU is not supported yet
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_SMS_Sender($sPhoneNumber, $sMessage)
	Do
		If _ATCmd_UsePDU() Then
			#TODO - PDU is not supported yet
			Local $sPDUMessage = __ATCmd_ComposePDU($sPhoneNumber, $sMessage)
			Local $sLenPDU = @extended
			_ATCmd_FullLoging(@ScriptLineNumber & ' _ATCmd_SMS_Sender: PDU: LenPDU=' & $sLenPDU & ' PDUMessage=' & $sPDUMessage)
			; Send Message - PDU Method = <length><CR>pdu_hex_string<ctrl-z/ESC>
			_ATCmd_Command('AT+CMGS=' & $sLenPDU & @CR)
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: PDU: Sending AT+CMGS=')
			If @error Then ExitLoop

			__ATCmd_WaitSuccess('>', 5) ; +CMGS 60 after CTRL-Z for SMS not concatenated; 1 to get ‘>’ prompt
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: PDU: Wait for ‘>’ prompt')
			If @error Then ExitLoop

			_ATCmd_Command($sPDUMessage)
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: PDU: _ATCmd_Command($sPDUMessage)')
			If @error Then ExitLoop

			_ATCmd_CommandSyncOK($ATCmd_CTRL_Z)
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: PDU: CTRL_Z')
			If @error Then ExitLoop
		ElseIf _ATCmd_UseUCS2() Then
			; Send Message - TEXT Method = <da>[,<toda>]<CR>text_string<ctrl-z/ESC>
			_ATCmd_Command('AT+CMGS="' & __ATCmd_StringToUCS2Hex($sPhoneNumber) & '"' & @CR)
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: UCS2: Sending AT+CMGS=')
			If @error Then ExitLoop

			__ATCmd_WaitSuccess('>', 5) ; +CMGS 60 after CTRL-Z for SMS not concatenated; 1 to get ‘>’ prompt
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: UCS2: Wait for ‘>’ prompt')
			If @error Then ExitLoop

			_ATCmd_Command(__ATCmd_StringToUCS2Hex($sMessage))
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: UCS2: _ATCmd_Command(MESSAGE)')
			If @error Then ExitLoop

			_ATCmd_CommandSyncOK($ATCmd_CTRL_Z)
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: UCS2: CTRL_Z')
			If @error Then ExitLoop
		Else
			; Send Message - TEXT Method = <da>[,<toda>]<CR>text_string<ctrl-z/ESC>
			_ATCmd_Command('AT+CMGS="' & $sPhoneNumber & '"' & @CR)
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: TEXT: Sending AT+CMGS=')
			If @error Then ExitLoop

			__ATCmd_WaitSuccess('>', 5) ; +CMGS 60 after CTRL-Z for SMS not concatenated; 1 to get ‘>’ prompt
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: TEXT: Wait for ‘>’ prompt')
			If @error Then ExitLoop

			_ATCmd_Command($sMessage)
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: TEXT: _ATCmd_Command(MESSAGE)')
			If @error Then ExitLoop

			_ATCmd_CommandSyncOK($ATCmd_CTRL_Z)
			_ATCmd_ErrorLog(@ScriptLineNumber & ' _ATCmd_SMS_Sender: TEXT: CTRL_Z')
			If @error Then ExitLoop
		EndIf
	Until 1
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

	Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $ATCmd_RET_SUCCESS)
EndFunc   ;==>_ATCmd_SMS_Sender

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_UsePDU
; Description ...: Enable/Disable PDU mode
; Syntax ........: _ATCmd_UsePDU([$bChoose = Default])
; Parameters ....: $bChoose     - [optional] a boolean value. Default is Default.
; Return values .: Success      - True/False
;                  Failure      - $ATCmd_RET_FAILURE and set @error = $ATCmd_ERR_PARAMETER
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_UsePDU($bChoose = Default)
	Local Static $bPDU_Mode = False
	If Not @NumParams Then Return $bPDU_Mode
	If Not IsBool($bChoose) Then Return SetError($ATCmd_ERR_PARAMETER, $ATCmd_EXT_DEFAULT, $ATCmd_RET_FAILURE)
	$bPDU_Mode = $bChoose
	If $bChoose Then _ATCmd_UseUCS2(False) ; reset UCS2
EndFunc   ;==>_ATCmd_UsePDU

; #FUNCTION# ====================================================================================================================
; Name ..........: _ATCmd_UseUCS2
; Description ...: Enable/Disable UCS2 mode
; Syntax ........: _ATCmd_UseUCS2([$bChoose = Default])
; Parameters ....: $bChoose     - [optional] a boolean value. Default is Default.
; Return values .: Success      - True/False
;                  Failure      - $ATCmd_RET_FAILURE and set @error = $ATCmd_ERR_PARAMETER
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......: PDU is enabled if UCS2 is used
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ATCmd_UseUCS2($bChoose = Default)
	Local Static $bUCS2_Mode = False
	If Not @NumParams Then Return $bUCS2_Mode
	If Not IsBool($bChoose) Then Return SetError($ATCmd_ERR_PARAMETER, $ATCmd_EXT_DEFAULT, $ATCmd_RET_FAILURE)

	$bUCS2_Mode = $bChoose
	If $bChoose Then _ATCmd_UsePDU(False) ; reset PDU
EndFunc   ;==>_ATCmd_UseUCS2
#EndRegion ; ATCmd.au3 - Functions #CURRENT#

#Region ; ATCmd.au3 - Functions #INTERNAL_USE_ONLY#

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_CMSErrorParser
; Description ...: parse CMS ERROR # to Verbose format
; Syntax ........: __ATCmd_CMSErrorParser($sData[, $iError = @error[, $iExtended = @extended]])
; Parameters ....: $sData               - a string value.
;                  $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: CMS ERROR # in Verbose format
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.smssolutions.net/tutorials/gsm/gsmerrorcodes/
; Link ..........: http://www.ozekisms.com/p_2380-ozeki-cms-error-codes.html
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_CMSErrorParser($sData, $iError = @error, $iExtended = @extended)
	Local $aResult = StringRegExp($sData, '(?:CMS ERROR: \d+)\Z', $STR_REGEXPARRAYGLOBALMATCH)
	If @error Then Return SetError($iError, $iExtended, $sData)

	Local $sSufix = ''
	Switch $aResult[0]
		Case 'CMS ERROR: 1'
			$sSufix = 'Unassigned number'
		Case 'CMS ERROR: 8'
			$sSufix = 'Operator determined barring'
		Case 'CMS ERROR: 10'
			$sSufix = 'Call bared'
		Case 'CMS ERROR: 21'
			$sSufix = 'Short message transfer rejected'
		Case 'CMS ERROR: 27'
			$sSufix = 'Destination out of service'
		Case 'CMS ERROR: 28'
			$sSufix = 'Unindentified subscriber'
		Case 'CMS ERROR: 29'
			$sSufix = 'Facility rejected'
		Case 'CMS ERROR: 30'
			$sSufix = 'Unknown subscriber'
		Case 'CMS ERROR: 38'
			$sSufix = 'Network out of order'
		Case 'CMS ERROR: 41'
			$sSufix = 'Temporary failure'
		Case 'CMS ERROR: 42'
			$sSufix = 'Congestion'
		Case 'CMS ERROR: 47'
			$sSufix = 'Recources unavailable'
		Case 'CMS ERROR: 50'
			$sSufix = 'Requested facility not subscribed'
		Case 'CMS ERROR: 69'
			$sSufix = 'Requested facility not implemented'
		Case 'CMS ERROR: 81'
			$sSufix = 'Invalid short message transfer reference value'
		Case 'CMS ERROR: 95'
			$sSufix = 'Invalid message unspecified'
		Case 'CMS ERROR: 96'
			$sSufix = 'Invalid mandatory information'
		Case 'CMS ERROR: 97'
			$sSufix = 'Message type non existent or not implemented'
		Case 'CMS ERROR: 98'
			$sSufix = 'Message not compatible with short message protocol'
		Case 'CMS ERROR: 99'
			$sSufix = 'Information element non-existent or not implemente'
		Case 'CMS ERROR: 111'
			$sSufix = 'Protocol error, unspecified'
		Case 'CMS ERROR: 127'
			$sSufix = 'Internetworking , unspecified'
		Case 'CMS ERROR: 128'
			$sSufix = 'Telematic internetworking not supported'
		Case 'CMS ERROR: 129'
			$sSufix = 'Short message type 0 not supported'
		Case 'CMS ERROR: 130'
			$sSufix = 'Cannot replace short message'
		Case 'CMS ERROR: 143'
			$sSufix = 'Unspecified TP-PID error'
		Case 'CMS ERROR: 144'
			$sSufix = 'Data code scheme not supported'
		Case 'CMS ERROR: 145'
			$sSufix = 'Message class not supported'
		Case 'CMS ERROR: 159'
			$sSufix = 'Unspecified TP-DCS error'
		Case 'CMS ERROR: 160'
			$sSufix = 'Command cannot be actioned'
		Case 'CMS ERROR: 161'
			$sSufix = 'Command unsupported'
		Case 'CMS ERROR: 175'
			$sSufix = 'Unspecified TP-Command error'
		Case 'CMS ERROR: 176'
			$sSufix = 'TPDU not supported'
		Case 'CMS ERROR: 192'
			$sSufix = 'SC busy'
		Case 'CMS ERROR: 193'
			$sSufix = 'No SC subscription'
		Case 'CMS ERROR: 194'
			$sSufix = 'SC System failure'
		Case 'CMS ERROR: 195'
			$sSufix = 'Invalid SME address'
		Case 'CMS ERROR: 196'
			$sSufix = 'Destination SME barred'
		Case 'CMS ERROR: 197'
			$sSufix = 'SM Rejected-Duplicate SM'
		Case 'CMS ERROR: 198'
			$sSufix = 'TP-VPF not supported'
		Case 'CMS ERROR: 199'
			$sSufix = 'TP-VP not supported'
		Case 'CMS ERROR: 208'
			$sSufix = 'D0 SIM SMS Storage full'
		Case 'CMS ERROR: 209'
			$sSufix = 'No SMS Storage capability in SIM'
		Case 'CMS ERROR: 210'
			$sSufix = 'Error in MS'
		Case 'CMS ERROR: 211'
			$sSufix = 'Memory capacity exceeded'
		Case 'CMS ERROR: 212'
			$sSufix = 'Sim application toolkit busy'
		Case 'CMS ERROR: 213'
			$sSufix = 'SIM data download error'
		Case 'CMS ERROR: 255'
			$sSufix = 'Unspecified error cause'
		Case 'CMS ERROR: 300'
			$sSufix = 'ME Failure'
		Case 'CMS ERROR: 301'
			$sSufix = 'SMS service of ME reserved'
		Case 'CMS ERROR: 302'
			$sSufix = 'Operation not allowed'
		Case 'CMS ERROR: 303'
			$sSufix = 'Operation not supported'
		Case 'CMS ERROR: 304'
			$sSufix = 'Invalid PDU mode parameter'
		Case 'CMS ERROR: 305'
			$sSufix = 'Invalid Text mode parameter'
		Case 'CMS ERROR: 310'
			$sSufix = 'SIM not inserted'
		Case 'CMS ERROR: 311'
			$sSufix = 'SIM PIN required'
		Case 'CMS ERROR: 312'
			$sSufix = 'PH-SIM PIN required'
		Case 'CMS ERROR: 313'
			$sSufix = 'SIM failure'
		Case 'CMS ERROR: 314'
			$sSufix = 'SIM busy'
		Case 'CMS ERROR: 315'
			$sSufix = 'SIM wrong'
		Case 'CMS ERROR: 316'
			$sSufix = 'SIM PUK required'
		Case 'CMS ERROR: 317'
			$sSufix = 'SIM PIN2 required'
		Case 'CMS ERROR: 318'
			$sSufix = 'SIM PUK2 required'
		Case 'CMS ERROR: 320'
			$sSufix = 'Memory failure'
		Case 'CMS ERROR: 321'
			$sSufix = 'Invalid memory index'
		Case 'CMS ERROR: 322'
			$sSufix = 'Memory full'
		Case 'CMS ERROR: 330'
			$sSufix = 'SMSC address unknown'
		Case 'CMS ERROR: 331'
			$sSufix = 'No network service'
		Case 'CMS ERROR: 332'
			$sSufix = 'Network timeout'
		Case 'CMS ERROR: 340'
			$sSufix = 'No +CNMA expected'
		Case 'CMS ERROR: 500' ; http://www.ozekisms.com/p_2598-ozeki-cms-error-500.html
			$sSufix = 'Unknown error'
		Case 'CMS ERROR: 512'
			$sSufix = 'User abort'
		Case 'CMS ERROR: 513'
			$sSufix = 'Unable to store'
		Case 'CMS ERROR: 514'
			$sSufix = 'Invalid Status'
		Case 'CMS ERROR: 515'
			$sSufix = 'Device busy or Invalid Character in string'
		Case 'CMS ERROR: 516'
			$sSufix = 'Invalid length'
		Case 'CMS ERROR: 517'
			$sSufix = 'Invalid character in PDU'
		Case 'CMS ERROR: 518'
			$sSufix = 'Invalid parameter'
		Case 'CMS ERROR: 519'
			$sSufix = 'Invalid length or character'
		Case 'CMS ERROR: 520'
			$sSufix = 'Invalid character in text'
		Case 'CMS ERROR: 521'
			$sSufix = 'Timer expired'
		Case 'CMS ERROR: 522'
			$sSufix = 'Operation temporary not allowed'
		Case 'CMS ERROR: 532'
			$sSufix = 'SIM not ready'
		Case 'CMS ERROR: 534'
			$sSufix = 'Cell Broadcast error unknown'
		Case 'CMS ERROR: 535'
			$sSufix = 'Protocol stack busy'
		Case 'CMS ERROR: 538'
			$sSufix = 'Invalid parameter'
	EndSwitch
	If $sSufix Then $sSufix = ' ( ' & $sSufix & ' )'
	Local $sResult = StringReplace($sData, $aResult[0], $aResult[0] & $sSufix)
	Return SetError($iError, $iExtended, $sResult)
EndFunc   ;==>__ATCmd_CMSErrorParser

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_DefaultConfig
; Description ...: Set default setting
; Syntax ........: __ATCmd_DefaultConfig()
; Parameters ....: None
; Return values .: Success      - $ATCmd_RET_SUCCESS
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......:
; Remarks .......: PDU is not supported yet
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_DefaultConfig()
	_ATCmd_CommandSyncOK('AT+CFUN=1' & @CR) ; Set Functionality - 0 = full functionality ; 1 - mobile full functionality with power saving disabled (factory default)
	_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: __ATCmd_DefaultConfig - ' & _ATCmd_GetLastErrorMessageCR())
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)

	If _ATCmd_UsePDU() Then
		#TODO - PDU is not supported yet
		_ATCmd_CommandSyncOK('AT+CMGF=0' & @CR) ; set Message Format PDU
		_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: __ATCmd_DefaultConfig - ' & _ATCmd_GetLastErrorMessageCR())
		If @error Then Return SetError($ATCmd_ERR_COMMAND, $ATCmd_EXT_DEFAULT, $ATCmd_RET_FAILURE)
	ElseIf _ATCmd_UseUCS2() Then
		_ATCmd_CommandSyncOK('AT+CMGF=1' & @CR) ; set Message Format TEXT
		_ATCmd_CommandSync('AT+CSMP=17,167,2,25' & @CR) ; Encoding set for UCS2
		_ATCmd_CommandSync('AT+CSCS="UCS2"' & @CR) ; Setting Character Set to UCS2
		_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: __ATCmd_DefaultConfig - ' & _ATCmd_GetLastErrorMessageCR())
		If @error Then Return SetError($ATCmd_ERR_COMMAND, $ATCmd_EXT_DEFAULT, $ATCmd_RET_FAILURE)
	Else
		_ATCmd_CommandSyncOK('AT+CMGF=1' & @CR) ; set Message Format TEXT
		_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: __ATCmd_DefaultConfig - ' & _ATCmd_GetLastErrorMessageCR())
		If @error Then Return SetError($ATCmd_ERR_COMMAND, $ATCmd_EXT_DEFAULT, $ATCmd_RET_FAILURE)
	EndIf

	Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $ATCmd_RET_SUCCESS)
EndFunc   ;==>__ATCmd_DefaultConfig

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_GetCOMPortByDeviceName
; Description ...: Return COM Port index by Device Name
; Syntax ........: __ATCmd_GetCOMPortByDeviceName($sDeviceName)
; Parameters ....: $sDeviceName         - a string value.
; Return values .: Success      - String COM Port Index (COMX-COMXXX)
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_GetCOMPortByDeviceName($sDeviceName)
	Local $sCOMPort = ""
	Local $aCOMDevices = _ATCmd_ListDevices()
	If Not IsArray($aCOMDevices) Then Return SetError($ATCmd_ERR_NOTCOMPORTS, $ATCmd_EXT_DEFAULT, "")

	For $i = 0 To UBound($aCOMDevices) - 1
		If $sDeviceName = $aCOMDevices[$i][0] Then
			$sCOMPort = $aCOMDevices[$i][1]
			ExitLoop
		EndIf
	Next

	If $sCOMPort Then Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $sCOMPort)
	Return SetError($ATCmd_ERR_NOTFOUND, $ATCmd_EXT_DEFAULT, "")
EndFunc   ;==>__ATCmd_GetCOMPortByDeviceName

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_GetPINCounter
; Description ...: Get PIN Attempts Left
; Syntax ........: __ATCmd_GetPINCounter()
; Parameters ....: None
; Return values .: Success      - PIN Attempts Left
;                  Failure      - Unkown
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_GetPINCounter()
	Local $sResponse = _ATCmd_CommandSyncOK('AT+CSIM=10,"0020000100"' & @CR) ; check the PIN counter - PIN Attempts Left
	If StringInStr($sResponse, "+CSIM") Then
		Local $aReg = StringRegExp($sResponse, '([0-9A-Fa-f]{4})', 3)
		If IsArray($aReg) Then
			Local $iAttempts = Number("0x0" & StringRight($aReg[0], 1))
			Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $iAttempts)
		EndIf
	EndIf
	Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, "Unkown")
EndFunc   ;==>__ATCmd_GetPINCounter

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_Instance
; Description ...: Return/Set COM Port Instance Handle
; Syntax ........: __ATCmd_Instance([$hCOMPort = 0[, $iError = @error[, $iExtended = @extended]]])
; Parameters ....: $hCOMPort            - [optional] a handle value. Default is 0.
;                  $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: COM Port Instance Handle
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_Instance($hCOMPort = 0, $iError = @error, $iExtended = @extended)
	Local Static $hCOMPortInstance = 0
	If @NumParams Then $hCOMPortInstance = $hCOMPort
	Return SetError($iError, $iExtended, $hCOMPortInstance)
EndFunc   ;==>__ATCmd_Instance

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_LastResponse
; Description ...: Return/Set last device response
; Syntax ........: __ATCmd_LastResponse([$sATResponse = ""])
; Parameters ....: $sATResponse         - [optional] a string value. Default is "".
; Return values .: string - AT Command Response
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_LastResponse($sATResponse = "")
	Local Static $sLastATResponse = ""
	If Not @NumParams Then Return $sLastATResponse
	$sLastATResponse = $sATResponse
	_ATCmd_FullLoging('> AT Response: ' & $sLastATResponse)
EndFunc   ;==>__ATCmd_LastResponse

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_LastSent
; Description ...: Return/Set last Sent AT Command
; Syntax ........: __ATCmd_LastSent([$sATSent = ""])
; Parameters ....: $sATSent             - [optional] a string value. Default is "".
; Return values .: string - Last AT Command Sent
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_LastSent($sATSent = "")
	Local Static $sLastATSent = ""
	If Not @NumParams Then Return $sLastATSent
	_ATCmd_FullLoging('+ ATCommand sent: ' & $sATSent)
	$sLastATSent = $sATSent
EndFunc   ;==>__ATCmd_LastSent

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_ShutDown
; Description ...: Free COM Port Handle
; Syntax ........: __ATCmd_ShutDown()
; Parameters ....: None
; Return values .: Success      - None
;                  Failure      - $ATCmd_RET_FAILURE  and set @error like _ATCmd_Disconnect
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......: _ATCmd_Disconnect
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_ShutDown()
	_ATCmd_Disconnect()
	_ATCmd_ErrorLog(@ScriptLineNumber & ' ATCmd: __ATCmd_ShutDown')
	If @error Then Return SetError(@error, @extended, $ATCmd_RET_FAILURE)
EndFunc   ;==>__ATCmd_ShutDown

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_SMS_ListMessagesToArray
; Description ...: List device text message
; Syntax ........: __ATCmd_SMS_ListMessagesToArray($ATResponse)
; Parameters ....: $ATResponse          - an unknown value.
; Return values .: Success      - 2DArray messages information - ;Index;Status;FromPhone;Date;Text
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......: PDU is not supported yet
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_SMS_ListMessagesToArray($ATResponse)

	If _ATCmd_UsePDU() Then
		#TODO - PDU is not supported yet
		; https://www.diafaan.com/sms-tutorials/gsm-modem-tutorial/at-cmgl-pdu-mode/
		; https://www.developershome.com/sms/operatingMode.asp
	Else
		Local $aMessages_Outer = StringRegExp($ATResponse, '(?is)\+CMGL: (\d+),"(.*?)","(.*?)","?(.*?)"?,"(.*?)"(|(,"\V+"))\R(\V+)', $STR_REGEXPARRAYGLOBALFULLMATCH)
		;																 INDEX  STAT    oa/da    alpha    scts  to*a,Len     data
#cs typical output
+CMGL: <index>,<stat>,<oa/da>,<alpha>,<scts>[,<tooa/toda>,
<length>]<CR><LF><data>[<CR><LF>
+CMGL: <index>,<stat>,<oa/da>,<alpha>,<scts>[,<tooa/toda>,
<length>]<CR><LF><data>[...]]
#ce

#cs possible $ATCmd_MSGTEXT_06_TYPE values
<tooa/toda> - type of number <oa/da>
129 - number in national format
145 - number in international format (contains the "+")
#ce

		Local $a_2DListOf_Messages[UBound($aMessages_Outer)][$ATCmd_MSGTEXT__COUNTER]
		Local $a_INNER

		#Region ; ATCmd.au3 - processing RegExp result to 2D arrray
		For $IDX_O = 0 To UBound($aMessages_Outer) - 1
			$a_INNER = $aMessages_Outer[$IDX_O]
			For $IDX_I = 0 To $ATCmd_MSGTEXT__COUNTER - 1
				$a_2DListOf_Messages[$IDX_O][$IDX_I] = $a_INNER[$IDX_I]
			Next
		Next
		#EndRegion ; ATCmd.au3 - processing RegExp result to 2D arrray

		#Region ; ATCmd.au3 - post processing
		Local $a_Temp
		For $ROW = 0 To UBound($a_2DListOf_Messages) - 1
			#Region ; ATCmd.au3 - splitting $ATCmd_MSGTEXT_06_TYPE / $ATCmd_MSGTEXT_07_LENGTH
			; The following part of RegExp returns the same values for both information
			;    				(|(,"\V+"))
			; thus there is a need to separate them
			If $a_2DListOf_Messages[$ROW][$ATCmd_MSGTEXT_06_TYPE] <> '' And $a_2DListOf_Messages[$ROW][$ATCmd_MSGTEXT_06_TYPE] = $a_2DListOf_Messages[$ROW][$ATCmd_MSGTEXT_07_LENGTH] Then
				;    ,"145","1"
				;    ,"<tooa/toda>","<length>"
				$a_Temp = StringRegExp($a_2DListOf_Messages[$ROW][$ATCmd_MSGTEXT_06_TYPE], '(?:,")([^\"]+)', $STR_REGEXPARRAYGLOBALMATCH)
				If UBound($a_Temp) = 0 Then
					#TODO ??? to be considered what to do here
				ElseIf UBound($a_Temp) = 2 Then
					$a_2DListOf_Messages[$ROW][$ATCmd_MSGTEXT_06_TYPE] = $a_Temp[0]
					$a_2DListOf_Messages[$ROW][$ATCmd_MSGTEXT_07_LENGTH] = $a_Temp[1]
				Else
					#TODO ??? to be considered what to do here
				EndIf
			EndIf
			#EndRegion ; ATCmd.au3 - splitting $ATCmd_MSGTEXT_06_TYPE / $ATCmd_MSGTEXT_07_LENGTH

			#Region ; ATCmd.au3 - decoding
			If _ATCmd_UseUCS2() Then
				$a_2DListOf_Messages[$ROW][$ATCmd_MSGTEXT_03_ADDRESS] = __ATCmd_UCS2HexToString($a_2DListOf_Messages[$ROW][$ATCmd_MSGTEXT_03_ADDRESS])
				$a_2DListOf_Messages[$ROW][$ATCmd_MSGTEXT_08_MESSAGE] = __ATCmd_UCS2HexToString($a_2DListOf_Messages[$ROW][$ATCmd_MSGTEXT_08_MESSAGE])
			Else
				; nothing to do
			EndIf
			#EndRegion ; ATCmd.au3 - decoding
		Next
		#EndRegion ; ATCmd.au3 - post processing
		Return $a_2DListOf_Messages
	EndIf
EndFunc   ;==>__ATCmd_SMS_ListMessagesToArray

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_StringStripCRLFOK
; Description ...: replace any CR,LF and "OK" AT Command end string
; Syntax ........: __ATCmd_StringStripCRLFOK($sString)
; Parameters ....: $sString             - a string value.
; Return values .: String
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_StringStripCRLFOK($sString)
	$sString = StringRegExpReplace($sString, '\r|\n', '')
	If StringRight($sString, 2) = "OK" Then $sString = StringLeft($sString, StringLen($sString) - 2)
	Return $sString
EndFunc   ;==>__ATCmd_StringStripCRLFOK

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_WaitResponse
; Description ...: Wait device response
; Syntax ........: __ATCmd_WaitResponse([$iMaxWaitTimeSeconds = 15])
; Parameters ....: $iMaxWaitTimeSeconds - [optional] an integer value. Default is 15.
; Return values .: Success      - Response text from device
;                  Failure      - $ATCmd_RET_FAILURE and set @error $ATCmd_ERR_COMMTIMEOUT or $ATCmd_ERR_COMMERROR or $ATCmd_ERR_COMMAND
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_WaitResponse($iMaxWaitTimeSeconds = 15)
	If $iMaxWaitTimeSeconds < 1 Then $iMaxWaitTimeSeconds = 1
	Local $iSizeBuffer_End = 0
	Local $iSizeBuffer_Temp = 0
	Local $sBuffer = ""
	Local $bSuccess = False
	Local $hTimer = TimerInit() ; Begin the timer and store the handle in a variable.
	Local $iTimerEnd = 0

	While 1
		If TimerDiff($hTimer) / 1000 > $iMaxWaitTimeSeconds Then
			Return SetError($ATCmd_ERR_COMMTIMEOUT, $ATCmd_EXT_DEFAULT, $ATCmd_RET_FAILURE)
		EndIf

		Sleep(10)
		$iSizeBuffer_Temp = _COM_GetInputCount(__ATCmd_Instance())
		If @error Then SetError($ATCmd_ERR_COMMERROR, @error, $ATCmd_RET_FAILURE)

;~ 		If $iSizeBuffer_End And $iSizeBuffer_End = $iSizeBuffer_Temp Then ExitLoop ; no more inputs
		If $iSizeBuffer_End Then ExitLoop ; no more inputs
		$iSizeBuffer_End = $iSizeBuffer_Temp
	WEnd

	$iTimerEnd = TimerDiff($hTimer)

	If $iSizeBuffer_End > 2 Then
		$sBuffer = _COM_ReadString(__ATCmd_Instance(), $iSizeBuffer_End)
		$bSuccess = True
	EndIf
	$sBuffer = __ATCmd_CMSErrorParser($sBuffer)
	__ATCmd_LastResponse($sBuffer) ; save last response
	If $bSuccess Then
		Return SetError($ATCmd_ERR_SUCCESS, $iTimerEnd, $sBuffer)
	EndIf

	Return SetError($ATCmd_ERR_COMMAND, $ATCmd_EXT_DEFAULT, $ATCmd_RET_FAILURE)
EndFunc   ;==>__ATCmd_WaitResponse

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_WaitSuccess
; Description ...: Wait device response match $sATValidation
; Syntax ........: __ATCmd_WaitSuccess([$sATValidation = ""[, $iMaxWaitTimeSeconds = 15]])
; Parameters ....: $sATValidation       - [optional] a string value. Default is "".
;                  $iMaxWaitTimeSeconds - [optional] an integer value. Default is 15.
; Return values .: Success      - Response text from device
;                  Failure      - $ATCmd_RET_FAILURE
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_WaitSuccess($sATValidation = "", $iMaxWaitTimeSeconds = 15)
	If $iMaxWaitTimeSeconds < 1 Then $iMaxWaitTimeSeconds = 1
	If $iMaxWaitTimeSeconds > 60 Then $iMaxWaitTimeSeconds = 60
	Local $iSizeBuffer = 0
	Local $sBuffer = 0
	Local $bSuccess = False
	If $sATValidation And StringRegExp(__ATCmd_LastSent(), '\A' & '(' & 'AT+CMGS=[\d\"]' & '|' & 'AT+CMGW=[\d\"]' & ')', $STR_REGEXPMATCH) Then
		; mLipok: Not sure about: AT+CMSS=
		;
		; REMARK: I2C interfaces are not supproted via COM
		; thus AT#I2CWR= is not needed to check here
		; https://www.autoitscript.com/forum/topic/209996-ai-is-bs/?do=findComment&comment=1525346
		;
		; Other AT Command which uses CTRL-Z should be reviewed:
		; 	AT#EMAILD, AT#SSEND, AT#MSDSEND, AT#SEMAIL, AT#SSLSECDATA, AT#SMTPCL, AT#RSASECDATA, AT#ECHOCFG
		If _ATCmd_UsePDU() Then
			#TODO - PDU is not supported yet
			$sATValidation = __ATCmd_StringTo7bitHex($sATValidation)
		ElseIf _ATCmd_UseUCS2() Then
			$sATValidation = __ATCmd_StringToUCS2Hex($sATValidation)
		EndIf
	EndIf

	#TODO $iMaxWaitTimeSeconds refactor to use TimerInit() TimerDiff()
	$iMaxWaitTimeSeconds *= 4
	For $i = 1 To $iMaxWaitTimeSeconds
		Sleep(250)
		$iSizeBuffer = _COM_GetInputCount(__ATCmd_Instance())
		If $iSizeBuffer > 2 Then
			$sBuffer = _COM_ReadString(__ATCmd_Instance(), $iSizeBuffer)
;~ 			ConsoleWrite('>>>>>>>>>' & $sBuffer & "<<<<<<<<<<" & @CRLF)
			If $sATValidation Then
				If StringInStr($sBuffer, "ERROR") Then
					$bSuccess = False
					ExitLoop
				EndIf
				If StringInStr($sBuffer, $sATValidation) Then
					$bSuccess = True
					ExitLoop
				EndIf
			EndIf
		EndIf
	Next
	$sBuffer = __ATCmd_CMSErrorParser($sBuffer)
	__ATCmd_LastResponse($sBuffer) ; save last response
	If $bSuccess Then
		Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $sBuffer)
	EndIf

	Return SetError($ATCmd_ERR_COMMAND, (($i > $iMaxWaitTimeSeconds) ? $ATCmd_EXT_WAITTIMEOUT : $ATCmd_EXT_DEFAULT), $ATCmd_RET_FAILURE)
EndFunc   ;==>__ATCmd_WaitSuccess
#Region ; ATCmd.au3 - PDU/UCS2 Enconde/Decode

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_Bin2Dec
; Description ...: Binary to decimal
; Syntax ........: __ATCmd_Bin2Dec($iBinary)
; Parameters ....: $iBinary                - Number in binary format like 010101
; Return values .: Number - Decimal Number
; Author ........: kaesereibe
; Modified ......: Danyfirex
; Remarks .......:
; Related .......:
; Link ..........: https://www.autoitscript.com/forum/topic/163035-dec2bin-bin2dec/
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_Bin2Dec($iBinary)
	Return BitOR((StringLen($iBinary) > 1 ? BitShift(__ATCmd_Bin2Dec(StringTrimRight($iBinary, 1)), -1) : 0), StringRight($iBinary, 1))
EndFunc   ;==>__ATCmd_Bin2Dec

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_ComposePDU
; Description ...: Convert Phone and Message to PDU Format
; Syntax ........: __ATCmd_ComposePDU($sPhoneNumber, $sMessage)
; Parameters ....: $sPhoneNumber        - a string value. Full number with national area code for example +48123456789
;                  $sMessage            - a string value.
; Return values .: PDU String
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.gsmfavorites.com/documents/sms/pdutext/
; Link ..........: http://www.gsm-modem.de/sms-pdu-mode.html
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_ComposePDU($sPhoneNumber, $sMessage)
	#Tidy_ILC_Pos=55
	Local Const $bUseUCS2 = _ATCmd_UseUCS2()
	$sMessage = $bUseUCS2 ? StringLeft($sMessage, 70) : StringLeft($sMessage, 160)
	Local $sSMSC = "00"                               ; 00 SMSC number specified by the AT command +CSCA
	Local $TP_MTI = "11"                              ; TP-Message-Type-Indicator  (SMS-SUBMIT|SMSC not reject duplicated|no validity period exists|no reply path|no user data header|no status report)
	Local $TP_RD = "00"                               ; TP-Message-Reference 0...255 - "00" value here lets the phone set the message  reference number itself.

	Local $TP_DA = __ATCmd_DAToPDU($sPhoneNumber)     ; TP-Destination-Address
;~ 	Local $iDA_Length = ""                            ; TP-Destination-Address Length
;~ 	Local $iDA_Type = ""                              ; TP-Destination-Address Type 81  91(international)

	Local $TP_PID = "00"                              ; TP-Protocol-Identifier - Normal case
	Local $TP_DCS = $bUseUCS2 ? "08" : "00"           ; TP-Data-Coding-Scheme   ((USC2) is used for encoding complex sets of non-Latin characters such as Chinese andArabic.)
;~ 													  ;		"00"  GSM alphabet, 7 bits 160 characters
;~ 													  ;		"04"  8-bit data 140 octets
;~ 													  ;		"08" USC2, 16 bits 70 complex characters

	Local $TP_VP = "A7"                               ; TP-Validity-Period -  A7 -> 1 days
	Local $TP_UDL = _                                 ; TP-User-Data-Length - The TP-DCS field indicated 7-bit  data, so the length here is the number of septets (10). If the TP-DCS field were  set to 8-bit data or Unicode, the length would be the number of octets.
			Hex(($bUseUCS2 ? (StringLen($sMessage) * 2) : StringLen($sMessage)), 2)
	Local $TP_UD = $bUseUCS2 ? __ATCmd_StringToUCS2Hex($sMessage) : __ATCmd_StringTo7bitHex($sMessage) ; TP-User-Data

	Local $sTPDU = ""                                 ; Transport Protocol Data Unit
	$sTPDU = $sSMSC & $TP_MTI & $TP_RD & $TP_DA & $TP_PID & $TP_DCS & $TP_VP & $TP_UDL & $TP_UD

	Return SetError($ATCmd_ERR_SUCCESS, ((StringLen($sTPDU) - 2) / 2), $sTPDU)
EndFunc   ;==>__ATCmd_ComposePDU

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_DAToPDU
; Description ...: Comvert Phone Number to DA (Destination Address)
; Syntax ........: __ATCmd_DAToPDU($sPhoneNumber)
; Parameters ....: $sPhoneNumber        - a string value. Full number with national area code for example +48123456789
; Return values .: String - Hex DA(Destination Address) - Address Length+Type of Address+Encoded Destination Address
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_DAToPDU($sPhoneNumber)
	; DestinationAddress To PDU -> Address-Length+Type-of-Address+Encoded DestinationAddress
	Local $iIsInternational = (StringLeft($sPhoneNumber, 1) = "+")
	If $iIsInternational Then $sPhoneNumber = StringMid($sPhoneNumber, 2)
	Local $sDA = _
			Hex(StringLen($sPhoneNumber), 2) & _
			($iIsInternational ? "91" : "81") & _
			__ATCmd_EncodePhoneNumber($sPhoneNumber)
	Return $sDA
EndFunc   ;==>__ATCmd_DAToPDU

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_Dec2Bin
; Description ...: Decimal to binary
; Syntax ........: __ATCmd_Dec2Bin($iDecimal)
; Parameters ....: $iDecimal - Decimal value
; Return values .: Number - Number in binary format like 010101
; Author ........: kaesereibe
; Modified ......: Danyfirex
; Remarks .......:
; Related .......:
; Link ..........: https://www.autoitscript.com/forum/topic/163035-dec2bin-bin2dec/
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_Dec2Bin($iDecimal)
	Return (BitShift($iDecimal, 1) ? __ATCmd_Dec2Bin(BitShift($iDecimal, 1)) : "") & BitAND($iDecimal, 1)
EndFunc   ;==>__ATCmd_Dec2Bin

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_EncodePhoneNumber
; Description ...: Encode Phone Number
; Syntax ........: __ATCmd_EncodePhoneNumber($sPhoneNumber)
; Parameters ....: $sPhoneNumber        - a string value. Full number with national area code for example +48123456789
; Return values .: Encode String(HEX) Number
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: http://www.developershome.com/sms/cmgsCommand4.asp#25.5.1.2 - The Fifth Sub-field: Destination Phone Number
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_EncodePhoneNumber($sPhoneNumber)
	Local $sEncodePhone = ""
	If Not Mod(StringLen($sPhoneNumber), 2) = 0 Then $sPhoneNumber = $sPhoneNumber & "F"
	Local $aReg = StringRegExp($sPhoneNumber, "[1-9F]{1,2}", $STR_REGEXPARRAYGLOBALMATCH)

	For $i = 0 To UBound($aReg) - 1
		$aReg[$i] = StringReverse($aReg[$i])
	Next

	For $i = 0 To UBound($aReg) - 1
		$sEncodePhone &= $aReg[$i]
	Next

	Return $sEncodePhone
EndFunc   ;==>__ATCmd_EncodePhoneNumber

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_StringTo7bitHex
; Description ...: Encode string to 7 bit data
; Syntax ........: __ATCmd_StringTo7bitHex($sText)
; Parameters ....: $sText               - a string value.
; Return values .: String(HEX)
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_StringTo7bitHex($sText)                  ; 8-bit octets representing 7-bit data. - GSM 03.38
	Local $aASCII = StringToASCIIArray($sText)
	Local $sBinData = ""
	Local $sBin = 0
	For $i = UBound($aASCII) - 1 To 0 Step -1
		$sBin = String(__ATCmd_Dec2Bin($aASCII[$i]))
		If StringLen($sBin) < 7 Then $sBin = StringFormat("%07s", $sBin)
		$sBinData &= $sBin
	Next
	Local $iLenBinData = StringLen($sBinData)
	Local $iLenPad = Mod($iLenBinData, 8)
	Local $sPad = ""
	If $iLenPad Then
		For $i = 1 To 8 - $iLenPad
			$sPad &= "0"
		Next
	EndIf
	$sBinData = $sPad & $sBinData
	$iLenBinData = StringLen($sBinData)
	Local $sHexData = ""
	For $i = 1 To $iLenBinData / 8
		$sHexData &= Hex(__ATCmd_Bin2Dec(StringMid($sBinData, StringLen($sBinData) + 1 - 8 * $i, 8)), 2)
	Next
	Return SetError($ATCmd_ERR_SUCCESS, $ATCmd_EXT_DEFAULT, $sHexData)
EndFunc   ;==>__ATCmd_StringTo7bitHex

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_StringToUCS2Hex
; Description ...: Encode string to UCS2
; Syntax ........: __ATCmd_StringToUCS2Hex($sUnicode)
; Parameters ....: $sUnicode            - a string value.
; Return values .: String(HEX)
; Author ........: Danyfirex
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_StringToUCS2Hex($sUnicode)
	Return StringTrimLeft(StringToBinary($sUnicode, $SB_UTF16BE), 2) ; Trim '0x'
EndFunc   ;==>__ATCmd_StringToUCS2Hex

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ATCmd_UCS2HexToString
; Description ...: Decode UCS2 to string
; Syntax ........: __ATCmd_UCS2HexToString($sData)
; Parameters ....: $sData               - UCS2 encoded data
; Return values .: Decoded string
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ATCmd_UCS2HexToString($sData)
	Return BinaryToString('0x' & $sData, $SB_UTF16BE)
EndFunc   ;==>__ATCmd_UCS2HexToString
#EndRegion ; ATCmd.au3 - PDU/UCS2 Enconde/Decode

#EndRegion ; ATCmd.au3 - Functions #INTERNAL_USE_ONLY#
