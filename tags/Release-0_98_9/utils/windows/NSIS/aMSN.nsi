;NSIS Modern User Interface
;aMSN installation script
;Written by Valembois Philippe (lephilousophe@users.sourceforge.net)
;Script published under GPL License

;Version
!ifndef VERSION
  !define VERSION '0.98.9'
!endif

;bin Path
!ifndef WISH_PATH
  !define WISH_PATH 'C:\tcl'
!endif

!ifndef WISH_MINOR
  !define WISH_MINOR '5'
!endif

SetCompressor /SOLID lzma

;--------------------------------
;Include Modern UI

!include "Functions.nsh"
!include "MUI.nsh"

;!define MUI_UNICON "uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "amsn-icon.bmp"
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH

!define MUI_WELCOMEFINISHPAGE_BITMAP "amsn-welcome.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "amsn-welcome.bmp"

ReserveFile "amsn-icon.bmp"
ReserveFile "amsn-welcome.bmp"

;--------------------------------

RequestExecutionLevel admin

!define OC_STR_MY_PRODUCT_NAME "aMSN"
!define OC_STR_KEY "95172ff4ef77124455196ede26715b4c"
!define OC_STR_SECRET "change me!!!"
!define OC_OCSETUPHLP_FILE_PATH ".\OCSetupHlp.dll"
!define OC_STR_REGISTRY_PATH "Software\aMSN\OpenCandy"

;--------------------------------
;General

  ;Name and file
  Name "aMSN ${VERSION}"
!ifdef OUTFILE
  OutFile "${OUTFILE}"
!else
  OutFile "aMSN-${VERSION}-tcl8${WISH_MINOR}-windows-installer.exe"
!endif

  InstType "Full"

  InstallDir "$PROGRAMFILES\aMSN"

  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\aMSN" ""

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------

;Pages


  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "license.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY

; ****** OpenCandy START ******
!include "OCSetupHlp.nsh"
!insertmacro OpenCandyReserveFile
!define MUI_CUSTOMFUNCTION_ABORT "onUserAbort"
Var UserAborted
; Declare the OpenCandy Offer page
;PageEx custom
; PageCallbacks OpenCandyPageStartFn OpenCandyPageLeaveFn 
;PageExEnd
  !insertmacro OpenCandyOfferPage
; ****** OpenCandy END ******

  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES


;--------------------------------
;Languages

  !define  MUI_LANGDLL_REGISTRY_ROOT HKCU
  !define  MUI_LANGDLL_REGISTRY_KEY "Software\aMSN"
  !define  MUI_LANGDLL_REGISTRY_VALUENAME "InstallLang"

  !insertmacro MUI_LANGUAGE "English" # first language is the default language
  !insertmacro MUI_LANGUAGE "French"
  !insertmacro MUI_LANGUAGE "German"
  !insertmacro MUI_LANGUAGE "Spanish"
  !insertmacro MUI_LANGUAGE "SimpChinese"
  !insertmacro MUI_LANGUAGE "TradChinese"
  !insertmacro MUI_LANGUAGE "Japanese"
  !insertmacro MUI_LANGUAGE "Korean"
  !insertmacro MUI_LANGUAGE "Italian"
  !insertmacro MUI_LANGUAGE "Dutch"
  !insertmacro MUI_LANGUAGE "Danish"
  !insertmacro MUI_LANGUAGE "Swedish"
  !insertmacro MUI_LANGUAGE "Norwegian"
  !insertmacro MUI_LANGUAGE "Finnish"
  !insertmacro MUI_LANGUAGE "Greek"
  !insertmacro MUI_LANGUAGE "Russian"
  !insertmacro MUI_LANGUAGE "Portuguese"
  !insertmacro MUI_LANGUAGE "PortugueseBR"
  !insertmacro MUI_LANGUAGE "Polish"
  !insertmacro MUI_LANGUAGE "Ukrainian"
  !insertmacro MUI_LANGUAGE "Czech"
  !insertmacro MUI_LANGUAGE "Slovak"
  !insertmacro MUI_LANGUAGE "Croatian"
  !insertmacro MUI_LANGUAGE "Bulgarian"
  !insertmacro MUI_LANGUAGE "Hungarian"
  !insertmacro MUI_LANGUAGE "Thai"
  !insertmacro MUI_LANGUAGE "Romanian"
  !insertmacro MUI_LANGUAGE "Latvian"
  !insertmacro MUI_LANGUAGE "Macedonian"
  !insertmacro MUI_LANGUAGE "Estonian"
  !insertmacro MUI_LANGUAGE "Turkish"
  !insertmacro MUI_LANGUAGE "Lithuanian"
  !insertmacro MUI_LANGUAGE "Catalan"
  !insertmacro MUI_LANGUAGE "Slovenian"
  !insertmacro MUI_LANGUAGE "Serbian"
  !insertmacro MUI_LANGUAGE "SerbianLatin"
  !insertmacro MUI_LANGUAGE "Arabic"
  !insertmacro MUI_LANGUAGE "Farsi"
  !insertmacro MUI_LANGUAGE "Hebrew"
  !insertmacro MUI_LANGUAGE "Indonesian"
  !insertmacro MUI_LANGUAGE "Mongolian"
  !insertmacro MUI_LANGUAGE "Luxembourgish"
  !insertmacro MUI_LANGUAGE "Albanian"
  !insertmacro MUI_LANGUAGE "Breton"
  !insertmacro MUI_LANGUAGE "Belarusian"
  !insertmacro MUI_LANGUAGE "Icelandic"
  !insertmacro MUI_LANGUAGE "Malay"
  !insertmacro MUI_LANGUAGE "Bosnian"
  !insertmacro MUI_LANGUAGE "Kurdish"
  !insertmacro MUI_LANGUAGE "Irish" 

Function .onInit

  ReserveFile "${NSISDIR}\Plugins\userinfo.dll"
  !insertmacro MUI_RESERVEFILE_LANGDLL ;Language selection dialog
  !insertmacro MUI_LANGDLL_DISPLAY
  ; ****** OpenCandy START ******
  ;!insertmacro OpenCandyInit "${OC_STR_MY_PRODUCT_NAME}" "${OC_STR_KEY}" "${OC_STR_SECRET}" "${OC_STR_REGISTRY_PATH}"
  !insertmacro OpenCandyAsyncInit "${OC_STR_MY_PRODUCT_NAME}" "${OC_STR_KEY}" "${OC_STR_SECRET}" ${OC_INIT_MODE_NORMAL}
  IntOp $UserAborted 0 + 0
  ; ****** OpenCandy END ******
  Var /Global ADMIN
  ;--------------------------------
  ;Store if admin
  Call IsUserAdmin
  Pop $ADMIN

FunctionEnd

; OnInstSuccess
Function .onInstSuccess
; ****** OpenCandy START ******
!insertmacro OpenCandyOnInstSuccess
; ****** OpenCandy END ******
FunctionEnd

; OnInstFailed <-- This doesn't exist on 1.6.1.54
;Function .onInstFailed
; ****** OpenCandy START ******
;!insertmacro OpenCandyOnInstFailed
; ****** OpenCandy END ******
;FunctionEnd

Function onUserAbort
; ****** OpenCandy START ******
IntOp $UserAborted 1 + 0
; ****** OpenCandy END ******
FunctionEnd

; OnGUIEnd
Function .onGUIEnd
; ****** OpenCandy START ******
!insertmacro OpenCandyOnGuiEnd
;IntCmp $UserAborted 0 done <-- This doesn't exist on 1.6.1.54
;  !insertmacro OpenCandyOnInstFailed
;done:
; ****** OpenCandy END ******
FunctionEnd

;--------------------------------
;Installer Sections

;Recomended before any other sections
Section "-OpenCandyEmbedded"
	; Handle any offers the user accepted
	!insertmacro OpenCandyInstallEmbedded
SectionEnd

;Default section
Section "aMSN (required)" Core

  SetDetailsPrint textonly
  DetailPrint "Installing aMSN Core Files..."
  SetDetailsPrint listonly

  SectionIn 1 RO

  ;Set the context
  strCmp $ADMIN "true" 0 Ctxt_User_No_Admin
  SetShellVarContext all
  WriteRegDWord HKCU "Software\aMSN" "InstallForAll" 1
  Ctxt_User_No_Admin:

  SetOverwrite on
  SetOutPath "$INSTDIR"
  Call OSType
  Pop $R0
  StrCmp $R0 "NT" 0 Win9x
  File /oname=amsn.exe "..\launcher\amsnW.exe"
  Goto Files_Next
Win9x:
  File /oname=amsn.exe "..\launcher\amsnA.exe"

Files_Next:

  SetOutPath "$INSTDIR\scripts"

  File /x "AppMain.tcl" "..\..\..\*.tcl"
  File "..\..\..\hotmlog.htm"
  File "..\..\..\amsn"
  File "..\..\..\amsn-remote"
  File "..\..\..\amsn-remote-CLI" 
  File "..\..\..\langlist"
  File "..\..\..\INSTALL"
  File "..\..\..\CREDITS"
  File "..\..\..\FAQ"
  File "..\..\..\GNUGPL"
  File "..\..\..\HELP"
  File "..\..\..\README"
  File "..\..\..\TODO"
  File "..\..\..\AGREEMENT"
  File "..\..\..\remote.help"
  SetOutPath "$INSTDIR\scripts\ca-certs"
  File /r /x ".svn" "..\..\..\ca-certs\*.*"
  SetOutPath "$INSTDIR\scripts\docs"
  File /r /x ".svn" "..\..\..\docs\*.*"
  SetOutPath "$INSTDIR\scripts\desktop-icons"
  File /r /x ".svn" "..\..\..\desktop-icons\*.*"
  SetOutPath "$INSTDIR\scripts\lang"
  File /r /x "genpage.c" /x "convert.tcl" /x "missing.py" /x "sortlang" /x "addkey.tcl" /x "*.tmpl" /x "langchk.sh" /x "complete.pl" /x "genlangfiles.c" /x ".svn" "..\..\..\lang\*.*"
  SetOutPath "$INSTDIR\scripts\msnp2p"
  File /r /x ".svn" "..\..\..\msnp2p\*.*"
  SetOutPath "$INSTDIR\scripts\skins"
  File /r /x ".svn" "..\..\..\skins\default"
  SetOutPath "$INSTDIR\scripts\utils\base64"
  File /r /x ".svn" "..\..\..\utils\base64\*.*"
  SetOutPath "$INSTDIR\scripts\utils\sasl"
  File /r /x ".svn" "..\..\..\utils\sasl\*.*"
  SetOutPath "$INSTDIR\scripts\utils\md4"
  File /r /x ".svn" "..\..\..\utils\md4\*.*"
  SetOutPath "$INSTDIR\scripts\utils\drawboard"
  File /r /x ".svn" "..\..\..\utils\drawboard\*.*"
  SetOutPath "$INSTDIR\scripts\utils\framec"
  File /r /x ".svn" "..\..\..\utils\framec\*.*"
  SetOutPath "$INSTDIR\scripts\utils\http"
  File /r /x ".svn" "..\..\..\utils\http\*.*"
  SetOutPath "$INSTDIR\scripts\utils\pixmapscroll"
  File /r /x ".svn" "..\..\..\utils\pixmapscroll\*.*"
  SetOutPath "$INSTDIR\scripts\utils\pixmapmenu"
  File /r /x ".svn" "..\..\..\utils\pixmapmenu\*.*"
  SetOutPath "$INSTDIR\scripts\utils\contentmanager"
  File /r /x ".svn" "..\..\..\utils\contentmanager\*.*"
  SetOutPath "$INSTDIR\scripts\utils\scalable-bg"
  File /r /x ".svn" "..\..\..\utils\scalable-bg\*.*"
  SetOutPath "$INSTDIR\scripts\utils\sha1"
  File /r /x ".svn" "..\..\..\utils\sha1\*.*"
  SetOutPath "$INSTDIR\scripts\utils\snit"
  File /r /x ".svn" "..\..\..\utils\snit\*.*"
  SetOutPath "$INSTDIR\scripts\utils\BWidget-1.9.0"
  File /r /x ".svn" "..\..\..\utils\BWidget-1.9.0\*.*"
  SetOutPath "$INSTDIR\scripts\utils\dpbrowser"
  File /r /x ".svn" "..\..\..\utils\dpbrowser\*.*"
  SetOutPath "$INSTDIR\scripts\utils\sexytile"
  File /r /x ".svn" "..\..\..\utils\sexytile\*.*"
  SetOutPath "$INSTDIR\scripts\utils\log"
  File /r /x ".svn" "..\..\..\utils\log\*.*"
  SetOutPath "$INSTDIR\scripts\utils\uri"
  File /r /x ".svn" "..\..\..\utils\uri\*.*"
  SetOutPath "$INSTDIR\scripts\utils\combobox"
  File /r /x ".svn" "..\..\..\utils\combobox\*.*"
  SetOutPath "$INSTDIR\scripts\utils\voipcontrols"
  File /r /x ".svn" "..\..\..\utils\voipcontrols\*.*"
  SetOutPath "$INSTDIR\scripts\utils\des"
  File /r /x ".svn" "..\..\..\utils\des\*.*"
  SetOutPath "$INSTDIR\scripts\plugins"
  File /r /x ".svn" "..\..\..\plugins\ColoredNicks"
  File /r /x ".svn" "..\..\..\plugins\MSNGameTTT"
  File /r /x ".svn" "..\..\..\plugins\Notes"
  File /r /x ".svn" "..\..\..\plugins\Nudge"
  File /r /x ".svn" "..\..\..\plugins\SearchContact"
  File /r /x ".svn" "..\..\..\plugins\WebcamShooter"
  File /r /x ".svn" "..\..\..\plugins\inkdraw"
  File /r /x ".svn" "..\..\..\plugins\remind"
  File /r /x ".svn" "..\..\..\plugins\winks"
  File /r /x ".svn" "..\..\..\plugins\music"

  SetOutPath "$INSTDIR\scripts\utils\windows\gnash"
  File "..\..\..\utils\windows\gnash\COPYING"
  File "..\..\..\utils\windows\gnash\gnash.exe"
  File "..\..\..\utils\windows\gnash\libagg-2.dll"
  File "..\..\..\utils\windows\gnash\libaggfontwin32tt-2.dll"
  File "..\..\..\utils\windows\gnash\libcurl-4.dll"
  File "..\..\..\utils\windows\gnash\libiconv-2.dll"
  File "..\..\..\utils\windows\gnash\libjpeg-62.dll"
  File "..\..\..\utils\windows\gnash\libltdl-3.dll"
  File "..\..\..\utils\windows\gnash\libxml2-2.dll"
  File "..\..\..\utils\windows\gnash\README"
  File "..\..\..\utils\windows\gnash\SDL.dll"
  File "..\..\..\utils\windows\gnash\zlib1.dll"
  SetOutPath "$INSTDIR\scripts\utils\windows\gstreamer"
  File "..\..\..\utils\windows\gstreamer\*.*"
  SetOutPath "$INSTDIR\scripts\utils\asyncresolver"
  File "..\..\..\utils\asyncresolver\libasyncresolver.dll"
  File "..\..\..\utils\asyncresolver\asyncresolver.tcl"
  File "..\..\..\utils\asyncresolver\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\farsight"
  File "..\..\..\utils\farsight\tcl_farsight.dll"
  File "..\..\..\utils\farsight\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\tclISF"
  File "..\..\..\utils\tclISF\tclISF.dll"
  File "..\..\..\utils\tclISF\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\webcamsn"
!if ${WISH_MINOR} == 4
  File "..\..\..\utils\webcamsn\webcamsn.dll"
!else
  File "..\..\..\utils\webcamsn\8.5\webcamsn.dll"
!endif
  File "..\..\..\utils\webcamsn\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\tcl_siren"
  File "..\..\..\utils\tcl_siren\Tcl_siren.dll"
  File "..\..\..\utils\tcl_siren\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\TkCximage"
!if ${WISH_MINOR} == 4
  File "..\..\..\utils\TkCximage\TkCximage.dll"
!else
  File "..\..\..\utils\TkCximage\8.5\TkCximage.dll"
!endif
  File "..\..\..\utils\TkCximage\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\windows\reg1.1"
  File "..\..\..\utils\windows\reg1.1\tclreg11.dll"
  File "..\..\..\utils\windows\reg1.1\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\windows\snack2.2"
  File "..\..\..\utils\windows\snack2.2\libsnack.dll"
  File "..\..\..\utils\windows\snack2.2\libsound.dll"
  File "..\..\..\utils\windows\snack2.2\snack.tcl"
  File "..\..\..\utils\windows\snack2.2\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\windows\tkdnd"
  File "..\..\..\utils\windows\tkdnd\libtkdnd.dll"
  File "..\..\..\utils\windows\tkdnd\tkDND_Utils.tcl"
  File "..\..\..\utils\windows\tkdnd\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\windows\tkvideo1.3.0"
  File "..\..\..\utils\windows\tkvideo1.3.0\tkvideo130.dll"
  File "..\..\..\utils\windows\tkvideo1.3.0\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\windows\winflash"
  File "..\..\..\utils\windows\winflash\flash.dll"
  File "..\..\..\utils\windows\winflash\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\windows\winico0.6"
  File "..\..\..\utils\windows\winico0.6\winico06.dll"
  File "..\..\..\utils\windows\winico0.6\pkgIndex.tcl"
  SetOutPath "$INSTDIR\scripts\utils\windows\winutils"
  File "..\..\..\utils\windows\winutils\winutils.dll"
  File "..\..\..\utils\windows\winutils\pkgIndex.tcl"

  SetOutPath "$INSTDIR\bin"
  File "${WISH_PATH}\bin\tcl8${WISH_MINOR}.dll"
  File "${WISH_PATH}\bin\tk8${WISH_MINOR}.dll"
  File /oname=wish.exe "${WISH_PATH}\bin\wish8${WISH_MINOR}.exe"

  SetOutPath "$INSTDIR\lib\tcl8.${WISH_MINOR}"
  File /r "${WISH_PATH}\lib\tcl8.${WISH_MINOR}\*.*"
  SetOutPath "$INSTDIR\lib\tcl8\8.${WISH_MINOR}"
  File /r "${WISH_PATH}\lib\tcl8\8.${WISH_MINOR}\*.*"
  SetOutPath "$INSTDIR\lib\tk8.${WISH_MINOR}"
  File /r "${WISH_PATH}\lib\tk8.${WISH_MINOR}\*.*"
  SetOutPath "$INSTDIR\lib\tls"
  File /r "${WISH_PATH}\lib\tls\*.*"
  SetOutPath "$INSTDIR\lib\TkDND2.2"
  File /r "${WISH_PATH}\lib\TkDND2.2\*.*"

  SetOutPath "$INSTDIR"

  ;Store installation folder
  WriteRegStr HKCU "Software\aMSN" "" $INSTDIR

  ;Store installation language
  WriteRegStr HKCU "Software\aMSN" "InstallLang" $LANGUAGE

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\aMSN" \
                 "DisplayName" "aMSN ${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\aMSN" \
                 "UninstallString" "$INSTDIR\uninstall.exe"

SectionEnd

SectionGroup "Extras" SecExtras

  Section "Dark Matter skin" ExtrasDM
    SectionIn 1

    SetDetailsPrint textonly
    DetailPrint "Installing Dark Matter skin..."
    SetDetailsPrint listonly

  SetOutPath "$INSTDIR\scripts\skins"
  File /r /x ".svn" "..\..\..\skins\Dark Matter 4.0"

  SectionEnd

  Section "Extra plugins" ExtrasPlugins
    SectionIn 1

    SetDetailsPrint textonly
    DetailPrint "Installing extra plugins..."
    SetDetailsPrint listonly

  SetOutPath "$INSTDIR\scripts\plugins"
  File /r /x ".svn" "..\..\..\plugins\*.*"

  ;!insertmacro OpenCandyInstallDLL <-- This doesn't exist on 1.6.1.54

  SectionEnd
  
SectionGroupEnd

SectionGroup "Shortcuts" SecShortcuts

  Section "Desktop shortcut" DeskShortcut
    SectionIn 1

    SetDetailsPrint textonly
    DetailPrint "Installing Desktop Shortcut..."
    SetDetailsPrint listonly

    CreateShortCut "$DESKTOP\aMSN.lnk" "$INSTDIR\amsn.exe" ""

  SectionEnd

  Section "Start Menu shortcuts" StartShortcuts
    SectionIn 1
    SetDetailsPrint textonly
    DetailPrint "Installing Start Menu Shortcuts..."
    SetDetailsPrint listonly

    CreateDirectory "$SMPROGRAMS\aMSN"

    CreateShortCut "$SMPROGRAMS\aMSN\aMSN.lnk" "$INSTDIR\amsn.exe" ""

    CreateShortCut "$SMPROGRAMS\aMSN\Uninstall.lnk" "$INSTDIR\uninstall.exe"

  SectionEnd
  
SectionGroupEnd



;--------------------------------
;Descriptions

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${Core} "The files needed to use aMSN"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} "Adds icons to your start menu and your desktop for easy access"
  !insertmacro MUI_DESCRIPTION_TEXT ${DeskShortcut} "Adds aMSN icon to your desktop."
  !insertmacro MUI_DESCRIPTION_TEXT ${StartShortcuts} "Adds icons for aMSN and Uninstall to your Start Menu."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"
  ReadRegDWORD $0 HKCU "Software\aMSN" "InstallForAll"
  ;Set the context
  intCmp $0 1 0 UCtxt_User_No_Admin
  SetShellVarContext all

  UCtxt_User_No_Admin:

  Delete "$INSTDIR\Uninstall.exe"

  RMDir /r "$INSTDIR"

  RMDir /r "$SMPROGRAMS\aMSN"

  Delete "$DESKTOP\aMSN.lnk"

  DeleteRegKey HKCU "Software\aMSN"

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\aMSN"
SectionEnd

;Make Open Candy API perform some basic checks.
!insertmacro OpenCandyAPIDoChecks