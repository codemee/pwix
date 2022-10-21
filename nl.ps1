param(
  [Parameter(ValueFromRemainingArguments=$True, position=0)]
  [alias("path")]$pathes,                             # all unnames Parameter
  [int]$w=6,                                          # digits width
  [Parameter(ValueFromPipeline=$true)][String]$line,  # pipelined input
  [String]$s="`t",                                    # separator 
  [ValidateScript({$_ -ge 0})][int]$v=1,              # starting number
  [ValidateSet("ln","rn","rz")][String]$n="rn",       # adjustment
  [ValidateSet("a","t","n")][String]$b="t"            # number style
)

# the pipline collection needs begin/process/end
# structure to receive every single item of the 
# collection.

begin{
  $paddind = ""                         # defualt no padding
  if($n -eq "rz"){$paddind = ":d$w"}    # right adjustment with zero padding
  if($n -eq "ln"){$w = -$w}             # left adjustment
  $curr = 0                             # absolute start number

  function printLine {
    param(
      [String]$currline
    )
    if($currline -eq "" -and $b -eq "t") {            # -b t: nonempty lines
      write-host ""
    } 
    else {
      $numbers = ($v + $script:curr)                  # -b a: all lines
      if($b -eq 'n') {$numbers = ""}                  # -b n: no numbers
      "{0,$w$paddindh}$s{1}" -f $numbers, $currline
      $script:curr += 1
    }
  }
}

process{
  if($pathes.count -eq 0) {           # if no pathes specified
    if($line) {       # check if there's any pipelined input
      printLine $line
    }
  }
}

end{
  foreach($path in $pathes) {
    $allPathes = get-item $path
    foreach($filename in $allPathes) {
      if(test-path -pathtype leaf $filename) {
        $contents = get-content -path $filename
        foreach($currline in $contents) {
          printLine $currline 
        }
      }
      elseif (test-path -pathtype container $filename){
        write-error ("nl :{0}: Is a directory" -f $filename)
      }
      else {
        write-error ("nl :{0}: No such file" -f $filename)
      }
    }
  }
}
