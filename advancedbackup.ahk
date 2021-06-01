#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
#Persistent
;#Include C:\Desktop\Programlar\AHK Scripts\tab2m.exe

/*
Idealist:

make a folder that is immune to autodelete inside Backup to store side stuff like options and scripts
*/



WinGetTitle, Title, ahk_exe GRW.exe
WinGet, InstallLocation, ProcessPath, %Title%

options=%A_AppData%\Backup\backup.ini
tabahk=%A_AppData%\Backup\tab2m.exe

Loop, 2
{
if FileExist(options)
{
flagcheck(flagcheckreturn, options)
if flagcheckreturn = 1
{
ahkcheck(ahkcheckreturn, tabahk)
}
else break
if ahkcheckreturn=1
{
run %tabahk%
break
}
else createahk()
run %tabahk%
}
else msgbox(options)
}


flagcheck(byref flagcheckreturn, byref options)
{
IniRead, flagcheckreturn, %options%, Settings, RemapTabKey
}


ahkcheck(byref ahkcheckreturn, byref tabahk)
{
if FileExist(tabahk)
{
ahkcheckreturn=1
}
else ahkcheckreturn=0
}


createahk()
{
;content := "#SingleInstance Force`n#NoTrayIcon`nSetTimer process_watcher, 5000`n#IfWinActive, ahk_exe GRW.exe`ntab::m`nm::tab`nprocess_watcher:`nProcess Exist, GRW.exe`nIf ErrorLevel = 0`nExitApp`nelse return"
;FileAppend, %content%, %A_AppData%\Backup\tabahk.txt
;FileMove, %A_AppData%\Backup\tabahk.txt, %A_AppData%\Backup\tab.ahk
FileInstall, C:\Desktop\Programlar\AHK Scripts\tab2m.exe, %A_appdata%\Backup\tab2m.exe, 1
FileSetAttrib, +H, %A_AppData%\Backup\tab2m.exe
}


msgbox(byref options)
{
FileCreateDir, %A_AppData%\Backup
Msgbox, 4, Assign Map Toggle Key to Tab?, Do you want to assign your map toggle key to Tab? This will only be asked once.
IfMsgBox Yes 
{
FileAppend, ,%options%
IniWrite, 1, %options%, Settings, RemapTabKey
FileSetAttrib, +H, %options%
}
IfMsgBox No
{
FileAppend, ,%options%
IniWrite, 0, %options%, Settings, RemapTabKey
FileSetAttrib, +H, %options%
}
}

AdressCheck:
IniRead adresscheck, %options%, Settings, SavegameLocation, Invalid
if (adresscheck="Invalid")
{
Loop, Files, C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\savegames\*, DR
{
    if A_LoopFileName=1771
    {
        if installdetected=1
        {
            wintextmove("Multiple savegame files for different installations of Ghost Recon: Wildlands found")
            FileSelectFolder, SaveAdress, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, 0, Multiple savegame files for different installations of Ghost Recon: Wildlands found in C:\Program Files (x86). Please select your desired savegame folder corresponding to the installation indicated by:`nUbisoft\Ubisoft Game Launcher\savegames\{your-unique-ubisoft-id} and the subfolder \1771 for Ubisoft Connect or the subfolder \3559 for Steam installations.
            break
        }
        Else
        {
        installdetected=1
        SaveAdress := A_LoopFileFullPath
        steaminstall=0
        }
    }
    if A_LoopFileName=3559
    {
         if installdetected=1
        {
            wintextmove("Multiple savegame files for different installations of Ghost Recon: Wildlands found")
            FileSelectFolder, SaveAdress, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, 0, Multiple savegame files for different installations of Ghost Recon: Wildlands found in C:\Program Files (x86). Please select your desired savegame folder corresponding to the installation indicated by:`nUbisoft\Ubisoft Game Launcher\savegames\{your-unique-ubisoft-id} and the subfolder \1771 for Ubisoft Connect or the subfolder \3559 for Steam installations.
            break
        }
         Else
        {
        installdetected=1
        SaveAdress := A_LoopFileFullPath
        steaminstall=1
        }
    } 
}
if steaminstall!=1 and steaminstall!=0
{
    wintextmove("No savegame files for Ghost Recon: Wildlands found in C:\Program Files (x86)")
    FileSelectFolder, SaveAdress, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, 0, No savegame files for Ghost Recon: Wildlands found in C:\Program Files (x86). If you have a custom install location for your Ubisoft Launcher or use another main drive than C:, select your savegame folder indicated by:`nUbisoft\Ubisoft Game Launcher\savegames\{your-unique-ubisoft-id} and the subfolder \1771 for Ubisoft Connect or the subfolder \3559 for Steam installations.
}
IniWrite, %SaveAdress%, %options%, Settings, SavegameLocation
Gosub BackupRoutine
}
else Gosub BackupRoutine
return



BackupRoutine:
FormatTime, time, ,dd-MM-yyyy HH.mm
IniRead, Adress, %options%, Settings, SavegameLocation
FileCreateDir, %A_AppData%\Backup\%time%
FileCopyDir, %Adress%, %A_AppData%\Backup\%time%, 1
SetTimer, BackupRoutine, 60000 ;change how often backups are made
SetTimer, RemoveFiles, 60000 ; so that the file limit is not exceeded while the loop is on hold (10 min)
SetTimer, GameExit, 30000
return

RemoveFiles:
ItemCount=0
Loop, Files, %A_AppData%\Backup\*, D
{
ItemCount+=1
}
if(ItemCount>10){
Rest := ItemCount - 10
Loop, %rest%
{
Time_Orig := A_Now
    Loop, Files,  %A_AppData%\Backup\*, D
        {
        If (A_LoopFileTimeCreated < Time_Orig)
            {
            Time_Orig := A_LoopFileTimeCreated
            OldestFolder := A_LoopFileName
            }
        }
FileRemoveDir %A_AppData%\Backup\%OldestFolder%, 1
}
}
return

GameExit:
Process Exist, GRW.exe
If ErrorLevel = 0
{
    Files := ""
    Loop, Files, %A_AppData%\Backup\*, D
    {
        Files .= A_LoopFileTimeCreated ":" A_LoopFileName "`n"
    }
    Sort, Files, NR
    Files := StrSplit(Files, "`n")
    AlmostFile:= % Files[3]
    UnLBFolder:= % Files[1]
    CorrectedFile:= StrSplit(AlmostFile, ":")
    CorrectedLBFolder := StrSplit (UnLBFolder, ":")
    LBFolder := % CorrectedLBFolder [2]
    SafeBackupFile:= % CorrectedFile[2]

    ;find newest file and format its time to be readable for the user

    FileGetTime, UnformattedLatestBackupTime, %A_AppData%\Backup\%LBFolder%, C
    FormatTime, LatestBackupTime, %UnformattedLatestBackupTime%, dd/MM/yyyy HH:mm:ss
    SetTimer, ChangeButtonNames, 20
    msgbox, 3, Restore backup?, It appears that you have stopped playing Ghost Recon: Wildlands. The latest backup was saved at %LatestBackupTime%. Do you want to restore to the third latest save, choose a custom save to restore or quit?
    IfMsgBox Yes ;safe restore
    {
        FileCopyDir, %A_AppData%\Backup\%SafeBackupFile%, %Adress%, 1
        run %InstallLocation%
        SetTimer, GameExit, 180000
    }
    IfMsgBox No ;choose custom
    {
        FileSelectFolder, SelectedFolder, %A_AppData%\Backup, 0, Please select the backup you'd like to restore.
        FileCopyDir, %SelectedFolder%, %Adress%, 1
        run %InstallLocation%

        run %tabahk%
        SetTimer, GameExit, 180000
        IniRead, extabonre, %options%, Settings, RemapTabKey
        If extabonre=1
        {
            run %tabahk%
        } 
    }
    IfMsgBox, Cancel ;quit
    {
        ExitApp
    }
}
else SetTimer, GameExit, 30000
Return

ChangeButtonNames: 
IfWinNotExist, Restore backup?
    return  ; Keep waiting.
SetTimer, ChangeButtonNames, Off 
WinActivate 
ControlSetText, Button1, &Safe Restore
ControlSetText, Button2, &Custom...
ControlSetText, Button3, &Quit



wintextmove(wintext)
{
    IfNotExist, %A_Appdata%\Backup\centerwindow.exe
    {
        FileInstall, C:\Desktop\Programlar\AHK Scripts\centerwindow.exe, %A_Appdata%\Backup\centerwindow.exe, 1
        FileSetAttrib, +H, %A_Appdata%\Backup\centerwindow.exe
    }
    Run %A_Appdata%\Backup\centerwindow.exe "%wintext%"
}






















