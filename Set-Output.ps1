param (
    [string]$device = $null
)

# Check if the AudioDeviceCmdlets module is installed
$moduleInstalled = Get-Module -ListAvailable | Where-Object { $_.Name -eq 'AudioDeviceCmdlets' }

# If the module is not installed, try to install it with admin privileges
if (-not $moduleInstalled) {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        # If not running with admin privileges, restart with admin privileges
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        Exit
    }
    else {
        # Running with admin privileges, attempt to install the module
        Install-Module -Name AudioDeviceCmdlets -Repository PSGallery -Force
    }
}

# Import the module
Import-Module AudioDeviceCmdlets

# List all available audio output devices
$devices = Get-AudioDevice -List

# Prompt the user to choose a device
If($device -eq $null){
    $chosenDevice = Read-Host "which device (h for headset / b for bluetooth)?"
}
else {
    $chosenDevice = $device;
}


$chosenDevice = If ($chosenDevice -eq "b") { "Headphones (2- BT SPEAKER)" } Else { "Speakers (High Definition Audio Device)" };

$result = $null;
foreach ($d in $devices) {
    if ($d.Name -eq $chosenDevice) {
        $result = $d
        break;
    }
}

# Set the chosen device as the default output
Set-AudioDevice -ID $result.ID
