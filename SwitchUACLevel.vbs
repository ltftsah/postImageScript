'The sample scripts are not supported under any Microsoft standard support
'program or service. The sample scripts are provided AS IS without warranty
'of any kind. Microsoft further disclaims all implied warranties including,
'without limitation, any implied warranties of merchantability or of fitness for
'a particular purpose. The entire risk arising out of the use or performance of
'the sample scripts and documentation remains with you. In no event shall
'Microsoft, its authors, or anyone else involved in the creation, production, or
'delivery of the scripts be liable for any damages whatsoever (including,
'without limitation, damages for loss of business profits, business interruption,
'loss of business information, or other pecuniary loss) arising out of the use
'of or inability to use the sample scripts or documentation, even if Microsoft
'has been advised of the possibility of such damages.

' elevate privilege to execute the code
If Not WScript.Arguments.Named.Exists("elevate") Then
  CreateObject("Shell.Application").ShellExecute WScript.FullName _
    , """" & WScript.ScriptFullName & """ /elevate", "", "runas", 1
  WScript.Quit
End If

' utils
Function ReadKey(keyPath)
	Set WshShell = CreateObject("WScript.Shell")

	keyVal = ""
	On Error Resume Next
	keyVal = WshShell.RegRead(keyPath)
	On Error GOTO 0
	ReadKey = keyVal

	Set WshShell = Nothing
End Function
' utils ---------------


KeyPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\"
ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin"
PromptOnSecureDesktop_Name = "PromptOnSecureDesktop"

Function GetUACLevel()
	ConsentPromptBehaviorAdmin_Value = ReadKey(KeyPath & ConsentPromptBehaviorAdmin_Name)
	PromptOnSecureDesktop_Value = ReadKey(KeyPath & PromptOnSecureDesktop_Name)

	If ConsentPromptBehaviorAdmin_Value = 0 And PromptOnSecureDesktop_Value = 0 Then
		GetUACLevel = "Never notify"
	ElseIf ConsentPromptBehaviorAdmin_Value = 5 And PromptOnSecureDesktop_Value = 0 Then
		GetUACLevel = "Notify me only when apps try to make changes to my computer(do not dim my desktop)"
	ElseIf ConsentPromptBehaviorAdmin_Value = 5 And PromptOnSecureDesktop_Value = 1 Then
		GetUACLevel = "Notify me only when apps try to make changes to my computer(default)"
	ElseIf ConsentPromptBehaviorAdmin_Value = 2 And PromptOnSecureDesktop_Value = 1 Then
		GetUACLevel = "Always notify"
	Else
		GetUACLevel = "Unknown"
	End If
End Function


'
'    VBScript run as administrator
'    Level   		UAC Description                         ConsentPromptBehaviorAdmin    		PromptOnSecureDesktop
'	    0		       Never notIfy			 				                           0				                      0
'	    1		       NotIfy me only(do not dim my desktop)	 			       5				                      0
'	    2		       NotIfy me only(default)	  				                 5				                      1
'	    3		       Always notIfy							                         2                   				    1
'
Function SetUACLevel(level)
	If level = 0 Or level = 1 Or level = 2 Or level = 3 Then
		ConsentPromptBehaviorAdmin_Value = 5
		PromptOnSecureDesktop_Value = 1

		Select Case level
			case 0
				ConsentPromptBehaviorAdmin_Value = 0
				PromptOnSecureDesktop_Value = 0
			case 1
				ConsentPromptBehaviorAdmin_Value = 5
				PromptOnSecureDesktop_Value = 0
			case 2
				ConsentPromptBehaviorAdmin_Value = 5
				PromptOnSecureDesktop_Value = 1
			case 3
				ConsentPromptBehaviorAdmin_Value = 2
				PromptOnSecureDesktop_Value = 1
		End Select

		Set WshShell = CreateObject("WScript.Shell")
		WshShell.RegWrite KeyPath & ConsentPromptBehaviorAdmin_Name, ConsentPromptBehaviorAdmin_Value, "REG_DWORD"
		WshShell.RegWrite KeyPath & PromptOnSecureDesktop_Name, PromptOnSecureDesktop_Value, "REG_DWORD"
		Set WshShell = Nothing

		WScript.echo GetUACLevel()
	Else
		WScript.echo "No supported level"
	End If
End Function

' get current UAC level
WScript.echo GetUACLevel()

' set UAC level
SetUACLevel(2)
