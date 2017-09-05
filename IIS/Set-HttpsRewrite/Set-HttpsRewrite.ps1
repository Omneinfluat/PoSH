<#
.SYNOPSIS
    Sets up http to https url rewrite
.DESCRIPTION
    The Set-HttpsRewrite script creates an IIS URL
    rewrite from http to https on the sites given
    as parameter for sites in IIS location iis:\sites.

    The script requires the url rewrite module to be 
    installed.

    This can be done via Web Plattform Installer
    Scripted or manually.

    https://github.com/Omneinfluat/PoSH/tree/master/IIS/Install-WPI
.PARAMETER Sites
    Name(s) of the IIS site(s) to create a rewrite 
    rule for.

    I.e. the name of the site as it appears in IIS.
.LINK
    https://docs.microsoft.com/en-us/iis/install/web-platform-installer/web-platform-installer-direct-downloads
    https://github.com/Omneinfluat/PoSH/tree/master/IIS
.NOTES
    Path..........: 
    Name..........: Set-HttpsRewrite.PS1
    Author........: Omneinfluat/Erik Carlsson
    Created.......: 2017-09-05
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
    [Parameter(Mandatory=$true,Position=0, HelpMessage="IIS site names")] [String[]]$Sites
)

#region https redirect
ForEach ($Site IN $Sites) {
$site = "iis:\sites\$sitename"
$filterRoot = "system.webServer/rewrite/rules/rule[@name='Redirect to HTTPS']"
Clear-WebConfiguration -pspath $site -filter $filterRoot
Add-WebConfigurationProperty -pspath $site  -filter "system.webServer/rewrite/rules" -name "." -value @{name='Redirect to HTTPS';patternSyntax='Regular Expressions';stopProcessing='true'} -AtIndex 0
Set-WebConfigurationProperty -pspath $site  -filter "$filterRoot/match" -name "url" -value "(.*)"
Set-WebConfigurationProperty -pspath $site  -filter "$filterRoot/conditions" -Name "." -value @{input="{HTTPS}";pattern='^OFF$'}
Set-WebConfigurationProperty -pspath $site  -filter "$filterRoot/action" -name "type" -value "Redirect"
Set-WebConfigurationProperty -pspath $site  -filter "$filterRoot/action" -name "url" -value "https://{HTTP_HOST}/{R:1}"
Set-WebConfigurationProperty -pspath $site  -filter "$filterRoot/action" -name "redirectType" -value "SeeOther"
}
#endregion
