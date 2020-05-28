<#
.DESCRIPTION
    "Write-HostAndLog" function is used to replace "Write-Host" because it writes the message in console and also save it on log file.
    The log file has the same name of script and is stored on the same folder.
    You need to copy all variables declared before function and the function itself.
    This function doesn't work with PowerShel ISE because it can't find the ScriptPath.
#>

#requires -version 3

# Define path and timestamp
$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$ScriptNameAndExtension = $MyInvocation.MyCommand.Definition.Split("\") | Select-Object -Last 1
$ScriptName = $ScriptNameAndExtension.Split(".") | Select-Object -First 1
$TimeStamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm")

# Define task log file name
$Logs = "$($ScriptPath)\$($ScriptName)_$($TimeStamp).log"
$MainLog = "$($ScriptPath)\$($ScriptName).log"

# Function: Write to console and current log
function Write-HostAndLog{
    <#
    .SYNOPSIS
        Function to write messages to console and also to LOG file.

    .DESCRIPTION
        This function is used to replace Write-Host because it shows the message in console and also save it log file at the same folder where your script is running.

    .EXAMPLE
        Write-HostAndLog "Message that needs to be printed on console and log file!"
        The text "Message that needs to be printed on console and log file!" will be write on console and also in log file.
    
    .EXAMPLE
        Write-HostAndLog "Message that needs to be printed on console and log file!" -ForegroundColor Green
        The text "Message that needs to be printed on console and log file!" will be write on console in green and also in log file.

    .EXAMPLE
        Write-HostAndLog "Message that needs to be printed on console and log file!" -NoNewline
        The text "Message that needs to be printed on console and log file!" will be write on console and also in log file. Next text will be write at the same line.

    .NOTES
        To have a timestamp in each message line, we usually use the term $(Get-Date) before message, for example:
        Write-HostAndLog "$(Get-date) - Message..."
        So the message will be written like:
        05/27/2020 10:21:02 - Message...
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        # Text that will be written on PowerShell console and log file.
        $Message,
        [string]
        # ForegroundColor parameter to change text color.
        $ForegroundColor,
        [switch]
        # NoNewline switch to write the next text in the same line.
        $NoNewline
    )
    Begin{}
    Process{
        If ($NoNewline){
            $Script:LineBuffer += $Message
            If ($ForegroundColor){ Write-Host $Message -ForegroundColor $ForegroundColor -NoNewline }
            Else{ Write-Host $Message -NoNewline }
        }
        Else{
            $testmsg = $false
            while (-not $testmsg){
                try {
                    Out-File $Logs -InputObject "$($Script:LineBuffer)$($Message)" -Append
                    $testmsg = $true
                }
                catch {
                    Write-Host "Retrying to write in log file..."
                    Start-Sleep -Seconds 1
                }
            }
            $Script:LineBuffer = $null
            If ($ForegroundColor){ Write-Host $Message -ForegroundColor $ForegroundColor }
            Else{ Write-Host $Message }
        }
    }
    End{}
}

# Start script
Out-File -FilePath $Logs -InputObject "$(Get-Date) - Log Begin"

#################################
####   PUT YOUR SCRIPT HERE   ###
#################################

# End script log
Write-HostAndLog "$(Get-Date) - Log End"
Write-HostAndLog " "

# Merge current log
$LogContent = Get-Content $Logs
Out-File -FilePath $MainLog -InputObject $LogContent -Append
Remove-Item $Logs