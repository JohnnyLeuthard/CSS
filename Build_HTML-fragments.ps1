
$Computername = 'MN-Credit08'
$Computername = $env:COMPUTERNAME

# cleanup PS environment
Remove-Item $HTMLFile -ea 0 
Remove-Variable Temp,temp2,temp2 -ea 0 

# Set some variables
$StyleSheet = 'C:\Users\T910411\Desktop\Temp\HTML\main2.css'
#$StyleSheet = 'main.css'
$date = (Get-Date | Out-String).trim()
$HTMLFile = 'C:\Users\T910411\Desktop\Temp\HTML\Testing.html'
$Title = 'Computer Report'
$Header = 'My CSS Testing'
$Fragments = @()
#$buffer = '<p></p>'
$buffer = '<BR>'

########

 
# Navigation bar content
 $NAVBar = @"
    <nav id="nav">
        <a href="index.html">Home</a>
        <a href=#topoffile>Top</a>
        <a href=#systeminfo>SystemInfo</a>
        <a href=#diskinfo>Disk Info</a>
        <a href=#services>Servics</a>
        <a href=#bottomoffile>Bottom</a>
        <a href="http://bing.lmgtfy.com/?q=I+hate+bing+search+tool" target="_blank">Bing Search</a>
    </nav>
"@
# used to add navigation bar
$Nav = ($NAVBar)

# create dynamic variable (used to execute code) (future possibly multiple different datasets)
$info = New-Object -TypeName psobject
$info | Add-Member -Name Services -MemberType ScriptProperty -Value {gwmi win32_SERVICE -ComputerName $Computername | where {$_.Started -eq $false}  }
$info | Add-Member -Name HotFixs -MemberType ScriptProperty -Value {Get-HotFix -ComputerName $Computername}
$info | Add-Member -Name ComputerInfo -MemberType ScriptProperty -Value {gwmi Win32_ComputerSystem -ComputerName $Computername}
#$info | Add-Member -Name DiskInfo -MemberType ScriptProperty -Value { gwmi Win32_LogicalDisk -ComputerName $Computername | where {$_.DriveType -eq 3}  }
$info | Add-Member -Name DiskInfo -MemberType ScriptProperty -Value { gwmi Win32_LogicalDisk -ComputerName $Computername   }

$Begining = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
"@
$Fragments += $Begining 


# Header
$head = @"
    <head>
        <a name="topoffile">
        <link rel="stylesheet" href="$StyleSheet"></link>
        <title>$Title</title>
        <h1>$Header</h1>
$nav
    </head>
    <body>
"@ 


 

$SystemName =  @"
`t`t<h2>$Computername<h2>
"@ 

$ComputerInfoHTML = $info.ComputerInfo | Select Name,Manufacturer,Model,Domain  |ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Computer Info' + '</h3>' + '<a name="systeminfo"></a>')
$ServicesHTML = $info.Services | sort Startmode,Started | Select PSComputerName,Name,StartMode,Started,State,DisplayName,Description,AcceptPause,AcceptStop | ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Services' + '</h3>')
$DiskInfo = $info.DiskInfo | Sort DeviceID | Select DeviceID,@{N='FreeSpace(gb)';E={ "{0:N0}" -f ($_.FreeSpace / 1gb) }},@{N='Size(gb)';E={ "{0:N0}" -f ($_.Size / 1gb) }},DriveType |ConvertTo-Html -As table -Fragment -PreContent ('<h3>' + 'Disk Info' + '</h3>')



$Fragments += $head
#$Fragments += $buffer
$Fragments += $SystemName 
$Fragments += $Nav
#$Fragments += $buffer
$Fragments += ("`t" + '<a name="systeminfo"></a>')
$Fragments += $ComputerInfoHTML
$Fragments += $Nav
#$Fragments += $buffer
$Fragments += ("`t" + '<a name="diskinfo"></a>')
$Fragments += $DiskInfo
$Fragments += $Nav
#$Fragments += $buffer
$Fragments += ("`t" + '<a name="services"></a>')
$Fragments += $ServicesHTML
$Fragments += $Nav
#$Fragments += $buffer

$Counter=@"
<div style="width:195px; text-align:center;" ><iframe  src="https://www.eventbrite.com/countdown-widget?eid=20980124116" frameborder="0" height="547" width="195" marginheight="0" marginwidth="0" scrolling="no" allowtransparency="true"></iframe><div style="font-family:Helvetica, Arial; font-size:10px; padding:5px 0 5px; margin:2px; width:195px; text-align:center;" ><a class="powered-by-eb" style="color: #dddddd; text-decoration: none;" target="_blank" href="http://www.eventbrite.com/l/registration-online/">Powered by Eventbrite</a></div></div>
"@
#$Fragments += $Counter

$Footer = @"
    </body>
    <footer>

    </footer>
"@ 
#$Fragments += $buffer
$Fragments += $Footer
$Fragments += ("`t" + '<a name="bottomoffile" id="bottompadding"></a>')
$Fragments += $buffer
$Fragments += ("`t" + '<object id="datestamp">' + $date + '</object>')
$Fragments += '</html>'

# Add some ID's to colorize (warnings, disabled, etc)
$Fragments = $Fragments -REPLACE '<td></td>','<td id="blank"></td>'
$Fragments = $Fragments -REPLACE '<td>Auto</td><td>False</td>','<td>Auto</td><td id="warning">False</td>'
$Fragments = $Fragments -REPLACE '<td>Disabled</td>','<td id="Disabled">Disabled</td>'
$Fragments = $Fragments -REPLACE '<td>Manual</td>','<td id="manual">Manual</td>'
#$Fragments = $Fragments -REPLACE ('<tr><td>' + $Computername), ("`t" + '<tr><td>' + $Computername)
$Fragments = $Fragments -REPLACE ('<tr><td>'), ("`t" + '<tr><td>')
$Fragments = $Fragments -REPLACE '<tr><th>', "`t<tr><th>"
$Fragments = $Fragments -REPLACE "<colgroup>","`t<colgroup>"
$Fragments = $Fragments -REPLACE '<h3',"`t<h3"

############

# Playing around with puling multiple different info
<#
$Temp = $info.Services
$Temp2 = $Temp | sort Startmode,Started |Select PSComputerName,Name,StartMode,Started,State,DisplayName,Description,AcceptPause,AcceptStop
$Temp3 = $temp2 | ConvertTo-Html
$Services = $temp3 | select -Skip 8
#
$Temp = $info.HotFixs
$Temp2 = $Temp | sort HotFixID | Select Source,Description,Description,InstalledBy,InstalledOn
$Temp3 = $temp2 | ConvertTo-Html
$HotFixs = $temp3 | select -Skip 8


################


#$Temp3 = $TEMP3 -REPLACE "</head>", "</head>`r`n`t<body>"
# Add navigation bar to top
$Temp3 = $TEMP3 -REPLACE "</head><body>", ('</head>' + '<body>'+  $Nav)


# Tab in title element
$Temp3 = $TEMP3 -REPLACE "<title>", ("`t<title>")
# Add style sheet
$Temp3 = $TEMP3 -REPLACE "<head>",( "<head>`r`n`t" + '<link rel="stylesheet" href="' + $stylesheet + '"></link>')
# Add top of file anchor
$Temp3 = $TEMP3 -REPLACE '</link>', ( '</link>' + "`r`n`t" + '<a name="topoffile">')
# Add header
$Temp3 = $TEMP3 -REPLACE "<body>",( "<body>`r`n`t" + "<h1>$Header</h1>")
# A little cleanup
$Temp3 = $TEMP3 -REPLACE "</head><body>", ('</head>' + "`r`n" + '<body>')
 $Temp3 = $TEMP3 -REPLACE ('<tr><td>' + $Computername), ("`t" + '<tr><td>' + $Computername)
$Temp3 = $TEMP3 -REPLACE '<tr><th>SystemName', ("`t" + '<tr><th>SystemName')
$Temp3 = $TEMP3 -REPLACE '<colgroup>', ("`t" + '<colgroup>')
# Add title
$Temp3 = $TEMP3 -REPLACE 'HTML TABLE',"$Title"

$Temp3 = $TEMP3 -REPLACE '<td>Manual</td><td>True</td>','<td id="manual">Manual</td><td id="manual">True</td>'
# Add navigation bar to bottom
$Temp3 = $TEMP3 -REPLACE '</body>',("`t" + '</body>' + "`r`n`t" + '<footer>' +  $Nav + '</footer>' + "`r`n`t`t")
# Add bottom of file anchor
$Temp3 = $TEMP3 -REPLACE '</footer>', ( "`r`n`t" + '</footer>' + "`r`n`t" + '<a name="bottomoffile"></a>' )
# Add date stamp to botom of file
$Temp3 = $TEMP3 -REPLACE '<a name="bottomoffile"></a>', ('<a name="bottomoffile" id="bottompadding"></a>' + ("`r`n`t" + $date )  )


#>

# export HTML data to html file
$Fragments | Out-File $HTMLFile

# Open HTML in editor
C:\Tools\Notepad++\notepad++.exe $HTMLFile



