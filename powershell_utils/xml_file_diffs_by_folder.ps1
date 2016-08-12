# Say there are two folders, "instances" and "backups".
# They are both supposed to have the same XML file content, except for 
# some minor corrections to some files in "instances".
# Unfortunately, these folders have become out of sync, so we need to find:
# 1. Which files are in one folder but not the other (by file name), and 
# 2. Which files are in both folders but are different (by file hash).


# Find the differences in terms of missing files.
$ins_file = gci -recurse -filter *.xml -path instances
$bac_file = gci -recurse -filter *.xml -path backup
diff -ReferenceObject $ins_file -DifferenceObject $bac_file | Export-Csv 'diff.csv'

# Find the differences in terms of content, based on file hashes.
function FileHashes {
    param( [String]$path )
    gci -recurse -filter *.xml -path $path |
        Get-FileHash -Algorithm SHA256 |
        Select @{Label="FileName"; Expression={Split-Path $_.Path -Leaf}}, Hash
}
$ins = FileHashes -path 'instances'
$bac = FileHashes -path 'backup'

$notequal = diff -ReferenceObject $ins -DifferenceObject $bac -Property FileName, Hash | 
    Where { $_.SideIndicator -eq '=>' }

# Output the content of the files which are different.
Remove-Item 'filediff.csv'
ForEach ($file in $notequal) {
    $notequal_ins = gci -recurse -filter $file.FileName -Path 'instances' | Get-Content
    $notequal_bac = gci -recurse -filter $file.FileName -Path 'backup' | Get-Content
    diff -referenceobject $notequal_ins -DifferenceObject $notequal_bac |
        Export-Csv -Append 'filediff.csv' 
}
