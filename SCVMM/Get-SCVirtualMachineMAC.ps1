<#
.SYNOPSIS 
    List all VMM virtual Machine MACs as Dynamic or static
.DESCRIPTION
    The script lists all VMM Virtual Machine MACs both dynamic and
    static

    Output both and creates a CSV where it's specified servername, 
    MAC address and MAC type

    CSV is formated with default encoding and useculture

    Builds on script by Makus Lassfolk at Isolation.se
.PARAMETER VMMserver
    VMM server to connect to
.PARAMETER CSVPath
    Path to CSV to store output in
.OUTPUTS
    Write Output lists 
    CSV file formated with default encoding and useculture
.EXAMPLE

.LINK  
    http://www.isolation.se/list-all-vms-with-a-dynamic-mac-address/
.NOTES
    Name..........: Get-SCVirtualMachineMAC.PS1
    Author........: Omneinfluat\Erik Carlsson
    Created.......: 2018-08-23
    ChangeDate....: 2018-08-23
    LatestEditor..: Carlsson Erik (Adm-8C) (ECA1-8C) carlsson_erik@outlook.com
    Common use....: 

    MIT License

    Copyright (c) 2018 Omneinfluat

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>

[CmdletBinding()]
Param(
    [Parameter(Position=0, Mandatory=$true, HelpMessage="VMM server to connect to")] [String]$VMMserver,
    [Parameter(Position=1, HelpMessage="Path to CSV to store output in")] [String]$CSVPath = "$env:TEMP\SCVirtualMachineMACs.csv"
)

# Get all VM's from Localhost (change to SCVMM Server if running remote) 
$AllVMS = Get-SCVirtualMachine -VMMServer $VMMserver
$DynamicVMs = @()
$DynamicVMsMACs = @()
$DynamicMACList = @()
 
# For each VM, check Virtual Network Adapters if Mac = Dynamic. 
foreach ($vm in $AllVMS ) {
   $vmnics = $vm | Get-SCVirtualNetworkAdapter
     if ($vmnics.MACAddressType -eq "Dynamic") {     
        $DynamicVMs += $vm.Name
        $DynamicVMsMACs += $vmnics.MACAddress
        $DynamicMACList += New-Object psobject -Property @{VMName=$($vm.Name);VMMACAddress=$($vmnics.MACAddress);MACType="Dynamic"}
     }
}
 
$DynamicMACList | Export-Csv -Path $CSVPath -Encoding Default -UseCulture -Force

# List all VM's with a Dynamic Mac address. 
$DynamicVMs | Sort-Object
Write-Output "--------"
$DynamicVMsMACs
Write-Output "--------"
$DynamicMACList | Sort-Object
Write-Output "--------"
$DynamicVMs.Count

# Get all VM's from Localhost (change to SCVMM Server if running remote) 
$AllVMS = Get-SCVirtualMachine -VMMServer $VMMserver
$StaticVMs = @()
$StaticVMsMACs = @()
$StaticMACList = @()
 
# For each VM, check Virtual Network Adapters if Mac = Static. 
foreach ($vm in $AllVMS ) {
   $vmnics = $vm | Get-SCVirtualNetworkAdapter
     if ($vmnics.MACAddressType -eq "Static") {     
        $StaticVMs += $vm.Name
        $StaticVMsMACs += $vmnics.MACAddress
        $StaticMACList += New-Object psobject -Property @{VMName=$($vm.Name);VMMACAddress=$($vmnics.MACAddress);MACType="Static"}
     }
}

$StaticMACList | Sort-Object VMName | Export-Csv -Path $CSVPath -Encoding Default -Append -UseCulture

# List all VM's with a Static Mac address. 
$StaticVMs | Sort-Object
Write-Output "--------"
$StaticVMsMACs
Write-Output "--------"
$StaticMACList | Sort-Object
Write-Output "--------"
$StaticVMs.Count
Write-Output "--------"
Write-Output "CSV path is $CSVPath"
