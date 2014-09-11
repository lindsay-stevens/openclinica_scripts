Attribute VB_Name = "OCInterfaceFunctions"
Option Compare Database
Option Explicit

    Private Const STUDY_NAME = "ReplaceMeWithStudyName"
    Private Const USE_TABLENAME_CONVERTER = False

      Private Type STARTUPINFO
         cb As Long
         lpReserved As String
         lpDesktop As String
         lpTitle As String
         dwX As Long
         dwY As Long
         dwXSize As Long
         dwYSize As Long
         dwXCountChars As Long
         dwYCountChars As Long
         dwFillAttribute As Long
         dwFlags As Long
         wShowWindow As Integer
         cbReserved2 As Integer
         lpReserved2 As Long
         hStdInput As Long
         hStdOutput As Long
         hStdError As Long
      End Type

      Private Type PROCESS_INFORMATION
         hProcess As Long
         hThread As Long
         dwProcessID As Long
         dwThreadID As Long
      End Type

      Private Declare Function WaitForSingleObject Lib "kernel32" (ByVal _
         hHandle As Long, ByVal dwMilliseconds As Long) As Long

      Private Declare Function CreateProcessA Lib "kernel32" (ByVal _
         lpApplicationName As Long, ByVal lpCommandLine As String, ByVal _
         lpProcessAttributes As Long, ByVal lpThreadAttributes As Long, _
         ByVal bInheritHandles As Long, ByVal dwCreationFlags As Long, _
         ByVal lpEnvironment As Long, ByVal lpCurrentDirectory As Long, _
         lpStartupInfo As STARTUPINFO, lpProcessInformation As _
         PROCESS_INFORMATION) As Long

      Private Declare Function CloseHandle Lib "kernel32" (ByVal _
         hObject As Long) As Long

      Private Const NORMAL_PRIORITY_CLASS = &H20&
      Private Const INFINITE = -1&

      Public Sub ExecCmd(cmdline$)
         Dim proc As PROCESS_INFORMATION
         Dim start As STARTUPINFO
         Dim ReturnValue As Integer

         ' Initialize the STARTUPINFO structure:
         start.cb = Len(start)

         ' Start the shelled application:
         ReturnValue = CreateProcessA(0&, cmdline$, 0&, 0&, 1&, _
            NORMAL_PRIORITY_CLASS, 0&, 0&, start, proc)

         ' Wait for the shelled application to finish:
'         Do
'            ReturnValue = WaitForSingleObject(proc.hProcess, 0)
'            DoEvents
'            Loop Until ReturnValue <> 258
            ReturnValue = WaitForSingleObject(proc.hProcess, INFINITE)

            
         ReturnValue = CloseHandle(proc.hProcess)
      End Sub

Public Sub GenerateSASExtract()
Dim txstream As Object
Dim fs As Object

Dim lsCmd As String

Dim lsOCExtractFileName As String
    
    lsOCExtractFileName = GetOCExtractFileName()
    
    If lsOCExtractFileName <> "" Then
    
        GenerateDynamicLookUpXSLFile
    
        Set fs = CreateObject("Scripting.FileSystemObject")
    
        
        Set txstream = fs.CreateTextFile(CurrentProject.Path & "\SAS_" & STUDY_NAME & "_ImportCommands.sas", True)
        txstream.Write ("FileName " & STUDY_NAME & " '" & CurrentProject.Path & "\SAS_" & STUDY_NAME & "_data.xml';")
        txstream.Write (vbCrLf & "FileName map '" & CurrentProject.Path & "\SAS_" & STUDY_NAME & "_data_map.map';")
        txstream.Write (vbCrLf & "libname " & STUDY_NAME & " xml xmlmap=map access=readonly ;")
        txstream.Close
        
    
        lsCmd = "powershell -executionPolicy bypass -File """ & CurrentProject.Path & "\XmlWorkFiles\powershell_perform_SAS_xsl_transforms.ps1"""
        lsCmd = lsCmd & " -ocextract """ & lsOCExtractFileName & """"
        lsCmd = lsCmd & " -mapxsl """ & CurrentProject.Path & "\XmlWorkFiles\xml_convert_sas_map.xsl"""
        lsCmd = lsCmd & " -mapout """ & CurrentProject.Path & "\SAS_" & STUDY_NAME & "_data_map.map"""
        lsCmd = lsCmd & " -dataxsl """ & CurrentProject.Path & "\XmlWorkFiles\xml_convert_sas_data.xsl"""
        lsCmd = lsCmd & " -dataout """ & CurrentProject.Path & "\SAS_" & STUDY_NAME & "_data.xml"""
        lsCmd = lsCmd & " -formatxsl """ & CurrentProject.Path & "\XmlWorkFiles\xml_convert_sas_format.xsl"""
        lsCmd = lsCmd & " -formatout """ & CurrentProject.Path & "\SAS_" & STUDY_NAME & "_FormatCommands.sas"""
        
        ExecCmd lsCmd

        MsgBox "Done"

    End If
    
End Sub



Public Sub GenerateRExtract()

Dim lsCmd As String
Dim lsOCExtractFileName As String
    
    lsOCExtractFileName = GetOCExtractFileName()
    
    If lsOCExtractFileName <> "" Then
    
        GenerateDynamicLookUpXSLFile
        
        lsCmd = "powershell -executionPolicy bypass -File """ & CurrentProject.Path & "\XmlWorkFiles\powershell_perform_R_xsl_transforms.ps1"""
        lsCmd = lsCmd & " -ocextract """ & lsOCExtractFileName & """"
        lsCmd = lsCmd & " -projectpath """ & CurrentProject.Path & "\\"""
        lsCmd = lsCmd & " -studyname """ & STUDY_NAME & """"
        
        ExecCmd lsCmd
        MsgBox "Done"
    End If
    
End Sub

Public Sub GenerateCSVExtract()

Dim lsCmd As String
Dim lsOCExtractFileName As String
    
    lsOCExtractFileName = GetOCExtractFileName()


    If lsOCExtractFileName <> "" Then

        GenerateDynamicLookUpXSLFile
        
        lsCmd = "powershell -executionPolicy bypass -File """ & CurrentProject.Path & "\XmlWorkFiles\powershell_perform_CSV_xsl_transforms.ps1"""
        lsCmd = lsCmd & " -ocextract """ & lsOCExtractFileName & """"
        lsCmd = lsCmd & " -projectpath """ & CurrentProject.Path & "\\"""
        lsCmd = lsCmd & " -studyname """ & STUDY_NAME & """"
        
        
        
        ExecCmd lsCmd
        MsgBox "Done"

    End If
    
End Sub

Public Sub ImportOCExtractAsTables()
    Dim lsOCExtractFileName As String
    Dim obj As AccessObject, dbs As Object
    Dim lsCmd As String
    
    
    lsOCExtractFileName = GetOCExtractFileName()
    
    If lsOCExtractFileName <> "" Then
    
        GenerateDynamicLookUpXSLFile
        
        Set dbs = Application.CurrentData
        DoCmd.SetWarnings False


        For Each obj In dbs.AllTables
            If InStr(",Study,StudyMeasurementUnit,StudyFormStatus,StudyEventForms,StudyFormItemGroups,StudyItem,StudyCodeListItem,StudyMultiSelectListItem,StudyItemGroupItems,StudyRangeCheckItem,StudyUsers,StudyDataDiscrepancyNotes,StudyDataDiscrepancyNoteUpdates,", "," & obj.Name & ",") > 0 Then
                DoCmd.RunSQL ("DROP TABLE " & obj.Name)
            ElseIf USE_TABLENAME_CONVERTER Then
                If DCount("TableName", "ConversionToTableNames", "TableName = '" & obj.Name & "'") > 0 Then
                    DoCmd.RunSQL ("DROP TABLE " & obj.Name)
                End If
            End If
        Next obj


        DoCmd.SetWarnings True


        GenerateDynamicLookUpXSLFile

        lsCmd = "powershell -executionPolicy bypass -File """ & CurrentProject.Path & "\XmlWorkFiles\powershell_perform_access_xsl_transforms.ps1"""
        lsCmd = lsCmd & " -ocextract """ & lsOCExtractFileName & """"
        lsCmd = lsCmd & " -projectpath """ & CurrentProject.Path & "\\"""

        ExecCmd lsCmd
        
        Application.ImportXML CurrentProject.Path & "\XmlWorkFiles\xml_convert_access_out.xml"
        
        DoCmd.SetWarnings False
        DoCmd.RunSQL ("UPDATE StudyCodeListItem SET StudyCodeListItem.DecodeValue = LEFT(StudyCodeListItem.DecodeValueMemo,255)")
        DoCmd.RunSQL ("UPDATE StudyMultiSelectListItem SET StudyMultiSelectListItem.DecodeValue = LEFT(StudyMultiSelectListItem.DecodeValueMemo,255)")
        DoCmd.RunSQL ("UPDATE StudyItem SET QuestionMemo = Trim(Replace(Replace(questionmemo,chr(10),''),chr(13),'')), Question = LEFT(Trim(Replace(Replace(questionmemo,chr(10),''),chr(13),'')),255)")
        
        If USE_TABLENAME_CONVERTER Then
            If DCount("TableName", "ConversionToTableNames") = 0 Then
                lsCmd = "INSERT INTO ConversionToTableNames(TableName, CRFName, ItemGroupName)" & vbCrLf
                lsCmd = lsCmd & "SELECT DISTINCT StudyFormItemGroups.ItemGroupOID AS TableName, " & vbCrLf
                lsCmd = lsCmd & "Trim(IIf(InStrRev([StudyFormName],' -')>0,Left([StudyFormName],InStrRev([StudyFormName],' -')),[StudyFormName])) AS CRFName, " & vbCrLf
                lsCmd = lsCmd & "Trim(IIf(InStr([StudyFormItemGroups].[ItemGroupOID],'_UNGROUPED')>0,Null,[StudyItemGroupItems].[ItemGroupName])) AS ItemGroupName " & vbCrLf
                lsCmd = lsCmd & "FROM StudyFormItemGroups INNER JOIN StudyItemGroupItems ON StudyFormItemGroups.ItemGroupOID = StudyItemGroupItems.ItemGroupOID"
                
                DoCmd.RunSQL lsCmd
            End If
        End If
        
        DoCmd.SetWarnings True

        MsgBox "Done"
    End If
    
End Sub

Private Sub GenerateDynamicLookUpXSLFile()
Dim lrset As Recordset
Dim fs As FileSystemObject
Dim txstream As Object

    If USE_TABLENAME_CONVERTER Then
        CreateTblConversionToTableNames
        Set lrset = CurrentDb.OpenRecordset("SELECT TableName, CRFName, ItemGroupName FROM ConversionToTableNames ")
    End If

    Set fs = CreateObject("Scripting.FileSystemObject")
    Set txstream = fs.CreateTextFile(CurrentProject.Path & "\XmlWorkFiles\xml_convert_dynamic_lookup.xsl", True)
    
    
    txstream.Write ("<?xml version=""1.0"" ?>")
    txstream.Write (vbCrLf & "<xsl:stylesheet version=""1.0""")
    txstream.Write (vbCrLf & "xmlns:xsl=""http://www.w3.org/1999/XSL/Transform"">")
    txstream.Write (vbCrLf & "<xsl:template name=""get_tablename"">")
    txstream.Write (vbCrLf & "<xsl:param name=""formname"" />")
    txstream.Write (vbCrLf & "<xsl:param name=""groupname"" />")
    txstream.Write (vbCrLf & "<xsl:param name=""groupid"" />")
    
    If USE_TABLENAME_CONVERTER Then
        If Not lrset.EOF Then
            txstream.Write (vbCrLf & "<xsl:choose>")
            Do While Not lrset.EOF
                txstream.Write (vbCrLf & "<xsl:when test=""($formname='" & lrset!CRFName & "') and (" & IIf(IsNull(lrset!ItemGroupName), "contains($groupname,'_UNGROUPED')", "$groupname = '" & lrset!ItemGroupName & "'") & ")"">" & lrset!TableName & "</xsl:when>")
                lrset.MoveNext
            Loop
            lrset.Close
            txstream.Write (vbCrLf & "<xsl:otherwise>")
            txstream.Write (vbCrLf & "<xsl:value-of select=""$groupid"" />")
            txstream.Write (vbCrLf & "</xsl:otherwise>")
            txstream.Write (vbCrLf & "</xsl:choose>")
        Else
            txstream.Write (vbCrLf & "<xsl:value-of select=""$groupid"" />")
        End If
    Else
        txstream.Write (vbCrLf & "<xsl:value-of select=""$groupid"" />")
    End If
    txstream.Write (vbCrLf & "</xsl:template>")
    txstream.Write (vbCrLf & "<xsl:template name=""get_studyname"">" & STUDY_NAME & "</xsl:template>")
    txstream.Write (vbCrLf & "</xsl:stylesheet>")
    
    txstream.Close


End Sub


Private Function GetOCExtractFileName() As String
    Dim lobjFD As FileDialog
    Dim obj As AccessObject, dbs As Object
    Dim fs As Object
    Dim txstream As Object

    Dim lsXMLFileHeaderData As String
    
    
    GetOCExtractFileName = ""
    
    Set fs = CreateObject("Scripting.FileSystemObject")


    Set lobjFD = Application.FileDialog(msoFileDialogFilePicker)
    lobjFD.Title = "Select OpenClinica-Extension-1.3 XML dataset"
    lobjFD.Filters.Clear
    lobjFD.Filters.Add "xml", "*.xml", 1


    lobjFD.Show
    If lobjFD.SelectedItems.Count = 1 Then
        Set txstream = fs.OpenTextFile(lobjFD.SelectedItems(1))
        lsXMLFileHeaderData = txstream.Read(1024)
        txstream.Close

        If InStr(lsXMLFileHeaderData, "http://www.openclinica.org/ns/odm_ext_v130/v3.1") > 0 Then
        
            If InStr(lsXMLFileHeaderData, "<StudyName>" & STUDY_NAME & "</StudyName>") > 0 Then
                GetOCExtractFileName = lobjFD.SelectedItems(1)
            Else
                MsgBox "Incorrect XML file selected, must be the " & STUDY_NAME & " Study extract created using the ODM OpenClinica-Extensions-1.3 format"
            End If
        Else
            MsgBox "Incorrect XML file selected, must be the " & STUDY_NAME & " Study extract created using the ODM OpenClinica-Extensions-1.3 format"
        End If

    End If

    
End Function


Private Sub CreateTblConversionToTableNames()

Dim lCurrDB As Database
Dim ltblDef As TableDef
Dim ltblIndex As Integer
Dim ltblCount As Integer
Dim lbfound As Boolean

ltblIndex = 0

Set lCurrDB = Application.CurrentDb
ltblCount = lCurrDB.TableDefs.Count

Do While Not lbfound And ltblIndex < ltblCount
    lbfound = (lCurrDB.TableDefs(ltblIndex).Name = "ConversionToTableNames")
    ltblIndex = ltblIndex + 1
Loop

If Not lbfound Then
    lCurrDB.Execute ("CREATE TABLE ConversionToTableNames (TableName TEXT (255), CRFName TEXT (255), ItemGroupName TEXT (255))")
End If

End Sub


