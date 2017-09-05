<#
.SYNOPSIS 
    Installs WPI on server
.DESCRIPTION
    The Install-WPI script Downloads Wep Platform Installer
    from Microsoft, installs it and the optionally installs
    WPI products.

    Run locally on IIS server
.PARAMETER DownloadTarget
    Target folder to download WPI to, will be created if it
    doesn't exist.
.PARAMETER DownloadSource
    URL to download from, will be checked for connectivity
.PARAMETER DownloadFile
    Name of file to download, defalt is the (current) 
    name of the x64 file
.PARAMETER DownloadFilex86
    (Current) name of the x86 file

    If you have an x86 system provide the filename here instead.
.PARAMETER installmode
    Possible values: Silent, Passive, Interactive. 
    
    Silent will install without any gui (msi /qn)
    
    Passive will install with basic gui (msi /qb)
    
    Interactive will install with full gui and interaction 
    required (msi)
.PARAMETER WPIlocation
    Where WPI is installed on computer, normally:
    $env:ProgramFiles\Microsoft\Web Platform Installer
.PARAMETER WPIproducts
    Use if any WPI products should be installed
    Comma separated list

    Once WPI is installed you can run 
    WebPICMD.exe /List /ListOption:All
    to get productnames to install
.PARAMETER NoDownload
    Switch - if set no download will be executed,
    instead install will take place fromfile specified by

    -DownloadTarget and -DownloadFile
.PARAMETER NoInstall
    Switch - if set no install of WPI will be executed,
    
    only Download will happen.

    If used in conjucture with -NoDownload only product installation
    will place, if no products are selected nothing will happen.
.EXAMPLE
    Install-WPI

    Downloads web plattform installer from default url and
    to default target dir (C:\Install), then silent installs it
    (msi /qn).

    Checks that the URL works otherwise Returns a "Download Failed"

    Checks that the target directory exists, otherwise creates it.
.EXAMPLE
    Install-WPI -InstallMode Passive -WPIproducts "ARRv3_0"

    Downloads web plattform installer from default url and
    to default target dir (C:\Install), then installs it showing progress
    but without interaction (msi /qb).

    Then goes on to install "Application Request Routing 3.0" and any
    dependendants (such ass URL Rewrite 2.0) not already installed.
.EXAMPLE
    Install-WPI -NoDownload -NoInstall -WPIproducts "ARRv3_0"

    Skips the download part and skips the install WPI part

    Then Installs "Application Request Routing 3.0" and any
    dependendants.
.LINK
    https://docs.microsoft.com/en-us/iis/install/web-platform-installer/web-platform-installer-direct-downloads
    https://github.com/Omneinfluat/PoSH/tree/master/IIS
.NOTES
    Path..........: 
    Name..........: Install-WPI.PS1
    Author........: Omneinfluat/Erik Carlsson
    Created.......: 2016-06-08
    ChangeDate....: 2017-09-05
    LatestEditor..: Carlsson Erik (Adm-8C) (ECA1-8C) carlsson_erik@outlook.com
    Common use....: 
    
    MIT License

    Copyright (c) 2017 Omneinfluat

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
    [Parameter(HelpMessage="Target directory, will be created if it doesn't exists")][String]$DownloadTarget = "c:/install",
    [Parameter(HelpMessage="Source URL, will be checked for access")][String]$DownloadSource = "http://download.microsoft.com/download/C/F/F/CFF3A0B8-99D4-41A2-AE1A-496C08BEB904",
    [Parameter(HelpMessage="File to download")][String]$DownloadFile = "WebPlatformInstaller_amd64_en-US.msi",
    [Parameter(HelpMessage="File to download")][String]$DownloadFilex86 = "WebPlatformInstaller_amd64_en-US.msi",
    [Parameter(Position=0,HelpMessage="Possible values:Silent,Passive,Interactive, default Silent")][ValidateSet("Silent","Passive","Interactive")][String]$InstallMode = "Silent",
    [Parameter(HelpMessage="DirectoryWhere WPI has been installed")][String]$WPIlocation = "$env:ProgramFiles\Microsoft\Web Platform Installer",
    [Parameter(Position=1,HelpMessage="WPIproducts to install")][String[]]$WPIproducts,
    [Parameter(HelpMessage="use if no downloading but install from existing file")][Switch]$NoDownload,
    [Parameter(HelpMessage="use if no downloading but install from existing file")][Switch]$NoInstall
)

#region Check processor architecture
$OS_arch = $ENV:PROCESSOR_ARCHITECTURE
IF ($OS_arch -match "86") {$DownloadFile = $DownloadFilex86}
#endregion

#region Download 
IF (-not($NoDownload)){ #If NoDownload is set continues to installation
    #Verify that url is reachable   
    Try {
        $WebRequestResult = Invoke-WebRequest "$DownloadSource/$DownloadFile" -Method Head
        IF ($WebRequestResult.StatusCode -ne 200) {Return "Download Failed"}
    }
    Catch {Return "Download Failed, path error"}
    
    #Create targetdir if not exists
    IF (-not(Test-Path $DownloadTarget -PathType Container)) {New-Item $DownloadTarget -ItemType Directory}
    
    #Do the download stuff
    Invoke-WebRequest "$DownloadSource/$DownloadFile" -OutFile "$DownloadTarget\$DownloadFile"
}
#endregion

#region Install WPI
IF (-not($NoInstall)) { #If NoInstall is set continues to product installation
    #And do the install thingy with different interaction modes
    SWITCH ($InstallMode) {
        Silent {Start-Process "$DownloadTarget\$DownloadFile" '/qn' -PassThru | Wait-Process}
        Passive {Start-Process "$DownloadTarget\$DownloadFile" '/qb' -PassThru | Wait-Process}
        Interactive {Start-Process "$DownloadTarget\$DownloadFile" -PassThru | Wait-Process}
    }
}
#endregion
    
#region install WPI products if any is defined
IF ($WPIproducts) {
    IF (-not(Test-Path "$WPIlocation\WebpiCmd.exe" -PathType Leaf)) {Return "No WPI installed to $WPIlocation"} #If WPI hasn't been installed products can't be installed
    Push-Location $WPIlocation
    .\WebpiCmd.exe /Install /Products:$WPIproducts /AcceptEULA /Log:c:/install/WebpiCmd.log
    Pop-Location
}
#endregion
