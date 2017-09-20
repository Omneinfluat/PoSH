<#
.SYNOPSIS 
    Creates a new shortcut
.DESCRIPTION
    The New-Shortcut script creates a new
    shortcut file (.lnk) to a target file

    You can add arguments, icons etc.
.PARAMETER SourceFile
    Full path to file to point link to
.PARAMETER DestinationPath
    Full path to new link (.lnk) object
.PARAMETER ArgumentsToSourceFile
    Arguments to call SourceFile with
.PARAMETER LinkDescription
    Description for the Link
.PARAMETER LinkWorkingDirectory
    Working directory for link if other than dir for Sourcefile
.PARAMETER LinkHotkey
    Hotkey for link
.PARAMETER LinkIcon
    Icon for link
.PARAMETER LinkWindowStyle
    Window Style of link (1=Normal, 3=Max, 7=Min)
.OUTPUTS
.EXAMPLE
.LINK  
    https://stackoverflow.com/questions/9701840/how-to-create-a-shortcut-using-powershell
    http://powershellblogger.com/2016/01/create-shortcuts-lnk-or-url-files-with-powershell/
.NOTES
    Name..........: New-Shortcut.ps1
    Directory.....: 
    Author........: Omneinfluat\Erik Carlsson
    Created.......: 2017-09-20
    ChangeDate....: 2017-09-20
    LatestEditor..: Carlsson Erik (Adm-8C) (ECA1-8C) carlsson_erik@outlook.com
    Common use....: 

    This is based on code from: https://stackoverflow.com/questions/9701840/how-to-create-a-shortcut-using-powershell
    https://stackoverflow.com/users/520612/cb

    And: http://powershellblogger.com/2016/01/create-shortcuts-lnk-or-url-files-with-powershell/
    Steve Parankewich
    
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
    [Parameter(Position=0,mandatory=$True,HelpMessage="Full path to file to point link to")][string]$SourceFile,
    [Parameter(Position=1,mandatory=$True,HelpMessage="Full path to new link (.lnk) object")][string]$DestinationPath,
    [Parameter(HelpMessage="Arguments to call SourceFile with")][string]$ArgumentsToSourceFile,
    [Parameter(HelpMessage="Description for the Link")][string]$LinkDescription,
    [Parameter(HelpMessage="Working directory for link if other than dir for Sourcefile")][string]$LinkWorkingDirectory,
    [Parameter(HelpMessage="Hotkey for link")][string]$LinkHotkey,
    [Parameter(HelpMessage="Icon for link")][string]$LinkIcon = "$SourceFile, 0",
    [Parameter(HelpMessage="Window Style of link (1=Normal, 3=Max, 7=Min)")][ValidateSet(1,3,7)][Int]$LinkWindowStyle = 1
)


$WshShell = New-Object -comObject WScript.Shell #Create the new object
$Shortcut = $WshShell.CreateShortcut($DestinationPath) #Load the object with new shortcut

$Shortcut.TargetPath = $SourceFile #Load the shortcut with path to target
IF ($ArgumentsToSourceFile){ #Add arguments
    $Shortcut.Arguments = $ArgumentsToSourceFile
}

$Shortcut.Description = $LinkDescription; #Add a Link description

IF (-not($LinkWorkingDirectory)) { #If not specifically provided sets working directory to the directory of the source file
    $LinkWorkingDirectory = $SourceFile | Split-Path -Parent
}
$ShortCut.WorkingDirectory = $LinkWorkingDirectory; #Add the working dir

$ShortCut.WindowStyle = $LinkWindowStyle; #Add window style (1=Normal, 3=Max, 7=Min)

IF ($LinkHotkey) {  #If specified add link hotkey
    $ShortCut.Hotkey = $LinkHotkey;
}

$ShortCut.IconLocation = $LinkIcon; #add link icon

$Shortcut.Save() #Save (create) the shortcut

