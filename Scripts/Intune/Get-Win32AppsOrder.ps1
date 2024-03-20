#[scriptblock]::Create((iwr "https://gist.githubusercontent.com/MrWyss-MSFT/c52f0a4567cba24e9ac8a38416a05bac/raw").Content).Invoke()
$Path = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension*.log"

$MatchPatter = '<!\[LOG\[Get policies = (.*)\]LOG\]!>'

$lines = Select-String $Path -Pattern $MatchPatter
$Apps = @()

$ln_dig = "D{0}" -f $lines.count.ToString().Length
Foreach ($line in $lines) {
    
    if ($($Line.line) -match 'time="(\d{2}:\d{2}:\d{2}\.\d+)" date="(\d{1,2}-\d{1,2}-\d{4})"') {
        $formattedDateTime = [DateTime]::ParseExact("$($matches[2]) $($matches[1])", "M-d-yyyy H:mm:ss.fffffff", $null).ToString((Get-Culture).DateTimeFormat)
    }

    Write-host "Policy ($(($lines.IndexOf($line) + 1).ToString($ln_dig)) of $($lines.count)) $formattedDateTime" -ForegroundColor Green
    $json = $($line.Matches.Groups[1].Value) | ConvertFrom-Json
    if ($json -ne $null) {
        $app_dig = "D{0}" -f $json.count.ToString().Length
        Foreach ($app in $json) {
            Write-Host "App ($((($json.IndexOf($app) + 1)).ToString($app_dig)) of $($json.count)): $($app.Name)"
        }
    }
    else {
        Write-Host "Empty policy or error in parsing the policy." -ForegroundColor Red
        write-host "Line: $($line.Line)" -ForegroundColor Red
        Write-Host "File (GoTo): $($line.Path):$($line.LineNumber)" -ForegroundColor Red
    }
    Write-host ""
}