Attribute VB_Name = "export_access_to_excel"
Option Compare Database
Option Explicit

Public Function export_all_tables_to_excel(Optional separate_workbooks As Boolean = True)
' Export all tables in the database to Excel .xlsx, excluding system and temporary tables.
'
' Files are saved in subfolder of the location of the Access database. The subfolder is
' named using the pattern "DATE_TIME_export", e.g. "20161103_125901_export". Before
' executing, a message box will advise what's about to happen and give an opportunity to cancel.
'
' Parameters:
' :separate_workbooks boolean: if True (default), export as separate workbooks.
'     If False, export as sheets within one workbook called "exported_tables.xlsx".
'
' To use this code:
' - Go to "Database Tools" -> "Visual Basic",
' - Go to "File" -> "Import File" -> Select this file (export_to_excel.bas)
' - In the "Immediate" window (below), copy in one of the following
'   commands (without quotes) and press Enter:
'     - For separate workbooks: "?export_access_to_excel.export_all_tables_to_excel(True)"
'     - For sheets in one file: "?export_access_to_excel.export_all_tables_to_excel(False)"
'
' To run the tests, type "?export_access_to_excel.run_tests" (without quotes) in the Immediate
' window and press Enter. It should output lines to the Immediate window indicating whether
' the tests passed or failed.

Dim current_db                As DAO.Database
Dim tdfs_to_export            As New Collection
Dim destination_folder_path   As String
Dim msg_box_response          As Integer

Set current_db = CurrentDb()

' Work out which tables to export.
Set tdfs_to_export = get_tdfs_to_export(current_db)

' Determine the name of the export path
destination_folder_path = get_destination_folder_path()

' Inform user what's about to happen and give opportunity to cancel.
msg_box_response = MsgBox(get_msg_box_prompt_text(separate_workbooks, destination_folder_path, _
        tdfs_to_export.Count), vbOKCancel)

' If OK then export all the tables.
If msg_box_response = vbOK Then
    export_to_excel separate_workbooks, destination_folder_path, tdfs_to_export
End If

Set tdfs_to_export = Nothing
Set current_db = Nothing

End Function

Private Function get_tdfs_to_export(current_db As DAO.Database) As Collection

Dim tdfs_to_export            As New Collection
Dim table_def                 As TableDef

For Each table_def In current_db.TableDefs
    If Not (table_def.Name Like "MSys*" Or table_def.Name Like "~*") Then
        tdfs_to_export.Add table_def
    End If
Next

Set get_tdfs_to_export = tdfs_to_export
Set tdfs_to_export = Nothing

End Function

Private Function get_destination_folder_path() As String

get_destination_folder_path = CurrentProject.path & "\" _
        & Format(Now(), "yyyymmdd_hhnnss") & "_export"

End Function

Private Function get_msg_box_prompt_text(separate_workbooks As Boolean, destination_folder_path As String, _
        tdfs_to_export_count As Integer)

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
        & " tables as " & msg_box_fragment & destination_path _
        & Chr(10) & Chr(10) & "Click Cancel to abort"

End Function

Private Function export_to_excel(separate_workbooks As Boolean, destination_folder_path As String, _
        tdfs_to_export As Collection)

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

Dim current_db As DAO.Database

' Use the same database object handle since:
' - Repeatedly calling this makes Access sad.
' - Tests shouldn't have any side effects on the database.
Set current_db = CurrentDb()

Debug.Print test_get_destination_folder_path
Debug.Print test_get_msg_box_prompt_text_separate_workbooks_true
Debug.Print test_get_msg_box_prompt_text_separate_workbooks_false
Debug.Print test_get_tdfs_to_export(current_db)
Debug.Print test_export_to_excel_separate_workbooks_true(current_db)
Debug.Print test_export_to_excel_separate_workbooks_false(current_db)

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

export_table_count = get_tdfs_to_export(current_db).Count
test = export_table_count < current_db.TableDefs.Count

test_get_tdfs_to_export = test_message(test, test_name, test_goal)

End Function

Private Function test_export_to_excel_separate_workbooks_true(current_db As DAO.Database)
Dim test_name                 As String
Dim test_goal                 As String
Dim test                      As Boolean
Dim export_table_count        As Integer
Dim destination               As String
Dim file_name                 As String
Dim file_count                As Integer

test_name = "test_export_to_excel_separate_workbooks_true"
test_goal = "Should create a subfolder with an Excel file for each export table"

destination = get_destination_folder_path() & "tetesw_true"
export_to_excel True, destination, get_tdfs_to_export(current_db)
export_table_count = get_tdfs_to_export(current_db).Count

file_name = Dir(destination & "\*.xlsx")
file_count = 0
Do While file_name <> ""
    file_count = file_count + 1
    file_name = Dir()
Loop

test = file_count = export_table_count

On Error Resume Next
Kill destination & "\*.*"
RmDir destination
On Error GoTo 0

test_export_to_excel_separate_workbooks_true = test_message(test, test_name, test_goal)

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
export_to_excel False, destination, get_tdfs_to_export(current_db)

file_name = Dir(destination & "\*.xlsx")
file_count = 0
Do While file_name <> ""
    file_count = file_count + 1
    file_name = Dir()
Loop

test = file_count = 1

On Error Resume Next
Kill destination & "\*.*"
RmDir destination
On Error GoTo 0

test_export_to_excel_separate_workbooks_false = test_message(test, test_name, test_goal)

End Function
