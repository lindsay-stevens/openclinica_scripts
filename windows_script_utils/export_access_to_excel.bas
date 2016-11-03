Attribute VB_Name = "export_access_to_excel"
Option Compare Database
Option Explicit

Public Function export_all_tables_to_excel( _
        Optional separate_workbooks As Boolean = True, _
        Optional table_filter As String = "*", _
        Optional current_db As DAO.Database)
' Export all tables in the database to Excel .xlsx, excluding system and temporary tables.
'
' Files are saved in subfolder of the location of the Access database. The subfolder is
' named using the pattern "DATE_TIME_export", e.g. "20161103_125901_export". Before
' executing, a message box will advise what's about to happen and give an opportunity to cancel.
'
' Parameters:
' :separate_workbooks Boolean: if True (default), export as separate workbooks.
'     If False, export as sheets within one workbook called "exported_tables.xlsx".
' :table_filter String: default "*", but can be any string accepted by the Like operator,
'     for example "my_tables_*" would export only tables starting with "my_tables_".
' :current_db DAO.Database: mainly used for testing; can pass in a reference to the current
'     database to ensure that the view of objects is consistent with the calling procedure.
'
' To use this code:
' - Go to "Database Tools" -> "Visual Basic",
' - Go to "File" -> "Import File" -> Select this file (export_to_excel.bas)
' - In the "Immediate" window (below), copy in one of the following
'   commands (without quotes) and press Enter:
'     - For separate workbooks: "?export_access_to_excel.export_all_tables_to_excel(True)"
'     - For sheets in one file: "?export_access_to_excel.export_all_tables_to_excel(False)"
'
' For a demonstration of the export, type "?export_access_to_excel.demo_run" (without quotes)
' in the Immediate window and press enter. This will create 5 tables, insert some data using
' random letters, export them as single-file and multi-file, then remove the tables.
'
' To run the tests, type "?export_access_to_excel.run_tests" (without quotes) in the Immediate
' window and press Enter. It should output lines to the Immediate window indicating whether
' the tests passed or failed.

Dim tdfs_to_export            As New Collection
Dim extra                     As String
Dim destination_folder_path   As String
Dim msg_box_response          As Integer

If current_db Is Nothing Then
    Set current_db = CurrentDb()
End If

' Work out which tables to export. Abort if 0 tables found.
Set tdfs_to_export = get_tdfs_to_export(current_db, table_filter)
If tdfs_to_export.Count = 0 Then
    If table_filter <> "*" Then
        extra = " Try changing the table filter parameter."
    End If
    MsgBox "No tables to export found, aborting." & extra, vbOKOnly, "Export Access to Excel"
    Exit Function
End If

' Determine the name of the export path
destination_folder_path = get_destination_folder_path()

' Inform user what's about to happen and give opportunity to cancel.
msg_box_response = MsgBox(get_msg_box_prompt_text(separate_workbooks, _
        destination_folder_path, tdfs_to_export.Count), vbOKCancel, "Export Access to Excel")

' If OK then export all the tables.
If msg_box_response = vbOK Then
    export_to_excel separate_workbooks, destination_folder_path, tdfs_to_export
End If

Set tdfs_to_export = Nothing
Set current_db = Nothing

End Function

Private Function get_tdfs_to_export(current_db As DAO.Database, table_filter As String) As Collection
' Return the collection of tables to export, excluding system and temporary tables.
' The collection may be futher filtered by the "table_filter" parameter.

Dim tdfs_to_export            As New Collection
Dim table_def                 As TableDef

current_db.TableDefs.Refresh
For Each table_def In current_db.TableDefs
    If Not (table_def.Name Like "MSys*" _
            Or table_def.Name Like "~*") _
            And table_def.Name Like table_filter Then
        tdfs_to_export.Add table_def
    End If
Next

Set get_tdfs_to_export = tdfs_to_export
Set tdfs_to_export = Nothing

End Function

Private Function get_destination_folder_path() As String
' Return the export folder path

get_destination_folder_path = CurrentProject.path & "\" _
        & Format(Now(), "yyyymmdd_hhnnss") & "_export"

End Function

Private Function get_msg_box_prompt_text(separate_workbooks As Boolean, destination_folder_path As String, _
        tdfs_to_export_count As Integer)
' Return the main message box prompt text

Dim msg_box_fragment          As String
Dim destination_path          As String

If separate_workbooks Then
    msg_box_fragment = "one sheet per workbook in "
    destination_path = destination_folder_path
Else
    msg_box_fragment = "sheets in one workbook at "
    destination_path = destination_folder_path & "\exported_tables.xlsx"
End If

get_msg_box_prompt_text = "About to export " & tdfs_to_export_count _
        & " table(s) as " & msg_box_fragment & destination_path _
        & Chr(10) & Chr(10) & "Click OK to continue, or Cancel to abort"

End Function

Private Function export_to_excel(separate_workbooks As Boolean, destination_folder_path As String, _
        tdfs_to_export As Collection)
' Create an output folder and export the provided tables to Excel.

Dim table_def                 As DAO.TableDef
Dim final_export_path         As String

If Len(Dir(destination_folder_path, vbDirectory)) = 0 Then
    MkDir destination_folder_path
End If
For Each table_def In tdfs_to_export
    If separate_workbooks Then
        final_export_path = destination_folder_path & "\" & table_def.Name & ".xlsx"
    Else
        final_export_path = destination_folder_path & "\exported_tables.xlsx"
    End If
    DoCmd.TransferSpreadsheet acExport, acSpreadsheetTypeExcel12Xml, _
            table_def.Name, final_export_path, True
Next

End Function

Public Function run_tests()
' Run all the tests and print their outcome messages.

Dim current_db                As DAO.Database

' Use the same database object handle since:
' - Repeatedly calling this makes Access sad.
' - Tests shouldn't have any side effects on the database.
Set current_db = CurrentDb()

test_setup current_db
Debug.Print test_get_destination_folder_path
Debug.Print test_get_msg_box_prompt_text_separate_workbooks_true
Debug.Print test_get_msg_box_prompt_text_separate_workbooks_false
Debug.Print test_get_tdfs_to_export(current_db)
Debug.Print test_export_to_excel_separate_workbooks_true(current_db)
Debug.Print test_export_to_excel_separate_workbooks_false(current_db)
test_teardown current_db

Set current_db = Nothing

End Function

Private Function test_message(pass_fail As Boolean, test_name As String, test_goal As String, Optional extra As String)
' Utility function to format test messages.

Dim pass_fail_text            As String

If pass_fail Then
    pass_fail_text = "Test passed. "
Else
    pass_fail_text = "Test failed. "
End If

test_message = pass_fail_text & "Test: " & test_name & "; Goal: " & test_goal & "; " & extra

End Function

Private Function test_get_destination_folder_path()
Dim test_name                 As String
Dim test_goal                 As String
Dim test                      As Boolean
Dim observed                  As String

test_name = "test_get_destination_folder_path"
test_goal = "Should contain current project path"

observed = get_destination_folder_path()
test = InStr(observed, CurrentProject.path) = 1
test_get_destination_folder_path = test_message(test, test_name, test_goal)

End Function

Private Function test_get_msg_box_prompt_text_separate_workbooks_true()
Dim test_name                 As String
Dim test_goal                 As String
Dim test                      As Boolean
Dim observed                  As String

test_name = "test_get_msg_box_prompt_text_separate_workbooks_true"
test_goal = "Should contain string 'per workbook' if separate workbook is True"

observed = get_msg_box_prompt_text(True, "dummy path", 1)
test = InStr(observed, "per workbook") > 1

test_get_msg_box_prompt_text_separate_workbooks_true = test_message(test, test_name, test_goal)

End Function

Private Function test_get_msg_box_prompt_text_separate_workbooks_false()
Dim test_name                 As String
Dim test_goal                 As String
Dim test                      As Boolean
Dim observed                  As String

test_name = "test_get_msg_box_prompt_text_separate_workbooks_false"
test_goal = "Should contain string 'one workbook' if separate workbook is False"

observed = get_msg_box_prompt_text(False, "dummy path", 1)
test = InStr(observed, "one workbook") > 1

test_get_msg_box_prompt_text_separate_workbooks_false = test_message(test, test_name, test_goal)

End Function

Private Function test_get_tdfs_to_export(current_db As DAO.Database)
Dim test_name                 As String
Dim test_goal                 As String
Dim test                      As Boolean
Dim export_table_count        As Integer

test_name = "test_get_tdfs_to_export"
test_goal = "Should return a collection smaller than complete table collection"

export_table_count = get_tdfs_to_export(current_db, "export_test_table*").Count
test = export_table_count < current_db.TableDefs.Count

test_get_tdfs_to_export = test_message(test, test_name, test_goal)

End Function

Private Function test_export_to_excel_separate_workbooks_true(current_db As DAO.Database)
Dim test_name                 As String
Dim test_goal                 As String
Dim test                      As Boolean
Dim destination               As String
Dim export_tdfs               As New Collection
Dim file_name                 As String
Dim file_count                As Integer

test_name = "test_export_to_excel_separate_workbooks_true"
test_goal = "Should create a subfolder with an Excel file for each export table"

destination = get_destination_folder_path() & "tetesw_true"
Set export_tdfs = get_tdfs_to_export(current_db, "export_test_table*")
export_to_excel True, destination, export_tdfs

file_name = Dir(destination & "\*.xlsx")
file_count = 0
Do While file_name <> ""
    file_count = file_count + 1
    file_name = Dir()
Loop

test = file_count = export_tdfs.Count

test_export_to_excel_separate_workbooks_true = test_message(test, test_name, test_goal)

delete_test_directory destination

End Function

Private Function test_export_to_excel_separate_workbooks_false(current_db As DAO.Database)
Dim test_name                 As String
Dim test_goal                 As String
Dim test                      As Boolean
Dim destination               As String
Dim file_name                 As String
Dim file_count                As Integer

test_name = "test_export_to_excel_separate_workbooks_false"
test_goal = "Should create a subfolder with a single Excel file"

destination = get_destination_folder_path() & "tetesw_false"
export_to_excel False, destination, get_tdfs_to_export(current_db, "export_test_table*")

file_name = Dir(destination & "\*.xlsx")
file_count = 0
Do While file_name <> ""
    file_count = file_count + 1
    file_name = Dir()
Loop

test = file_count = 1

test_export_to_excel_separate_workbooks_false = test_message(test, test_name, test_goal)

delete_test_directory destination

End Function

Private Function delete_test_directory(destination As String)
' Utility function to clear out a directory and remove it.

On Error Resume Next
Kill destination & "\*.*"
RmDir destination
On Error GoTo 0

End Function

Private Function test_setup(current_db As DAO.Database)
' Set up the database for testing.
Dim i, v                      As Integer
Dim tdf_name                  As String
Dim tdf_sql                   As String
Dim random_character          As String
Dim insert_sql                As String

' Make sure it's all clear first
On Error Resume Next
Call test_teardown(current_db)
On Error GoTo 0

' Create 5 test tables, insert 5 records using random characters.
For i = 1 To 5
    tdf_name = "export_test_table_" & i
    tdf_sql = "CREATE TABLE " & tdf_name & " (ID AUTOINCREMENT(1,1), Field1 Text);"
    current_db.Execute tdf_sql, dbFailOnError

    For v = 1 To 5
        random_character = Chr(Int((90 - 65 + 1) * Rnd + 65))
        insert_sql = "INSERT INTO " & tdf_name & " (Field1) VALUES ('" & random_character & "');"
        current_db.Execute insert_sql, dbFailOnError
    Next
Next
current_db.TableDefs.Refresh

End Function

Private Function test_teardown(current_db As DAO.Database)
' Clean up after tests are complete.

Dim i                         As Integer
Dim tdf_name                  As String

' This might happen if it's the last call
If current_db Is Nothing Then
    Set current_db = CurrentDb()
End If

For i = 1 To 5
    tdf_name = "export_test_table_" & i
    current_db.TableDefs.Delete tdf_name
Next
current_db.TableDefs.Refresh

End Function

Public Function demo_run()
' To demonstrate the export, this function creates test tables and exports
' them twice, once with the single-file option and again with multi-file.

Dim current_db                As DAO.Database
Dim time_wait                 As Date

Set current_db = CurrentDb()
test_setup current_db

' Output tables as sheets in separate files.
export_all_tables_to_excel True, "export_test_table*", current_db

' Wait 1 second so that the folder names are different
time_wait = DateAdd("s", 1, Now())
Do Until Now() >= time_wait
Loop

' Output tables as sheets in one file.
export_all_tables_to_excel False, "export_test_table*", current_db

test_teardown current_db

End Function
