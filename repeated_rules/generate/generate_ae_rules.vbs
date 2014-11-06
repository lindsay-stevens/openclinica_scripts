' Place script in directory with ruleref/def templates.
' Alternatively, specify paths in below variables.
' Finds # and replaces with AENUM, % with AENUM+1.
' Adjust AENUMref and AENUMdef loop counters as needed.
' Outfile has all rulerefs and ruledefs for x in AENUM.

ruleref = "AE_SAE_K1002_AE#_ruleref.xml"
ruledef = "AE_SAE_K1002_AE#_ruledef.xml"
outfile = "AE_SAE_K1002_AE_rules.xml"

Set objFSOref = CreateObject("Scripting.FileSystemObject")
Set objReadref = objFSOref.OpenTextFile(ruleref, 1)
str_ruleref = objReadref.ReadAll
objReadref.Close

Set objFSOdef = CreateObject("Scripting.FileSystemObject")
Set objReaddef = objFSOdef.OpenTextFile(ruledef, 1)
str_ruledef = objReaddef.ReadAll
objReaddef.Close

ruleref_accum = "<RuleImport>"

For AENUMref=20 to 50
    newTextref = str_ruleref
    newTextref = Replace(newTextref,"#", AENUMref)
    newTextref = Replace(newTextref,"%", AENUMref+1)
    ruleref_accum = ruleref_accum & newTextref
Next

For AENUMdef=20 to 50
    newTextdef = str_ruledef
    newTextdef = Replace(newTextdef,"#", AENUMdef)
    newTextdef = Replace(newTextdef,"%", AENUMdef+1)
    ruledef_accum = ruledef_accum & newTextdef
Next
ruledef_accum = ruledef_accum & "</RuleImport>"
rule_final = ruleref_accum & ruledef_accum

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set newout = objFSO.CreateTextFile(outfile,True)
newout.Write(rule_final)
newout.Close

WScript.Echo("Complete. Check new outfile.")