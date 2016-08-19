

##################
# Misc Stuff
##################
$Computername = 'MN-Credit08'
$Computername = $env:COMPUTERNAME

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
$ComputerInfoHTML = $info.ComputerInfo | Select Name,Manufacturer,Model,Domain | ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Computer Info' + '</h3>')
#$ServicesInfoHTML = $info.Services | sort Startmode,Started | Select PSComputerName,Name,StartMode,Started,State,DisplayName,Description,AcceptPause,AcceptStop | ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Services' + '</h3>')


$ServicesInfoHTML = $info.Services | where { ($_.Started -eq $False) -and ($_.StartMode -eq 'Auto')  } | sort Startmode,Started | Select PSComputerName,Name,StartMode,Started,State,DisplayName,Description,AcceptPause,AcceptStop | ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Services' + '</h3>' )


$DiskInfoHTML = $info.DiskInfo | Sort DeviceID | Select DeviceID,@{N='FreeSpace(gb)';E={ "{0:N0}" -f ($_.FreeSpace / 1gb) }},@{N='Size(gb)';E={ "{0:N0}" -f ($_.Size / 1gb) }},DriveType |ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Disk Info' + '</h3>')






##################
# Begining
##################
$Begining = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
"@
$Fragments += $Begining 


##################
# Navigation bar content
##################
$NAVBar = @"
    <nav id="nav">
        <!-- <a href="index.html">Home</a> -->
        <!-- <a> - </a>  -->
        <a href=#topoffile>Top</a> 
        <a> - </a>
        <!-- <a href=#systeminfo>SystemInfo</a>  -->
        <!-- <a> - </a>  -->
        <!-- <a href=#diskinfo>Disk Info</a>  -->
        <!-- <a> - </a>  -->
        <!-- <a href=#services>Servics</a>  -->
        <a href=#bottomoffile>Bottom</a>
        <a> - </a>
        <a href="http://bing.lmgtfy.com/?q=I+hate+bing+search+tool" target="_blank">Bing Search</a>
    </nav>
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

    </head>
    <body>
"@ 


		
##################
# ???
##################

$Counter=0  ##?? Update this nin some kind of loop?
$ComputerName2 = ($ComputerName + '-- make this a loop')
##?? update this to a loop and add <LI> for each object
$HTMLCode=@"	
    $NAVBar
    <ul class="collapsibleList">
	    <li>
		    <label for="mylist-node1" id="collapsibleListheadder">$ComputerName</label>
            <input type="checkbox" id="mylist-node1" />
            <ul>
                <li>
                    $ServicesInfoHTML
                </li>
			    <li>
				    $DiskInfoHTML
			    </li>
			    <li>
				    $ComputerInfoHTML
			    </li>
            </ul>
        </li>
        <li>
            <label for="mylist-node2" id="collapsibleListheadder">$ComputerName2</label>
		    <input type="checkbox" id="mylist-node2" />
            <ul>
                <li>
				    $ServicesInfoHTML
                </li>
			    <li>
				    $ServicesInfoHTML
			    </li>
			    <li>
				    $ServicesInfoHTML
			    </li>
            </ul>
        </li>
    </ul>
"@


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


#$Temp = ($Begining  + "`r`n" + $head+ "`r`n" + $HTMLCode  + "`r`n" + $Footer  + "`r`n")
$Temp = @"

$Begining 
$head
$HTMLCode
$Footer
</html>
"@


$Temp = $Temp -REPLACE '<table>', ("`r`n`t`t`t`t`t`t" + '<table>')
$Temp = $Temp -REPLACE '</table>', ("`r`n`t`t`t`t`t`t" + '</table>')
$Temp = $Temp -REPLACE '<colgroup>', ("`r`n`t`t`t`t`t`t`t" + '<colgroup>')
$Temp = $Temp -REPLACE "<tr><th>", ("`r`n`t`t`t`t`t`t`t" + '<tr><th>')
$Temp = $Temp -REPLACE "<tr><td>", ("`r`n`t`t`t`t`t`t`t`t" + '<tr><td>')



<#
# Add some ID's to colorize (warnings, disabled, etc)
$Temp = $Temp -REPLACE '<td></td>','<td id="blank"></td>'
$Temp = $Temp -REPLACE '<td>Auto</td><td>False</td>','<td>Auto</td><td id="warning">False</td>'
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

