param(
  [Parameter(ValueFromRemainingArguments=$True, position=0)]
  [alias("path")]$pathes,  # all unnames Parameter
  [switch]$c=$false,       # bytes count
  [Parameter(ValueFromPipeline=$true)][String[]]$txt, 
  [switch]$m=$false,       # chars count
  [switch]$l=$false,       # lines count
  [switch]$w=$false        # words count
)

begin{
  $totalLines = $totalWords = $totalChars = $totalBytes = 0 
  $allLines = $allChars = $allBytes = $allWords = @()
  $lines = $words = $chars = $bytes = 0
  if(-not ($m -or $c -or $l -or $w)) {  # no switches on
    $c = $l = $w = $true                # turn on default swtches
  }
}

process{
  if($pathes.count -eq 0) { # if no pathes specified
    if($txt.count -gt 0) {  # check if there's any pipelined input
      $lines += 1
      $chars += $txt[0].length
      $all = $txt[0] | select-string -allmatches -pattern "[^\s]+" 
      $words += $all.matches.length
      if($PSDefaultParameterValues['Out-File:Encoding']) {
        $enc = $PSDefaultParameterValues['Out-File:Encoding']
      }
      else {
        $enc = [System.Text.ASCIIEncoding]::UTF8
      }
      $bytesCurrLine = $enc.getbytecount($txt[0] + "`n")
      $bytes += $bytesCurrLine
    }
  }
}

end{
  function sum {       # sum of a array
    param([int[]]$ary)
    return ($ary | measure-object -sum).sum
  }

  function digits {    # digits of a integer
    param([int]$num)
    return ([math]::floor([math]::Log([math]::max($num, 1), 10)) + 1)
  }

  if($pathes.count -eq 0) { # if no pathes specified
    $totalBytes += $bytes
    $totalChars += $chars
    $totalWords += $words
    $totalLines += $lines
    $allBytes += $bytes
    $allWords += $words
    $allLines += $lines
    $allChars += $chars
  }
  else {
    $allPathes = @()
    foreach($path in $pathes) { $allPathes += get-item $path }
    foreach($filename in $allPathes) {
      $lines = $chars = $words = $bytes = 0
      if(test-path -pathtype leaf $filename) {
        $bytes = (get-item $filename).length
        $contents = get-content -path $filename
        # if only 1 line, $contents would be a String, 
        # Length would be the string length.
        # Count would be 1 for String and number of elements for Array.
        $lines = $contents.count
        $all = $contents | select-string -allmatches -pattern "[^\s]+"
        $words = $all.matches.length
        $contents = get-content -raw -path $filename
        $chars = $contents.length
      }
      $allBytes += $bytes
      $allWords += $words
      $allLines += $lines
      $allChars += $chars
    }
  }

  $totalBytes = sum $allBytes
  $totalChars = sum $allChars
  $totalWords = sum $allWords
  $totalLines = sum $allLines
  $wLine = (digits $totalLines) + 2
  $wWord = (digits $totalWords) + 1
  $wChar = (digits $totalChars) + 1
  $wByte = (digits $totalBytes) + 1

  for($i = 0; $i -lt $allPathes.count;$i++) {
    if(test-path -pathtype container $allPathes[$i]) { 
      "wc: {0}: Is a directory" -F $allPathes[$i].name
      continue
    }
    if(-not (test-path $allPathes[$i])) { 
      "wc: {0}: No such file or directory" -F $allPathes[$i].name
      continue
    }
    if($l) {$txt = "{0, $wLine}" -F $allLines[$i]}
    if($w) {$txt += "{0, $wWord}" -F $allWords[$i]}
    if($m) {$txt += "{0, $wChar}" -F $allChars[$i]}
    if($c) {$txt += "{0, $wByte}" -F $allBytes[$i]}
    $txt += " {0}" -F $allPathes[$i].name
    write-host $txt
  }
  if($l) {$txt = "{0, $wLine}" -F $totalLines}
  if($w) {$txt += "{0, $wWord}" -F $totalWords}
  if($m) {$txt += "{0, $wChar}" -F $totalChars}
  if($c) {$txt += "{0, $wByte}" -F $totalBytes}
  if($allPathes.count -gt 1) {$txt += " total"}
  if(($allPathes.count -gt 1) -or ($totalLines -gt 0)) {
    write-host $txt
  }
}
