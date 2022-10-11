param(
  [Parameter(ValueFromRemainingArguments=$True, 
             position=0)]$pathes,                     # all unnames Parameter
  [int]$w=6,                                          # digits width
  [Parameter(ValueFromPipeline=$true)][String]$line,  # pipelined input
  [String]$s="`t",                                    # separator 
  [ValidateScript({$_ -ge 0})][int]$v=1,              # starting number
  [ValidateSet("ln","rn","rz")][String]$n="rn"        # adjustment
)

# the pipline collection needs begin/process/end
# structure to receive every single item of the 
# collection.

begin{
  $paddind = ""
  if($n -eq "rz"){$paddind = ":d$w"}    # right adjustment with zero padding
  if($n -eq "ln"){$w = -$w}             # left adjustment
  $curr = 0

  function printLine {
    param(
      [String]$currline
    )
    "{0,$w$paddind}$s{1}" -f ($v + $script:curr),$currline
    $script:curr += 1
  }
}

process{
  if($line) {                       # check if there's any pipelined input
    printLine $line
  }
}

end{
  foreach($filename in $pathes) {
    if(test-path $filename) {
      $contents = get-content -path $filename
      foreach($currline in $contents) {
        printLine $currline 
      }
    }
  }
}
