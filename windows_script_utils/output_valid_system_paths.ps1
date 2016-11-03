# Output a list of valid paths from the system PATH environment variable.
# After uninstalling or upgrading things, the path list might get out of date.
$pathsFile = 'paths.txt'
If (Test-Path $pathsFile){
    Remove-Item $pathsFile
}
ForEach ($path in $env:Path.Split(";")) {
    if ($path) {
        if (Test-Path $path) {
            $outstring = $path + ';'
            Out-File -filePath $pathsFile -Append -Encoding "utf8" -InputObject $outstring
        }
    }
}

