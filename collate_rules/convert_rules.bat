:: Path to java.exe on the system.
@set "PATH=%PATH%;C:\Program Files (x86)\Java\jre1.8.0_101\bin"

:: Path to the XML file to convert.
@set "exportedXML=excel_layout.xml"

:: Can be "collate" (Excel to OpenClinica) or "split" (OpenClinica to Excel)
@set action=collate

:: Path to the saxon XML processor library.
@set "saxonLibrary=%~dp0..\saxon\saxon9he.jar"

:: Path to the XSLT file.
@set "xsltLocation=collateOrSplitRuleRefsByTarget.xsl"

java -cp "%saxonLibrary%" net.sf.saxon.Transform -s:"%exportedXML%" -o:"%exportedXML%" -xsl:"%xsltLocation%" -it:%action%-template

@echo.
@echo.
@echo This window is being kept open so you can check the results.
@echo If the file was successfully converted, you can close this window.
@echo.
@echo.

pause