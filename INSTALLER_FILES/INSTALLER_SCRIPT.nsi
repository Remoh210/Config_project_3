;NSIS Modern User Interface
;Start Menu Folder Selection Example Script
;Written by Joost Verburg

;--------------------------------
;Include Modern UI
  !include "MUI2.nsh"
  !addplugindir "nsis_plugins"
  !include LogicLib.nsh
;--------------------------------
;General
  !define MUI_WELCOMEPAGE_TEXT "GDP Bondarenko Bogdan$\r$\nGame made for AI class$\r$\nMenu made for configuration project 1.$\r$\nInstaller made for configuration project 2 and 3."

  ;!insertmacro MUI_PAGE_LICENSE "1.txt"
  ;Name and file
  Name "X-Wing"
  OutFile "X-Wing_Installer.exe"

  ;Default installation folder
  InstallDir "C:\cnd\BondarenkoBogdan\x-wing"
  
  ;Get installation folder from registry if available
  ;InstallDirRegKey HKCU "Software\Modern UI Test" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

;--------------------------------
;Variables

  Var StartMenuFolder

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  Var Dialog
  Var Label1
  Var Label2
  Var Email
  Var Password
  Var PasswordText
  Var EmailText
;--------------------------------
;Pages
  !insertmacro MUI_PAGE_WELCOME
  Page custom nsDialogsPage nsDialogsPageLeave
  Page custom Validate "Validate" title
  !insertmacro MUI_PAGE_LICENSE "license.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  
  ;Start Menu Folder Page Configuration
  
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "SOFTWARE\INFO6025\BONDARENKOBOGDAN" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "x-wing"
  
  !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
  
  !insertmacro MUI_PAGE_INSTFILES
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Function nsDialogsPage
		nsDialogs::Create 1018
	Pop $Dialog
	
	${If} $Dialog == error
		Abort
	${EndIf}
	
	${NSD_CreateLabel} 0 0 100% 12u "Enter your email"
	Pop $Label1
	
	${NSD_CreateText} 0 24u 100% 12u "bogdan@mail.com"
	Pop $Email

	${NSD_CreateLabel} 0 48u 100% 12u "Enter your password"
	Pop $Label2
	
	${NSD_CreateText} 0 72u 100% 12u "superpassword123"
	Pop $Password
	nsDialogs::Show
FunctionEnd




;Exit callback, get text from variables
Function nsDialogsPageLeave
${NSD_GetText} $Email $EmailText
${NSD_GetText} $Password $PasswordText
FunctionEnd




function Validate
  MessageBox MB_OK "you entered: $EmailText and: $PasswordText"
  Delete $EXEDIR\serial.txt
  inetc::post "email=$EmailText&password=$PasswordText" "http://localhost/nsi/auth_server.php?email=$EmailText&password=$PasswordText" "$EXEDIR\serial.txt"
  Pop $0
  ;MessageBox MB_OK "Server Status: $0"

  FileOpen $0 "$EXEDIR\serial.txt" r
  FileRead $0 $1
  Delete "$EXEDIR\serial.txt"
  MessageBox MB_OK "Your license key: $1"

  ${If} $1 == "CNDP3BONDARENKOBOGDAN"
  MessageBox MB_OK "License is Valid"
  ${Else}
  MessageBox MB_OK "Bad luck, no liscense for you!"
  Quit
  ${EndIf}
functionEnd

section
InitPluginsDir
  SetOutpath "$PLUGINSDIR"
  File "Project.zip"
  SetOutpath "$INSTDIR"
  nsisunz::UnzipToLog "$PLUGINSDIR\Project.zip" "$INSTDIR"
	RMDir /r "$INSTDIR\extra_assets"
  Pop $0
SectionEnd

Section
  FileOpen $0 "$INSTDIR\serial.txt" w
  FileWrite $0 $1
  FileClose $0
  Pop $0
  
SectionEnd


Section "Game files(required)" SecGameFiles
  
	SectionIn RO

  SetOutPath "$INSTDIR"

  
  SetRegView 64
  WriteRegStr HKLM "SOFTWARE\INFO6025\BONDARENKOBOGDAN" "" $INSTDIR
  
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    
  ;Create shortcuts
  CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
  CreateShortcut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
	CreateShortcut "$SMPROGRAMS\$StartMenuFolder\x-wing.lnk" "$INSTDIR\GameEngine.exe"
  
  !insertmacro MUI_STARTMENU_WRITE_END

SectionEnd

Section /o "Additional assets" SecModules
  
  SetOutPath "$INSTDIR"
  nsisunz::UnzipToLog /file "extra_assets\dummy1.png" "$PLUGINSDIR\Project.zip" "$INSTDIR"
  nsisunz::UnzipToLog /file "extra_assets\dummy2.png" "$PLUGINSDIR\Project.zip" "$INSTDIR"
  nsisunz::UnzipToLog /file "extra_assets\dummy3.png" "$PLUGINSDIR\Project.zip" "$INSTDIR"
  nsisunz::UnzipToLog /file "extra_assets\dummy4.png" "$PLUGINSDIR\Project.zip" "$INSTDIR"
  nsisunz::UnzipToLog /file "extra_assets\dummy5.png" "$PLUGINSDIR\Project.zip" "$INSTDIR"
SectionEnd
;--------------------------------
;Descriptions
  
  ;Language strings
  LangString descSecModules ${LANG_ENGLISH} "Assets"

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecModules} $(descSecModules)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ;For safety reasons specifying all folders and files in $INSTDIR
  RMDir /r "$INSTDIR\assets"
  RMDir /r "$INSTDIR\config"
  RMDir /r "$INSTDIR\localization"
  RMDir /r  "$INSTDIR\scenes"
  RMDir /r "$INSTDIR\extra_assets"
  Delete "$INSTDIR\GameEngine.exe"
  Delete "$INSTDIR\freetype271MT.dll"
  Delete "$INSTDIR\gtest.dll"
  Delete "$INSTDIR\libcurl-d.dll"
  Delete "$INSTDIR\serial.txt"
  Delete "$INSTDIR\Uninstall.exe"

  ;Will work Only if $INSTDIR is completely empty
  RMDir "$INSTDIR"
  
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
    
  Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
  Delete "$SMPROGRAMS\$StartMenuFolder\x-wing.lnk"
  RMDir "$SMPROGRAMS\$StartMenuFolder"
  SetRegView 64
  DeleteRegKey HKLM "SOFTWARE\INFO6025"

SectionEnd