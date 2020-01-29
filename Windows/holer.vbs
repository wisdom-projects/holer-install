' Copyright 2018-present, Yudong (Dom) Wang
'
' Licensed under the Apache License, Version 2.0 (the "License");
' you may not use this file except in compliance with the License.
' You may obtain a copy of the License at
'
'      http://www.apache.org/licenses/LICENSE-2.0
'
' Unless required by applicable law or agreed to in writing, software
' distributed under the License is distributed on an "AS IS" BASIS,
' WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
' See the License for the specific language governing permissions and
' limitations under the License.

'---------------------------------------------------
' HOLER STARTUP.VBS
'---------------------------------------------------
Dim HOLER_WSH
Dim HOLER_FSO
Dim HOLER_BIN_NAME
Dim HOLER_BIN_PATH
Dim HOLER_CMD
Dim HOLER_LINE
Dim HOLER_LOG
Dim HOLER_LOG_DIR
Dim HOLER_VBS_FILE
Dim HOLER_BOOT_DIR
Dim HOLER_CLIENT_DIR

Dim HOLER_ACCESS_KEY
Dim HOLER_SERVER_HOST

Set HOLER_FSO = CreateObject("Scripting.FileSystemObject")
Set HOLER_WSH = CreateObject("WScript.Shell")
Set HOLER_ENV = HOLER_WSH.Environment("USER")

HOLER_VBS_FILE = "holer.vbs"
HOLER_BOOT_DIR = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\"

HOLER_CLIENT_DIR = HOLER_ENV("HOLER_CLIENT_DIR")
HOLER_ACCESS_KEY = HOLER_ENV("HOLER_ACCESS_KEY")
HOLER_SERVER_HOST = HOLER_ENV("HOLER_SERVER_HOST")

HOLER_BIN_NAME = "holer-windows-amd64.exe"
HOLER_BIN_PATH = HOLER_CLIENT_DIR & HOLER_BIN_NAME
HOLER_LOG_DIR = HOLER_CLIENT_DIR & "logs"
HOLER_LOG = HOLER_LOG_DIR & "\holer-client.log"
HOLER_LINE = "------------------------------------------"

'---------------------------------------------------
' Input parameters
'---------------------------------------------------
InputParam

'---------------------------------------------------
' Launch holer program
'---------------------------------------------------
LaunchHoler

'---------------------------------------------------
' Function - Ask user to input parameters
'---------------------------------------------------
Function InputParam()
    Do While HOLER_ACCESS_KEY = Empty
        HOLER_ACCESS_KEY = InputBox("Enter holer access key")
    Loop
    HOLER_ENV("HOLER_ACCESS_KEY") = HOLER_ACCESS_KEY

    Do While HOLER_SERVER_HOST = Empty
        HOLER_SERVER_HOST = InputBox("Enter holer server host")
    Loop
    HOLER_ENV("HOLER_SERVER_HOST") = HOLER_SERVER_HOST

    Do While HOLER_CLIENT_DIR = Empty
        HOLER_CLIENT_DIR = InputBox("Enter holer client directory")
    Loop
    HOLER_ENV("HOLER_CLIENT_DIR") = HOLER_CLIENT_DIR
End Function

'---------------------------------------------------
' Function - Launch holer program
'---------------------------------------------------
Function LaunchHoler()
    '---------------------------------------------------
    ' Launch holer daemon
    '---------------------------------------------------
    HOLER_CMD = "cmd.exe /c """ & HOLER_BIN_PATH & """ -k " & HOLER_ACCESS_KEY & " -s " & HOLER_SERVER_HOST & " >> " & HOLER_LOG
    HOLER_WSH.Run HOLER_CMD, 0, False

    '---------------------------------------------------
    ' Find holer daemon
    '---------------------------------------------------
    HOLER_CMD = "cmd.exe /c echo Starting holer client... & timeout /T 3 /NOBREAK & echo " & HOLER_LINE & " & echo The running holer client: & tasklist | findstr " & HOLER_BIN_NAME & " & echo " & HOLER_LINE & " & pause"
    HOLER_WSH.Run HOLER_CMD, 1, True
End Function
