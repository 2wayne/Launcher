${SegmentFile}

!include UAC.nsh

Var RunAsAdmin
Var RunningAsAdmin

; Macro for producing the right message box based on the error code {{{1
!macro CaseUACCodeAlert CODE FORCEMESSAGE TRYMESSAGE
	!if "${CODE}" == ""
		${Default}
	!else
		${Case} "${CODE}"
	!endif
		${If} $RunAsAdmin == force
			MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST|MB_SETFOREGROUND "${FORCEMESSAGE}"
			Abort
		${ElseIf} $RunAsAdmin == try
			MessageBox MB_OK|MB_ICONINFORMATION|MB_TOPMOST|MB_SETFOREGROUND "${TRYMESSAGE}"
		${EndIf}
		${Break}
!macroend
!define CaseUACCodeAlert "!insertmacro CaseUACCodeAlert"


${Segment.onInit} ; {{{1
	; Run as admin if needed {{{2
	${ReadLauncherConfig} $RunAsAdmin Launch RunAsAdmin
	${If} $RunAsAdmin == force
	${OrIf} $RunAsAdmin == try
		Elevate: ; Attempt to elevate to admin {{{2
			!insertmacro UAC_RunElevated
			${Switch} $0
				; Success in changing credentials in some way {{{3
				${Case} 0
					${IfThen} $1 = 1 ${|} Abort ${|} ; This is the user-level process and the admin-level process has finished successfully.
					${If} $3 <> 0 ; This is the admin-level process: great!
						StrCpy $RunningAsAdmin true
						${Break}
					${EndIf}
					${If} $1 = 3 ; RunAs completed successfully, but with a non-admin user
						${If} $RunAsAdmin == force
							MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION|MB_TOPMOST|MB_SETFOREGROUND "$(LauncherRequiresAdmin)$\r$\n$\r$\n$(LauncherNotAdminTryAgain)" IDRETRY Elevate
							Abort
						${ElseIf} $RunAsAdmin == try
							MessageBox MB_ABORTRETRYIGNORE|MB_ICONEXCLAMATION|MB_TOPMOST|MB_SETFOREGROUND "$(LauncherNotAdminLimitedFunctionality)$\r$\n$\r$\n$(LauncherNotAdminLimitedFunctionalityTryAgain)" IDRETRY Elevate IDIGNORE RunAsAdminEnd
							Abort
						${EndIf}
					${EndIf}
					; If we're still here, we'll fall through as there's no ${Break}
				; Explicitly failed to get admin {{{3
				${CaseUACCodeAlert} 1233 \
					"$(LauncherRequiresAdmin)" \
					"$(LauncherNotAdminLimitedFunctionality)"
				; Windows logon service unavailable {{{3
				${CaseUACCodeAlert} 1062 \
					"$(LauncherAdminLogonServiceNotRunning)" \
					"$(LauncherNotAdminLimitedFunctionality)"
				; Other error, not sure what {{{3
				${CaseUACCodeAlert} "" \
					"$(LauncherAdminError)$\r$\n$(LauncherNotAdminLimitedFunctionality)" \
					"$(LauncherAdminError)$\r$\n$(LauncherNotAdminLimitedFunctionality)"
			${EndSwitch}

		RunAsAdminEnd:
	${EndIf}
!macroend