param(
  [Parameter(ValueFromRemainingArguments=$True, position=0)]
  [alias("path")]$pathes,                              # all unnames Parameter
  [switch]$c=$false,                                   # bytes count
  [Parameter(ValueFromPipeline=$true)][String]$line,  # pipelined input
  [switch]$m=$false,                                   # chars count
  [switch]$l=$false,                                   # lines count
  [switch]$w=$false                                    # words count
)

# the pipline collection needs begin/process/end
# structure to receive every single item of the 
# collection.

begin{
  $totalLines = 0 
  $totalWords = 0 
  $totalChars = 0 
  $totalBytes = 0 
  $allLines = @()
  $allChars = @()
  $allBytes = @()
  $allWords = @()
  $lines = 0
  $words = 0
  $chars = 0
  $bytes = 0
  if(-not ($m -or $c -or $l -or $w)) {  # no switches on
    $c = $l = $w = $true   # enable default swtches
  }
}

process{
  if($pathes.count -eq 0) { # if no pathes specified
    if($line) {             # check if there's any pipelined input
      $lines += 1
      $chars += $line.length
      $all = select-string -allmatches -pattern "[^\s]+" -inputobject $line
      $words += $all.matches.length
      if($PSDefaultParameterValues['Out-File:Encoding']) {
        $bytesCurrLine = 
          $PSDefaultParameterValues['Out-File:Encoding'].getbytecount($line)
      } 
      else {
        $bytesCurrLine = 
          [System.Text.ASCIIEncoding]::UTF8.getbytecount($line)
      }        
      $bytes += $bytesCurrLine
    }
  }
}

end{
  if($pathes.count -eq 0) { # if no pathes specified
    $totalBytes += $bytes
    $totalChars += $chars
    $totalWords += $words
    $totalLines += $lines
    $allBytes += $bytes
    $allWords += $words
    $allLines += $lines
    $allChars += $chars
    # "{0} {1} {2} {3}" -F $lines, $words, $chars, $bytes
  }
  else {
    foreach($filename in $pathes) {
      $lines = $chars = $words = $bytes = -1
      if(test-path $filename) {
        $bytes = (get-item $filename).length
        $contents = get-content -path $filename
        # if only 1 line, $contents would be a String, 
        # Length would be the string length.
        # Count would be 1 for String and number of elements for Array.
        $lines = $contents.count
        $all = select-string -allmatches -pattern "[^\s]+" -inputobject $contents
        $words = $all.matches.length
        $contents = get-content -raw -path $filename
        $chars = $contents.length
        # "{0} {1} {2} {3} {4}" -F $lines, $words, $chars, $bytes, $filename
        $totalBytes += $bytes
        $totalChars += $chars
        $totalWords += $words
        $totalLines += $lines
      }
      $allBytes += $bytes
      $allWords += $words
      $allLines += $lines
      $allChars += $chars
    }
  }
  $wLine = ([math]::floor([math]::Log([math]::max($totalLines, 1), 10)) + 1) + 2
  $wWord = ([math]::floor([math]::Log([math]::max($totalWords, 1), 10)) + 1) + 1
  $wChar = ([math]::floor([math]::Log([math]::max($totalChars, 1), 10)) + 1) + 1
  $wByte = ([math]::floor([math]::Log([math]::max($totalBytes, 1), 10)) + 1) + 1

  for($i = 0; $i -lt $allLines.count;$i++) {
    if($allLines[$i] -eq -1) { 
      "wc: {0}: No such file or directory" -F $pathes[$i]
      continue
    }
    $txt = ""
    if($l) {$txt += "{0, $wLine}" -F $allLines[$i]}
    if($w) {$txt += "{0, $wWord}" -F $allWords[$i]}
    if($m) {$txt += "{0, $wChar}" -F $allChars[$i]}
    if($c) {$txt += "{0, $wByte}" -F $allBytes[$i]}
    if($pathes.count -gt 0) {$txt += " {0}" -F $pathes[$i]}
    write-host $txt
  }
  if($allLines.count -gt 1) {
    $txt = ""
    if($l) {$txt += "{0, $wLine}" -F $totalLines}
    if($w) {$txt += "{0, $wWord}" -F $totalWords}
    if($m) {$txt += "{0, $wChar}" -F $totalChars}
    if($c) {$txt += "{0, $wByte}" -F $totalBytes}
    $txt += " total"
    write-host $txt
  }
}
