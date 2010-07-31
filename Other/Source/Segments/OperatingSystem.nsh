${SegmentFile}

!include WinVer.nsh

!macro _OperatingSystem_CheckOS Check Value
	ClearErrors
	${ReadLauncherConfig} $0 Launch ${Value}
	${Select} $0
		${Case} 2000
			${IfNotThen} ${At${Check}Win2000}   ${|} StrCpy $1 bad-os ${|}
		${Case} XP
			${IfNotThen} ${At${Check}WinXP}     ${|} StrCpy $1 bad-os ${|}
		${Case} 2003
			${IfNotThen} ${At${Check}Win2003}   ${|} StrCpy $1 bad-os ${|}
		${Case} Vista
			${IfNotThen} ${At${Check}WinVista}  ${|} StrCpy $1 bad-os ${|}
		${Case} 2008
			${IfNotThen} ${At${Check}Win2008}   ${|} StrCpy $1 bad-os ${|}
		${Case} 7
			${IfNotThen} ${At${Check}Win7}      ${|} StrCpy $1 bad-os ${|}
		${Case} "2008 R2"
			${IfNotThen} ${At${Check}Win2008R2} ${|} StrCpy $1 bad-os ${|}
		${Default}
			${IfNot} ${Errors} ; If it's defined and we're here, it's a bad value
				${InvalidValueError} [Launch]:${Value} $0
			${EndIf}
	${EndSelect}

	${If} $1 == bad-os
		MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST|MB_SETFOREGROUND "$(LauncherIncompatible${Value})"
		Quit
	${EndIf}
!macroend

${Segment.onInit}
	!insertmacro _OperatingSystem_CheckOS Least MinOS
	!insertmacro _OperatingSystem_CheckOS Most MaxOS
!macroend
