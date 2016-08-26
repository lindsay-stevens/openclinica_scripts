' ******************************************************************************
'
' Datamart Launcher and Backup.
'
' Purpose:
' - Facilitate connection to the database, providing feedback on expected errors.
' - Automatically copy the Access database to a backup folder before starting a session.
'
' ******************************************************************************
DoubleNewLine = vbNewLine & vbNewLine


Sub Main
    ' The first argument should be the file path to the database we want to open.
    FilePath = WScript.Arguments(0)

    ' File system access object used throughout, and convenience variable.
    Set FSO = CreateObject("Scripting.FileSystemObject")
    Set ShellProcess = SetupProcessEnvironment
    
    ' Probe for a successful connection to datamart. If that fails, check for why.
    ChecksRequired = False
    On Error Resume Next
    DSNPathx64 = GetResourcePath(FSO, "ocdm-x64.dsn")
    Set Connection = CreateObject("ADODB.Connection")
    ConnectionString = "FILEDSN=" & dsnPathx64
    Connection.ConnectionTimeout = 15
    Connection.Open
    If (Connection.Errors > 0) Then ChecksRequired = True
    Connection.Close
    On Error goto 0
    
    If (ChecksRequired) Then
        ' If the connection failed, run the checking procedures.
        ' If a check fails, that sub will suggest a solution and quit the script.
        CheckResourceFiles FSO, FilePath
        CheckDriverInstalled FSO
        CheckConnection dsnPathx64
    End If
    
    ' If there's nothing wrong, proceed with backup and open the database.
    DatabaseBackup FSO, FilePath
    OpenDatabase ShellProcess, FilePath
End Sub

Main


' ******************************************************************************
' 
' Required Connection Resource Checks
' 
' ******************************************************************************


' If the resource doesn't exist, show an error messagebox and quit.
Function CriticalResourceCheck(path, exists, message)
    If (Not exists) Then
        ErrorMessageText = message & DoubleNewLine & _
            "Tried to access the following:" & DoubleNewLine & path
        MsgBox ErrorMessageText, vbOKOnly+vbCritical, "Error"
        WScript.Quit 1
    End If
End Function

Function GetResourcePath(FSO, resourceName)
    ThisScriptPath = Wscript.ScriptFullName
    ResourceDir = FSO.GetParentFolderName(ThisScriptPath)
    GetResourcePath = FSO.BuildPath(ResourceDir, resourceName)
End Function

Sub CheckResourceFiles(FSO, filePath)
    ' Check for the the target database file, the datamart root certificate, and 
    ' the x86 / x64 DSN connection settings files.
    FilePathError = "Error: link target doesn't exist or could not be accessed." & _
        " Please right click the link file, and check that the target points to" & _
        " a file that exists."
    CriticalResourceCheck FilePath, FSO.FileExists(filePath), FilePathError
    
    ' Assuming these things are all filed together.
    DatamartRootCertPath = GetResourcePath(FSO, "root.crt")
    DatamartRootCertPathError = "Error: Datamart root certificate file required" & _
        " for connecting doesn't exist or could not be accessed. Please and check" & _
        " that it exists or copy it to the expected location shown below."
    CriticalResourceCheck DatamartRootCertPath, _
        FSO.FileExists(DatamartRootCertPath), DatamartRootCertPathError
    
    DSNPathx86 = GetResourcePath(FSO, "ocdm-x86.dsn")
    DSNPathx86Error = "Error: Datamart DSN configuration file (x86) required" & _
        " for connecting doesn't exist or could not be accessed. Please and check" & _
        " that it exists or copy it to the expected location shown below."
    CriticalResourceCheck DSNPathx86, FSO.FileExists(DSNPathx86), DSNPathx86Error
    
    DSNPathx64 = GetResourcePath(FSO, "ocdm-x64.dsn")
    DSNPathx64Error = "Error: Datamart DSN configuration file (x64) required" & _
        " for connecting doesn't exist or could not be accessed. Please and check" & _
        " that it exists or copy it to the expected location shown below."
    CriticalResourceCheck DSNPathx64, FSO.FileExists(DSNPathx64), DSNPathx64Error
End Sub


' ******************************************************************************
' 
' Install the ODBC Driver, if needed.
' 
' ******************************************************************************


Sub CheckDriverInstalled(FSO)
    ' Check if the installer folder exists under "Program Files".
    DriverFolderPath = "C:\Program Files\psqlODBC"
    DriverFolderPathError = "Error: the psqlODBC driver doesn't appear to be" & _
        " installed at the expected location, shown below. The driver installer" & _
        " will now be launched. Once this is complete, please try to connect again."
    If (Not FSO.FolderExists(DriverFolderPath)) Then
        ' Check that the installer exists.
        DriverInstallerPath = GetResourcePath(FSO, "psqlodbc-setup.exe")
        DriverInstallerPathError = "Error: the psqlODBC driver installer file" & _
            " doesn't exist or could not be accessed. Please download the driver " & _
            " installer from postgresql.org and install it, and copy it to the " & _
            " location shown below for others to use."
        CriticalResourceCheck DriverInstallerPath, _
            FSO.FileExists(DriverInstallerPath), DriverInstallerPathError
        
        ' Warn that we're about to launch the driver installer.
        ErrorMessageText = DriverFolderPathError & DoubleNewLine & _
            "Tried to access the following:" & DoubleNewLine & DriverFolderPath
        MsgBox ErrorMessageText, vbOKOnly+vbCritical, "Error"
        set InstallerShell = CreateObject("Wscript.Shell")
        ' Argument meanings:
        ' 1 = Activate and display the window.
        ' False = Allow the current process to end without waiting for the child to return.
        InstallerShell.Run DriverInstallerPath, 1, False
        WScript.Quit 1
    End If
End Sub


' ******************************************************************************
' 
' Set the Process-Scoped Environment Variables
' 
' ******************************************************************************


' When we open the database, the child process it runs in inherits the current 
' environment. This concept follows http://stackoverflow.com/a/7733051/3386100
'
' Note:
' Even though the host is already in the DSN file, we need to specify it again
' here because the behaviour of libpq (which psqlODBC uses) is to require 
' both variables, if the connection method requires a host but the intention is to avoid 
' a host name lookup. We require a host name for SSL to work, and we want to 
' avoid a host name lookup because that is what causes Access problems. The 
' alternative is to editing the System32/drivers/etc/hosts file :(
'
' Also, we can't do away with the DSN file because psqlODBC requires at least 
' The driver name, server name, port number and database to initiate connections.
' Everything else can come from enviroment variables.
'
' Also note that despite being in a function, the Wscript.Shell is global.
'
' Ref: https://www.postgresql.org/docs/current/static/libpq-envars.html
Function SetupProcessEnvironment
    Set ShellObject = CreateObject("Wscript.Shell")
    Set ProcessEnvVars = ShellObject.Environment("Process")
    ProcessEnvVars("PGHOST") = "svr-ocdm-psql9.ad.nchecr.unsw.edu.au"
    ProcessEnvVars("PGHOSTADDR") = "129.94.32.52"
    ProcessEnvVars("PGKRBSRVNAME") = "POSTGRESDM"
    ProcessEnvVars("PGSSLROOTCERT") = DatamartRootCertPath
    Set SetupProcessEnvironment = ShellObject
End Function


' ******************************************************************************
' 
' Check the ODBC Connection
' 
' ******************************************************************************


Sub CheckConnection(dsnPathx64)
    ' We should be able to connect to Datamart now, so we will check if it works.
    ' The only thing that should be wrong at this point is an incorrect username.
    Set Connection = CreateObject("ADODB.Connection")
    ConnectionString = "FILEDSN=" & dsnPathx64
    Connection.ConnectionTimeout = 15
    NetworkUserName = CreateObject("WScript.Network").UserName
    
    ' Here we override the default role error with instructions on how to resolve it.
    
    ' Disable errors temporarily, attempt connection, and inspect the error collection.
    On Error Resume Next
    Connection.Open ConnectionString
    ReRaiseConnectionErrors = False
    If Connection.Errors.Count > 0 Then
        For Each ErrorNum in Connection.Errors
            ' This ugliness is because there isn't a precise SQLState code for 
            ' an incorrect username. The SQLState code that postgresql 9.3 returns 
            ' is "08001", which is an unsuitably generic error:
            ' "sqlclient_unable_to_establish_sqlconnection". Also, there is unusual 
            ' spacing and newlines in the error message that seems unreliable.
            FindStr1 = Instr(ErrorNum.Description, "FATAL:")
            FindStr2 = Instr(ErrorNum.Description, "role")
            FindStr3 = Instr(ErrorNum.Description, LCase(NetworkUserName))
            FindStr4 = Instr(ErrorNum.Description, "does not exist")
            If FindStr1 > 0 and FindStr2 > 0 and FindStr3 > 0 and FindStr4 > 0 and _
                FindStr1 < FindStr2 < FindStr3 < FindStr4 Then
                CorrectUserName = UCase(Mid(NetworkUserName, 1, 1)) & _
                    LCase(Mid(NetworkUserName, 2))
                ODBCErrorMessage = "Error: ODBC connection failed." & DoubleNewLine & _
                    "It appears that your current PC username (shown below) is not" & _ 
                    " formatted correctly and was rejected:" & DoubleNewLine & _ 
                    NetworkUserName & DoubleNewLine & "To connect to datamart, log" & _
                    " off your PC, change your username to the following, log in," & _
                    " and try to connect again: " & DoubleNewLine & CorrectUserName
                MsgBox ODBCErrorMessage, vbOKOnly+vbCritical, "Error"
                Connection.Close
                WScript.Quit 1
            Else
                ReRaiseConnectionErrors = True
            End If
        Next
    End If
    Connection.Close
    
    ' Enable errors again, and if we had errors then trigger them again.
    On Error goto 0
    If ReRaiseConnectionErrors Then
        Connection.Open ConnectionString
        Connection.Close
        WScript.Quit 1
    End If
End Sub


' ******************************************************************************
' 
' Copy the Database to a Backup Folder and Prune Backup Files.
' 
' ******************************************************************************


' Function to convert a date into an ISO8601 format.
' For example, "25/08/2016 11:45:56" becomes "20160825T114556".
' Verbatim from http://stackoverflow.com/a/18448889/3386100
Function iso8601Date(dt)
    s = datepart("yyyy",dt)
    s = s & RIGHT("0" & datepart("m",dt),2)
    s = s & RIGHT("0" & datepart("d",dt),2)
    s = s & "T"
    s = s & RIGHT("0" & datepart("h",dt),2)
    s = s & RIGHT("0" & datepart("n",dt),2)
    s = s & RIGHT("0" & datepart("s",dt),2)
    iso8601Date = s
End Function


Sub DatabaseBackup(FSO, filePath)
    ' Configuration:
    ' BackupFolderName: a subfolder of where the target database is.
    ' MaximumBackupFiles: how many backup files to keep.
    BackupFolderName = "auto_backups"
    MaximumBackupFiles = 10
    
    ' If the backup folder doesn't exist yet, then create it.
    OriginalFolderPath = FSO.GetParentFolderName(filePath)
    BackupFolderPath = FSO.BuildPath(OriginalFolderPath, BackupFolderName)
    If Not FSO.FolderExists(BackupFolderPath) Then FSO.CreateFolder(BackupFolderPath)
    
    ' Get a list of files in the backup folder.
    Set BackupFilesCollection = FSO.GetFolder(BackupFolderPath).Files
    
    ' Get the original file and it's extension, so we can select only those of the same type.
    OriginalFile = FSO.GetFile(filePath)
    OriginalExt = FSO.GetExtensionName(OriginalFile)
    
    ' Put each file in a sorted list, by date ascending, to find the oldest files.
    Set BackupFilesList = CreateObject("System.Collections.Sortedlist")
    For Each BackupFile in BackupFilesCollection
        If LCase(FSO.GetExtensionName(BackupFile.Name)) = OriginalExt Then
            key = iso8601Date(BackupFile.DateCreated) & BackupFile.Name
            BackupFilesList.Add key, BackupFile.Name
        End If
    Next
    
    ' Remove excess backup files, if any. We add 1 because BackupFilesList is 0-indexed.
    FilesExcess = BackupFilesList.Count - MaximumBackupFiles + 1
    If FilesExcess > 0 Then
        For i = 0 to FilesExcess - 1
            Set File = BackupFilesCollection.Item (BackupFilesList.GetByIndex(i))
            File.Delete
        Next
    End If
    
    ' Make a new backup copy of the original file, named with the current timestamp.
    OriginalBase = FSO.GetbaseName(OriginalFile)
    BackupFileName = iso8601Date(Now) & "_" & OriginalBase & "." & OriginalExt
    BackupFilePath = FSO.BuildPath(BackupFolderPath, BackupFileName)
    FSO.CopyFile filePath, BackupFilePath
End Sub


' ******************************************************************************
' 
' Open the Database
' 
' ******************************************************************************


Sub OpenDatabase(shellProcess, filePath)
    ' Wrap the database file path in quotes in case it contains spaces.
    Command = Chr(34) & filePath & Chr(34)
    
    ' Now that everything is checked and ready, open the database.
    ' Argument meanings:
    ' 1 = Activate and display the window.
    ' False = Allow the current process to end without waiting for the child to return.
    shellProcess.Run Command, 1, False
End Sub