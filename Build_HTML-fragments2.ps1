

##################
# Misc Stuff
##################
#$Computername = 'MN-Credit08'
#$Computername = $env:COMPUTERNAME
$ComputerList = @()
#$ComputerList += 'MN-Credit08'
#$ComputerList += 'MN-SecureData'
$ComputerList += $env:COMPUTERNAME


# cleanup PS environment
#$HTMLFile = 'C:\Users\T910411\Desktop\Temp\HTML\_junk.html'
$HTMLFile = 'C:\Users\T910411\Desktop\Temp\HTML\_junk.html'
Remove-Item $HTMLFile -ea 0 
Remove-Variable Temp,temp2,temp2 -ea 0 

# Set some variables
#$StyleSheet = 'http://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css'
#$StyleSheet = 'C:\Users\T910411\Desktop\Temp\HTML\_junk.css'
$StyleSheet = '_junk.css'
$date = (Get-Date | Out-String).trim()
$Title = 'Computer Report'
$Header = 'My CSS Testing'
$Fragments = @()
#$buffer = '<p></p>'
$buffer = '<BR>'






##################
# Begining
##################
$Begining = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
"@


##################
# Header Data
##################
$head = @"
    <head>
        <a name="topoffile">
        <link rel="stylesheet" href="$StyleSheet"></link>
        <title>$Title</title>
        <h1>$Header</h1>
        $NAVBar
    </head>
    <body>
"@ 






##################
# Navigation bar content
##################
$NAVBar = @"
`t`t<nav id="nav">
`t`t`t`t<!-- <a href="index.html">Home</a> -->
`t`t`t<!-- <a> - </a>  -->
`t`t`t<a href=#topoffile>Top</a> 
`t`t`t<a> - </a>
`t`t`t<!-- <a href=#systeminfo>SystemInfo</a>  -->
`t`t`t<!-- <a> - </a>  -->
`t`t`t<!-- <a href=#diskinfo>Disk Info</a>  -->
`t`t`t<!-- <a> - </a>  -->
`t`t`t<!-- <a href=#services>Servics</a>  -->
`t`t`t<a href=#bottomoffile>Bottom</a>
`t`t`t<a> - </a>
`t`t`t<a href="http://bing.lmgtfy.com/?q=I+hate+bing+search+tool" target="_blank">Bing Search</a>
`t`t</nav>
"@


$HTMLCode = @()
foreach ($Computername in $ComputerList)
{

    ##?? Temp? used to add navigation bar under sections? # need to add dynamic anchors ##??
    $NAVBar2 = @"
    `t`t`t`t<nav id="nav2">
    `t`t`t`t`t<a href=#topoffile>Top</a> 
    `t`t`t`t`t<a> - </a>
    `t`t`t`t`t<a href=#Services-$ComputerName>Services</a> 
    `t`t`t`t`t<a> - </a>
    `t`t`t`t`t<a href=#ComputerInfo-$ComputerName>Computer Info</a> 
    `t`t`t`t`t<a> - </a>
    `t`t`t`t`t<a href=#DiskSpaceInfo-$ComputerName>Disk Space</a>
    `t`t`t`t`t<a> - </a>
    `t`t`t`t`t<a href=#bottomoffile>Bottom</a>
    `t`t`t`t</nav>
"@



##################
# create dynamic variable 
# (used to execute code) 
##################
$info = New-Object -TypeName psobject
$info | Add-Member -Name Services -MemberType ScriptProperty -Value {gwmi win32_SERVICE -ComputerName $Computername | where {$_.Started -eq $false}  }
$info | Add-Member -Name HotFixs -MemberType ScriptProperty -Value {Get-HotFix -ComputerName $Computername}
$info | Add-Member -Name ComputerInfo -MemberType ScriptProperty -Value {gwmi Win32_ComputerSystem -ComputerName $Computername}
$info | Add-Member -Name DiskInfo -MemberType ScriptProperty -Value { gwmi Win32_LogicalDisk -ComputerName $Computername | where {$_.DriveType -eq 3}  }


# Collect Info
#$ComputerInfoHTML = $info.ComputerInfo | Select Name,Manufacturer,Model,Domain | ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Computer Info' + '</h3>' + '<a name="systeminfo"></a>')
$ComputerInfoHTML = $info.ComputerInfo | 
    Select Name,Manufacturer,Model,Domain | 
        ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Computer Info' + '</h3>' + ('<a name="ComputerInfo-' + $Computername + '"></a>')     )
#$ServicesInfoHTML = $info.Services | sort Startmode,Started | Select PSComputerName,Name,StartMode,Started,State,DisplayName,Description,AcceptPause,AcceptStop | ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Services' + '</h3>')
$ServicesInfoHTML = $info.Services | where { ($_.Started -eq $False) -and ($_.StartMode -eq 'Auto')  } | sort Startmode,Started | 
    Select PSComputerName,Name,StartMode,Started,State,DisplayName,Description,AcceptPause,AcceptStop | 
        ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Services' + '</h3>' + ('<a name="Services-' + $Computername + '"></a>') )
$DiskInfoHTML = $info.DiskInfo | Sort DeviceID | 
    Select DeviceID,@{N='FreeSpace(gb)';E={ "{0:N2}" -f ($_.FreeSpace / 1gb) }},@{N='Size(gb)';E={ "{0:N2}" -f ($_.Size / 1gb) }},@{N='PercentFree';E={ "{0:P4}" -f ($_.Freespace / $_.size)   }}, DriveType | 
        ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Disk Info' + '</h3>' + ("`t`t" + '<a name="DiskSpaceInfo-' + $Computername + '"></a>'))



<#

# Disk space evaluator
$RegexDiskSpace = [regex]"<td>\d{1,3}."
$Spacewarning = 50

$DiskInfoHTML | % {
    
    $Temp2 = ($_ | Select-String $RegexDiskSpace).Matches.Value

    $temp3 = (  ($Temp2 -replace '<td>', '') -replace '%</td>',''    ).trim()
    If ( $temp3 -lt $Spacewarning)
    {
        Write-Host (   (  ($temp2 -replace '<td>', '') -replace '%',''    )   ) -ForegroundColor Yellow
        #Write-Host ( (  ($_ -replace '<td>', '').Trim() -replace '%</td>',''    )   ) -ForegroundColor Yellow
        $_ -replace '<td>', '<td id="warning">' 
    }
    else
    {
        Write-Host ($_) -ForegroundColor Green
    }

}

#>

		
    ##################
    # ???
    ##################
    $Counter=0  ##?? Update this nin some kind of loop?
    $ComputerName2 = ($ComputerName + '-- make this a loop')
    ##?? update this to a loop and add <LI> for each object
$HTMLCode += @"
        <li>
		    <label for="mylist-$ComputerName" id="collapsibleListheadder">$ComputerName</label>
            <input type="checkbox" id="mylist-$ComputerName" />
            <ul>
$NAVBar2
                <li>
                    $ComputerInfoHTML
                </li>

			    <li>
				    $DiskInfoHTML
			    </li>

			    <li>
				    $ServicesInfoHTML
			    </li>
            </ul>

        </li>
"@


} # (foreach $ComputerList)






##################
# Footer
##################
$Footer = @"
    </body>
    <footer>
        `t <a name="bottomoffile" id="bottompadding"></a>
$NAVBar
        <BR>
        <object id="datestamp">$date</object>
        <BR>
        </footer>
"@ 


# Assemble HTML code
$Temp = @"
$Begining 
$head
<ul class="collapsibleList">
$HTMLCode
</ul>       
$Footer
</html>
"@

# Parse HTML code, ad id's, do some formatting, etc.
$Temp = $Temp -REPLACE '<table>', ("`r`n`t`t`t`t`t`t" + '<table>')
$Temp = $Temp -REPLACE '</table>', ("`r`n`t`t`t`t`t`t" + '</table>')
$Temp = $Temp -REPLACE '<colgroup>', ("`r`n`t`t`t`t`t`t`t" + '<colgroup>')
$Temp = $Temp -REPLACE "<tr><th>", ("`r`n`t`t`t`t`t`t`t" + '<tr><th>')
$Temp = $Temp -REPLACE "<tr><td>", ("`r`n`t`t`t`t`t`t`t`t" + '<tr><td>')

$Temp = $Temp -REPLACE '<td></td>','<td id="blank"></td>'
$Temp = $Temp -REPLACE '<td>Auto</td><td>False</td>','<td>Auto</td><td id="warning">False</td>'
$Temp = $Temp -REPLACE  '</h3>', ('</h3>' + "`r`n`t`t`t`t")
#$Temp = $Temp -REPLACE  '</li>', ('</li>' + "`r`n`t`t" + '<BR>')



<#
# Add some ID's to colorize (warnings, disabled, etc)
$Temp = $Temp -REPLACE '<td>Disabled</td>','<td id="Disabled">Disabled</td>'
$Temp = $Temp -REPLACE '<td>Manual</td>','<td id="manual">Manual</td>'
#$Temp = $Temp -REPLACE ('<tr><td>' + $Computername), ("`t" + '<tr><td>' + $Computername)
$Temp = $Temp -REPLACE ('<tr><td>'), ("`t" + '<tr><td>')
$Temp = $Temp -REPLACE '<tr><th>', "`t<tr><th>"
$Temp = $Temp -REPLACE "<colgroup>","`t<colgroup>"
$Temp = $Temp -REPLACE '<h3',"`t<h3"
#>


# export HTML data to html file
$Temp | Out-File $HTMLFile


# Open HTML in editor
C:\Tools\Notepad++\notepad++.exe $HTMLFile


################################
<#



TODO 
==========
- fix 'mylist-node' to have a dynamic number
- update links in each <LI> make them dynamic and include just that section's anchors

#>

