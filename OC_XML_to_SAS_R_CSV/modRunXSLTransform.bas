Attribute VB_Name = "modRunXSLTransform"
Option Compare Database
Option Explicit

Public Enum RunXSLTransformMode
    tmCSV = 0
    tmR = 1
    tmSAS = 2
    tmAccess = 3
End Enum

Public Function RunXSLTransform(InputXMLPath As String, Mode As RunXSLTransformMode)

Call CheckAndAddRequiredReferences

Dim InputXML                  As New MSXML2.DOMDocument60
Dim InputXSL                  As New MSXML2.DOMDocument60
Dim InputStudyOID             As String
Dim OutputFSO                 As New Scripting.FileSystemObject
Dim OutputTS                  As Scripting.TextStream
Dim OutputFileName            As String

' Load the specified input xml file
InputXML.Load InputXMLPath

' Set the odm namespace and get the study name
InputXML.SetProperty "SelectionNamespaces", "xmlns:odm='http://www.cdisc.org/ns/odm/v1.3'"
InputStudyOID = InputXML.SelectSingleNode("odm:ODM/odm:Study").Attributes.getNamedItem("OID").Text

' The XSLs include external stylesheets so resolve external references
InputXSL.resolveExternals = True

If Mode = RunXSLTransformMode.tmCSV Then

    OutputFileName = CurrentProject.Path & "\" & InputStudyOID & "_out_csv.csv"
    InputXSL.Load CurrentProject.Path & "\XMLWorkFiles\xml_convert_csv.xsl"

    ' Create the output file object and write the transformed string to it
    Set OutputTS = OutputFSO.CreateTextFile(OutputFileName, True, True)
    OutputTS.Write (InputXML.transformNode(InputXSL))
    OutputTS.Close
    Set OutputTS = Nothing

    Dim CSVReRead             As Scripting.TextStream
    Dim CSVLineStr            As String
    Dim CSVLineStrInner       As String
    Dim CSVReWrite            As Scripting.TextStream
    Dim CSVReWriteName        As String

    ' Open the text file created by the xsl transform
    Set CSVReRead = OutputFSO.GetFile(OutputFileName).OpenAsTextStream(ForReading, TristateTrue)

    ' Read each line until a "TableName:" data set marker is found
    Do Until CSVReRead.AtEndOfStream
        CSVLineStr = CSVReRead.ReadLine

        ' Once a data set marker is found, create a new output file
        If InStr(CSVLineStr, "TableName:") Then
            CSVReWriteName = CurrentProject.Path & "\" & InputStudyOID & "_" & Right(CSVLineStr, Len(CSVLineStr) - 10) & "_out_csv.csv"
            Set CSVReWrite = OutputFSO.CreateTextFile(CSVReWriteName, True, True)

            ' Until another data set marker is found or the file ends,
            '  continue reading the original file and write each line to the new file
            Do Until InStr(CSVLineStrInner, "TableName:") Or CSVReRead.AtEndOfStream
                CSVLineStrInner = CSVReRead.ReadLine

                If InStr(CSVLineStrInner, "TableName:") = False Then
                    CSVReWrite.WriteLine CSVLineStrInner
                End If
                CSVLineStrInner = ""

            Loop

            ' Close the new file before trying to find the next data set marker
            CSVReWrite.Close
            Set CSVReWrite = Nothing

        End If
        CSVReWriteName = ""
        CSVLineStr = ""

    Loop

    CSVReRead.Close
    Set CSVReRead = Nothing

ElseIf Mode = RunXSLTransformMode.tmR Then

    OutputFileName = CurrentProject.Path & "\out_dataframes.txt"
    InputXSL.Load CurrentProject.Path & "\XMLWorkFiles\xml_convert_r_dataframes.xsl"
    ' Create the output file object and write the transformed string to it
    Set OutputTS = OutputFSO.CreateTextFile(OutputFileName, True, True)
    OutputTS.Write (InputXML.transformNode(InputXSL))
    OutputTS.Close
    Set OutputTS = Nothing

    OutputFileName = CurrentProject.Path & "\out_dataframe_factors.txt"
    InputXSL.Load CurrentProject.Path & "\XMLWorkFiles\xml_convert_r_dataframe_factors.xsl"
    ' Create the output file object and write the transformed string to it
    Set OutputTS = OutputFSO.CreateTextFile(OutputFileName, True, True)
    OutputTS.Write (InputXML.transformNode(InputXSL))
    OutputTS.Close
    Set OutputTS = Nothing

    OutputFileName = CurrentProject.Path & "\out_dataframes_with_factors.txt"
    InputXSL.Load CurrentProject.Path & "\XMLWorkFiles\xml_convert_r_dataframes_with_factors.xsl"
    ' Create the output file object and write the transformed string to it
    Set OutputTS = OutputFSO.CreateTextFile(OutputFileName, True, True)
    OutputTS.Write (InputXML.transformNode(InputXSL))
    OutputTS.Close
    Set OutputTS = Nothing

ElseIf Mode = RunXSLTransformMode.tmSAS Then

    OutputFileName = CurrentProject.Path & "\out_sas_data.xml"
    InputXSL.Load CurrentProject.Path & "\XMLWorkFiles\xml_convert_sas_data.xsl"
    ' Create the output file object and write the transformed string to it
    Set OutputTS = OutputFSO.CreateTextFile(OutputFileName, True, True)
    OutputTS.Write (InputXML.transformNode(InputXSL))
    OutputTS.Close
    Set OutputTS = Nothing

    OutputFileName = CurrentProject.Path & "\out_sas_format.sas"
    InputXSL.Load CurrentProject.Path & "\XMLWorkFiles\xml_convert_sas_format.xsl"
    ' Create the output file object and write the transformed string to it
    Set OutputTS = OutputFSO.CreateTextFile(OutputFileName, True, True)
    OutputTS.Write (InputXML.transformNode(InputXSL))
    OutputTS.Close
    Set OutputTS = Nothing

    OutputFileName = CurrentProject.Path & "\out_sas_map.map"
    InputXSL.Load CurrentProject.Path & "\XMLWorkFiles\xml_convert_sas_map.xsl"
    ' Create the output file object and write the transformed string to it
    Set OutputTS = OutputFSO.CreateTextFile(OutputFileName, True, True)
    OutputTS.Write (InputXML.transformNode(InputXSL))
    OutputTS.Close
    Set OutputTS = Nothing

ElseIf Mode = RunXSLTransformMode.tmAccess Then

    OutputFileName = CurrentProject.Path & "\out_access.xml"
    InputXSL.Load CurrentProject.Path & "\XMLWorkFiles\xml_convert_access.xsl"
    Application.ImportXML (InputXML.transformNode(InputXSL)), acAppendData

End If

' Clean up
Set InputXML = Nothing
Set InputXSL = Nothing
Set OutputFSO = Nothing
Set OutputTS = Nothing
OutputFileName = ""

End Function

Public Function CheckAndAddRequiredReferences()
' Check if MSXML and SCRRUN library references present
' If not, then add them to the default project

Dim foundMSXML2               As Boolean
Dim foundSCRRUN               As Boolean
Dim i                         As Integer

foundMSXML2 = False
foundSCRRUN = False

' Iterate through the default project and check library reference names
For i = 1 To Access.VBE.VBProjects.Item(1).References.Count
    If Access.VBE.VBProjects.Item(1).References(i).Name = "MSXML2" Then
        foundMSXML2 = True
    End If
    If Access.VBE.VBProjects.Item(1).References(i).Name = "Scripting" Then
        foundSCRRUN = True
    End If
Next i

' If the libraries weren't found in the above step, add references using default file locations
If foundMSXML2 = False Then
    Access.VBE.VBProjects.Item(1).References.AddFromFile ("C:\Windows\System32\msxml6.dll")
End If
If foundSCRRUN = False Then
    Access.VBE.VBProjects.Item(1).References.AddFromFile ("C:\Windows\System32\scrrun.dll")
End If

End Function
