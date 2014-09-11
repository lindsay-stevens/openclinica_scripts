Attribute VB_Name = "XLSCRFReadWrite"
Option Compare Database
Option Explicit

Public Function CleanString(StringToClean As String) As String
' Replaces all characters not upper/lower A-Z, 0-9 or "_" with "_"
' Requires reference "Microsoft VBScript Regular Expressions 5.5"

Dim RegExpObj                 As RegExp
Set RegExpObj = New RegExp

With RegExpObj
    .Multiline = False
    .Global = True
    .IgnoreCase = False
End With

RegExpObj.Pattern = "[^a-zA-Z0-9_]"
CleanString = RegExpObj.Replace(StringToClean, "_")

End Function

Public Function SQLExcludeCRFNameVersion(TableName As String) As String
' Builds a SQL String to select all columns from the table named in TableName,
' but excludes the CRF_NAME and VERSION columns

Dim rstTable                  As DAO.Recordset
Dim FieldCount                As Integer
Dim TempString                As String
Dim i                         As Integer

Set rstTable = CurrentDb.OpenRecordset(TableName)
FieldCount = rstTable.Fields.Count
TempString = "SELECT "

For i = 0 To FieldCount - 1
    If rstTable.Fields(i).Name <> "CRF_NAME" _
            And rstTable.Fields(i).Name <> "VERSION" _
            And rstTable.Fields(i).Name <> "rownumber" Then
        TempString = TempString & rstTable.Fields(i).Name & ","
    End If
Next

If Right(TempString, 1) = "," Then
    TempString = Left(TempString, Len(TempString) - 1)
End If

TempString = TempString & " FROM " & TableName

SQLExcludeCRFNameVersion = TempString

End Function

Public Function XLSCRFRead(FilePath As String, Recurse As Boolean, CreateOnly As Boolean)

Dim TargetTableList           As New Collection
Dim TTLItemIndex              As Integer
Dim TNRSSQL                   As String
Dim ImportSourceFile          As DAO.Database
Dim ImportFileCollection      As New Collection
Dim ImportFileIndex           As Integer
Dim TableNameRecordSet        As DAO.Recordset
Dim ImportCRFRecordSet        As DAO.Recordset
Dim CRFName                   As String
Dim CRFVersion                As String
Dim ImportCRFDatabase As DAO.Database

Set ImportCRFDatabase = CurrentDb


TargetTableList.Add "CRF"
TargetTableList.Add "Sections"
TargetTableList.Add "Groups"
TargetTableList.Add "Items"

' Get file paths for all the xls files in the path and put it in collection
GetXLSFiles FilePath, "xls", ImportFileCollection, Recurse

' For each file found, open it, create a table for it if there isn't one already
' and copy in the data
For ImportFileIndex = 1 To ImportFileCollection.Count
    Set ImportSourceFile = OpenDatabase(ImportFileCollection(ImportFileIndex).path, _
            False, True, "Excel 8.0;HDR=Yes")

    Set ImportCRFRecordSet = ImportSourceFile.OpenRecordset("SELECT * FROM [CRF$]")

    ' Get the CRFName and CRFVersion variables from the CRF sheet
    CRFName = ""
    CRFVersion = ""
    If Not (ImportCRFRecordSet.BOF And ImportCRFRecordSet.EOF) Then
        ImportCRFRecordSet.MoveFirst
        CRFName = ImportCRFRecordSet("CRF_NAME").Value
        CRFVersion = ImportCRFRecordSet("VERSION").Value
        ImportCRFRecordSet.Close
        Set ImportCRFRecordSet = Nothing
    End If

    For TTLItemIndex = 1 To TargetTableList.Count
        TNRSSQL = "SELECT * FROM [" & TargetTableList(TTLItemIndex) & "$]"

        Set TableNameRecordSet = ImportSourceFile.OpenRecordset(TNRSSQL)

        If Not (TableNameRecordSet.BOF And TableNameRecordSet.EOF) Then
            TableNameRecordSet.MoveFirst

            Do Until TableNameRecordSet.EOF
            
                ' Create the tables if they don't already exist

                ' If we are just creating tables this time round
                If CreateOnly = True Then
                    If ObjectExists(TargetTableList(TTLItemIndex), "table", ImportCRFDatabase) = False Then
                      Call CreateTables(TableNameRecordSet, TargetTableList(TTLItemIndex), ImportCRFDatabase)
                    End If
                    ' Exit the loop
                    Exit Do
                Else:
                    ' Use ADODB.command to insert the data
                    Call InsertData(TableNameRecordSet, TargetTableList(TTLItemIndex), CRFName, CRFVersion)
                    TableNameRecordSet.MoveNext
                End If

            Loop

        End If

    Next TTLItemIndex

    TableNameRecordSet.Close
    ImportSourceFile.Close
    Set TableNameRecordSet = Nothing
    Set ImportSourceFile = Nothing

Next ImportFileIndex

DoEvents

End Function

Public Function XLSCRFWrite(FilePath As String, Optional FilterCRFName As String, Optional FilterCRFVersion As String)

Dim TargetTableList           As New Collection
Dim TTLItemIndex              As Integer
Dim TableName                 As String
Dim ExportQDFParamStr         As String
Dim ExportQDFTableStr         As String
Dim ExportQDFWhereStr         As String
Dim ExportQDFOrderStr         As String
Dim ExportQDFFinalStr         As String
Dim ExportQDF                 As DAO.QueryDef
Dim ExportCRFQDF              As DAO.QueryDef
Dim ExportCRFRecordSet        As DAO.Recordset
Dim CRFName                   As String
Dim CRFVersion                As String
Dim CRFNameVersion            As String
Dim ExcelApp                  As New Excel.Application
Dim ExcelAppBook              As Excel.Workbook
Dim ExcelAppBookSheet         As Excel.Worksheet
Dim TableNameQDF              As DAO.QueryDef
Dim TableNameRecordSet        As DAO.Recordset
Dim TNRSFieldIndex            As Integer
Dim WorksheetForDelete        As Worksheet

TargetTableList.Add "CRF"
TargetTableList.Add "Sections"
TargetTableList.Add "Groups"
TargetTableList.Add "Items"

' Ensure the required paramaterized querydefs exist
ExportQDFParamStr = "PARAMETERS param_CRFName Text(255), param_CRFVersion Text(255); "
ExportQDFWhereStr = " WHERE CRF_NAME Like IIf(IsNull([param_CRFName]),'*','*'&[param_CRFName]&'*') " _
        & " AND VERSION Like IIf(IsNull([param_CRFVersion]),'*','*'&[param_CRFVersion]&'*')"
ExportQDFOrderStr = " ORDER BY rownumber "

For TTLItemIndex = 1 To TargetTableList.Count

    If TargetTableList(TTLItemIndex) = "CRF" Then
        ExportQDFTableStr = " SELECT CRF_NAME, VERSION, VERSION_DESCRIPTION, REVISION_NOTES FROM CRF "
    Else: ExportQDFTableStr = SQLExcludeCRFNameVersion(TargetTableList(TTLItemIndex))
    End If

    ExportQDFFinalStr = ExportQDFParamStr & ExportQDFTableStr & ExportQDFWhereStr

    If ObjectExists("export_qdf_" & TargetTableList(TTLItemIndex), "query") Then
        CurrentDb.QueryDefs.Delete "export_qdf_" & TargetTableList(TTLItemIndex)
    End If

    Set ExportQDF = CurrentDb.CreateQueryDef("export_qdf_" & TargetTableList(TTLItemIndex), ExportQDFFinalStr)

    ExportQDFTableStr = ""
    ExportQDFFinalStr = ""
    ExportQDF.Close

Next TTLItemIndex

' Open the CRF querydef so it can be used to generate each Excel file
Set ExportCRFQDF = CurrentDb.QueryDefs("export_qdf_CRF")
ExportCRFQDF.Parameters("param_CRFName").Value = FilterCRFName
ExportCRFQDF.Parameters("param_CRFVersion").Value = FilterCRFVersion
Set ExportCRFRecordSet = ExportCRFQDF.OpenRecordset()
ExportCRFQDF.Close

' Loop through ExportCRFRecordSet and create workbooks, worksheets
If Not (ExportCRFRecordSet.BOF And ExportCRFRecordSet.EOF) Then
    ExportCRFRecordSet.MoveFirst
    Do Until ExportCRFRecordSet.EOF
        CRFName = ExportCRFRecordSet.Fields("CRF_NAME").Value
        CRFVersion = ExportCRFRecordSet.Fields("VERSION").Value
        CRFNameVersion = CleanString(CRFName & "_" & CRFVersion)

        ' Create excel instance, workbook
        Set ExcelAppBook = ExcelApp.Workbooks.Add

        For TTLItemIndex = 1 To TargetTableList.Count

            TableName = TargetTableList(TTLItemIndex)

            ' Create sheet for the current table after the last sheet
            Set ExcelAppBookSheet = ExcelAppBook.Worksheets.Add( _
                    After:=ExcelAppBook.Worksheets(ExcelAppBook.Worksheets.Count))
            ExcelAppBookSheet.Name = TableName

            ' Retrieve recordset to go in sheet
            Set TableNameQDF = CurrentDb.QueryDefs("export_qdf_" & TargetTableList(TTLItemIndex))
            TableNameQDF.Parameters("param_CRFName").Value = CRFName
            TableNameQDF.Parameters("param_CRFVersion").Value = CRFVersion
            Set TableNameRecordSet = TableNameQDF.OpenRecordset()
            TableNameQDF.Close

            ' Create a header row by writing the field names to the first row
            For TNRSFieldIndex = 1 To TableNameRecordSet.Fields.Count
                ExcelAppBookSheet.Cells(1, TNRSFieldIndex).Value _
                        = TableNameRecordSet.Fields(TNRSFieldIndex - 1).Name
            Next TNRSFieldIndex

            ' Copy in the data from the recordset, using "CopyFromRecordset" function
            ExcelAppBookSheet.Range("A2").CopyFromRecordset TableNameRecordSet

            TableName = ""
            TableNameRecordSet.Close
            Set TableNameRecordSet = Nothing

        Next TTLItemIndex

        ' Remove the default created sheets named "Sheet1", "Sheet2", "Sheet3"
        For Each WorksheetForDelete In ExcelAppBook.Worksheets
            If WorksheetForDelete.Name = "Sheet1" _
                    Or WorksheetForDelete.Name = "Sheet2" _
                    Or WorksheetForDelete.Name = "Sheet3" Then
                ExcelAppBook.Worksheets(WorksheetForDelete.Name).Delete
            End If
        Next WorksheetForDelete

        ' Set the file name by the cleaned table name, save the file as Excel 2003 / xls
        If Right(FilePath, 1) <> "\" Then
            FilePath = FilePath & "\"
        End If
        ExcelAppBook.SaveAs FilePath & CRFNameVersion & ".xls", xlExcel8

        ' Close objects and clean up
        ExcelAppBook.Close
        ExcelApp.Quit

        Set TableNameRecordSet = Nothing
        Set ExcelAppBookSheet = Nothing
        Set ExcelAppBook = Nothing
        Set ExcelApp = Nothing

        ExportCRFRecordSet.MoveNext
    Loop
End If

' Clear out the temp query defs
For TTLItemIndex = 1 To TargetTableList.Count
    If ObjectExists("export_qdf_" & TargetTableList(TTLItemIndex), "query") Then
        CurrentDb.QueryDefs.Delete "export_qdf_" & TargetTableList(TTLItemIndex)
    End If
Next TTLItemIndex

ExportCRFRecordSet.Close
Set ExportCRFRecordSet = Nothing

End Function

Public Function GetXLSFiles(FolderRoot As String, FileExtension As String, FileCollection As Collection, Recurse As Boolean)
Dim fso                       As New Scripting.FileSystemObject
Dim files                     As New Collection
Dim file                      As Scripting.file

GetFilesRecursive fso.GetFolder(FolderRoot), FileExtension, files, fso, Recurse

Set FileCollection = files

End Function

Sub GetFilesRecursive(f As Scripting.Folder, filter As String, c As Collection, fso As Scripting.FileSystemObject, Recurse As Boolean)
Dim sf                        As Scripting.Folder
Dim file                      As Scripting.file

For Each file In f.files
    If InStr(1, fso.GetExtensionName(file.Name), filter, vbTextCompare) = 1 Then
        c.Add file, file.path
    End If
Next file
If Recurse = True Then
    For Each sf In f.SubFolders
        GetFilesRecursive sf, filter, c, fso, Recurse
    Next sf
End If
End Sub

Public Function ObjectExists(ObjectName As String, ObjectType As String, ObjectDatabase As DAO.Database) As Boolean

' Checks if the specified object name and type exists in the local database
' Only accepts table, query or report. Check MSysObjects to add other types

Dim OERS                      As DAO.Recordset
Dim OESQL                     As String
Dim OETypeInt                 As Integer

' Set default return value
ObjectExists = False

' Map object type names to the coded types
Select Case Format(ObjectType, "<")
    Case Is = "table"
        OETypeInt = 1
    Case Is = "linked table"
        OETypeInt = 4
    Case Is = "query"
        OETypeInt = 5
    Case Is = "report"
        OETypeInt = -32764
    Case Else
        OETypeInt = -1
End Select

' Create query / recordset to check for the object
OESQL = "SELECT MSysObjects.Name FROM MSysObjects " _
        & " WHERE MSysObjects.Name=" & Chr(34) & ObjectName & Chr(34) _
        & " AND MSysObjects.Type=" & OETypeInt
'CurrentProject.Connection.Execute "GRANT SELECT ON MSysObjects TO Admin;"
Set OERS = ObjectDatabase.OpenRecordset(OESQL, dbOpenSnapshot)

' If any objects of that name and type are found, return true
ObjectExists = (OERS.RecordCount <> 0)

' Clean up
OERS.Close
Set OERS = Nothing
OESQL = ""
OETypeInt = -1

End Function

Public Function CreateTables(TableNameRecordSet As DAO.Recordset, TableName As String, TableNameDatabase As DAO.Database)

Dim TNRSFieldIndex As Integer
Dim FieldDefDDL As String
Dim TableCreateDDL As String
Dim TargetTableRelation As DAO.Relation
Dim CRFTableIndex As DAO.index

For TNRSFieldIndex = 0 To TableNameRecordSet.Fields.Count - 1

    FieldDefDDL = FieldDefDDL & TableNameRecordSet.Fields(TNRSFieldIndex).Name

    ' Set big fields as MEMO
    If TableNameRecordSet.Fields(TNRSFieldIndex).Name = "VERSION_DESCRIPTION" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "SECTION_TITLE" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "SUBTITLE" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "INSTRUCTIONS" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "DESCRIPTION_LABEL" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "LEFT_ITEM_TEXT" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "RIGHT_ITEM_TEXT" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "HEADER" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "RESPONSE_OPTIONS_TEXT" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "RESPONSE_VALUES_OR_CALCULATIONS" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "DEFAULT_VALUE" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "VALIDATION" Or _
            TableNameRecordSet.Fields(TNRSFieldIndex).Name = "SIMPLE_CONDITIONAL_DISPLAY" Then
        FieldDefDDL = FieldDefDDL & " MEMO,"
    Else:
        FieldDefDDL = FieldDefDDL & " TEXT (255),"
    End If

Next TNRSFieldIndex

' If the table isn't CRF then add foreign key columns CRF_NAME and VERSION
If TableName <> "CRF" Then
    FieldDefDDL = FieldDefDDL & "CRF_NAME TEXT (255)," _
            & " VERSION TEXT (255),"
End If

' Always add on a rownumber column so the ordering can be preserved
FieldDefDDL = FieldDefDDL & "rownumber NUMBER"

TableCreateDDL = "CREATE TABLE " & TableName & "(" & FieldDefDDL & ")"

TableNameDatabase.Execute TableCreateDDL, dbFailOnError

' If the current table is CRF
If TableName = "CRF" Then
    ' Create a primary key on CRF_NAME and VERSION
    Set CRFTableIndex = TableNameDatabase.TableDefs("CRF").CreateIndex("primarykey")

    With CRFTableIndex
        .Fields.Append .CreateField("CRF_NAME")
        .Fields.Append .CreateField("VERSION")
        .Primary = True
    End With

    TableNameDatabase.TableDefs("CRF").Indexes.Append CRFTableIndex
    Set CRFTableIndex = Nothing

Else:
    ' Create a relationship to the CRF table on CRF_NAME and VERSION
    Set TargetTableRelation = TableNameDatabase.CreateRelation( _
            "CRF_" & TableName, "CRF", TableName)

    With TargetTableRelation
        .Fields.Append .CreateField("CRF_NAME")
        .Fields("CRF_NAME").ForeignName = "CRF_NAME"
        .Fields.Append .CreateField("VERSION")
        .Fields("VERSION").ForeignName = "VERSION"
    End With

    TableNameDatabase.Relations.Append TargetTableRelation
    Set TargetTableRelation = Nothing

End If

FieldDefDDL = ""
TableCreateDDL = ""

End Function

Public Function InsertData(TableNameRecordSet As DAO.Recordset, TableName As String, CRFName As String, CRFVersion As String)

Dim TNRSFieldIndex            As Integer
Dim AppendField               As String
Dim AppendParam               As String
Dim ImportCRFConnection As ADODB.Connection
Dim ImportCRFCommand          As ADODB.Command

' Iterate through each field to build the INSERT INTO statement
For TNRSFieldIndex = 0 To TableNameRecordSet.Fields.Count - 1

    AppendField = AppendField & TableNameRecordSet.Fields(TNRSFieldIndex).Name & ","
    AppendParam = AppendParam & "[param_" _
            & TableNameRecordSet.Fields(TNRSFieldIndex).Name & "],"

Next TNRSFieldIndex

' If the table isn't CRF then add foreign key columns CRF_NAME and VERSION
If TableName <> "CRF" Then
    AppendField = AppendField & "CRF_NAME, VERSION,"
    AppendParam = AppendParam & "[param_CRF_NAME], [param_VERSION],"
End If

' Always add on a rownumber column so the ordering can be preserved
AppendField = AppendField & "rownumber"
AppendParam = AppendParam & "[param_rownumber]"

Set ImportCRFCommand = New ADODB.Command

' Set the CommandText as the constructed INSERT INTO statement
ImportCRFCommand.CommandText = "INSERT INTO " & TableName _
        & " (" & AppendField & ")" _
        & " VALUES (" & AppendParam & ");"

AppendField = ""
AppendParam = ""

' Iterate through each field to make the command parameters
For TNRSFieldIndex = 0 To TableNameRecordSet.Fields.Count - 1

    If Not IsNull(TableNameRecordSet.Fields(TNRSFieldIndex).Value) Then
        ' If the field value isn't null, create the parameter with the value
        With ImportCRFCommand
            .Parameters.Append .CreateParameter( _
                    "param_" & TableNameRecordSet.Fields(TNRSFieldIndex).Name, _
                    adLongVarChar, adParamInput, _
                    Len(TableNameRecordSet.Fields(TNRSFieldIndex).Value), _
                    TableNameRecordSet.Fields(TNRSFieldIndex).Value)
        End With
    Else:
        ' If the field value is null, create the parameter with a null value
        With ImportCRFCommand
            .Parameters.Append .CreateParameter( _
                    "param_" & TableNameRecordSet.Fields(TNRSFieldIndex).Name, _
                    adLongVarChar, adParamInput, 1, Null)
        End With
    End If

Next TNRSFieldIndex

' If the table isn't CRF then add foreign key columns CRF_NAME and VERSION
If TableName <> "CRF" Then
    With ImportCRFCommand
        .Parameters.Append .CreateParameter("param_CRF_NAME", _
                adLongVarWChar, adParamInput, Len(CRFName), CRFName)
        .Parameters.Append .CreateParameter("param_VERSION", _
                adLongVarWChar, adParamInput, Len(CRFVersion), CRFVersion)
    End With
End If

' Always add on a rownumber column so the ordering can be preserved
With ImportCRFCommand
    .Parameters.Append .CreateParameter("param_rownumber", _
            adLongVarWChar, adParamInput, _
            10, _
            TableNameRecordSet.AbsolutePosition)
End With

' Make a copy of the current db connection to use for the command, begin transaction
Set ImportCRFConnection = CurrentProject.Connection
ImportCRFConnection.BeginTrans

' Set the connection to the current database and execute the command
With ImportCRFCommand
    .ActiveConnection = ImportCRFConnection
    .Execute
End With

' Commit transaction and close current db connection copy
ImportCRFConnection.CommitTrans
ImportCRFCommand.ActiveConnection.Close
Set ImportCRFCommand = Nothing
Set ImportCRFConnection = Nothing

End Function
