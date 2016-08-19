
$Computername = 'mn-Credit08'
$Computername = $env:COMPUTERNAME

# cleanup PS environment
Remove-Item $HTMLFile -ea 0 
Remove-Variable Temp,temp2,temp2 -ea 0 

# Set some variables
$StyleSheet = 'C:\Users\T910411\Desktop\Temp\HTML\main.css'
#$StyleSheet = 'main.css'
$date = (Get-Date | Out-String).trim()
$HTMLFile = 'C:\Users\T910411\Desktop\Temp\HTML\Testing.html'
$Title = 'CSS TESTING'
$Header = 'My CSS Testing'
 
 # Navigation bar content
 $NAVBar = @"
      <a href="index.html">Home</a>
      <a href=#topoffile>Top</A>
      <a href=#bottomoffile>bottom</A>
      <a href="https://www.microsoft.com">Microsoft</a>
"@
$Nav =''
# used to add navigation bar
$Nav = ("`r`n`t" + '<nav id="nav">' + "`r`n" + $NAVBar +  "`r`n`t" + '</nav>'  )

# create dynamic variable (used to execute code) (future possibly multiple different datasets)
$info = New-Object -TypeName psobject
$info | Add-Member -Name Services -MemberType ScriptProperty -Value {gwmi win32_SERVICE -ComputerName $Computername}
$info | Add-Member -Name HotFixs -MemberType ScriptProperty -Value {Get-HotFix -ComputerName $Computername}
$info | Add-Member -Name ComputerInfo -MemberType ScriptProperty -Value {gwmi Win32_ComputerSystem -ComputerName $Computername}


#$Temp = gwmi win32_service
$Temp = $info.Services
$Temp2 = $Temp | sort Startmode,Started |Select SystemName,Name,StartMode,Started,State,DisplayName,Description,AcceptPause,AcceptStop
$Temp3 = $temp2 | ConvertTo-Html


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
#> 


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
# Add title
$Temp3 = $TEMP3 -REPLACE 'HTML TABLE',"$Title"
# Add some ID's to colorize (warnings, disabled, etc)
$Temp3 = $TEMP3 -REPLACE '<td></td>','<td id="blank"></td>'
$Temp3 = $TEMP3 -REPLACE '<td>Auto</td><td>False</td>','<td>Auto</td><td id="warning">False</td>'
$Temp3 = $TEMP3 -REPLACE '<td>Disabled</td>','<td id="Disabled">Disabled</td>'
$Temp3 = $TEMP3 -REPLACE '<td>Manual</td>','<td id="manual">Manual</td>'
$Temp3 = $TEMP3 -REPLACE '<td>Manual</td><td>True</td>','<td id="manual">Manual</td><td id="manual">True</td>'
# Add navigation bar to bottom
$Temp3 = $TEMP3 -REPLACE '</body>',("`t" + '</body>' + "`r`n`t" + '<footer>' +  $Nav + '</footer>' + "`r`n`t`t")
# Add bottom of file anchor
$Temp3 = $TEMP3 -REPLACE '</footer>', ( "`r`n`t" + '</footer>' + "`r`n`t" + '<a name="bottomoffile"></a>' )
# Add date stamp to botom of file
$Temp3 = $TEMP3 -REPLACE '<a name="bottomoffile"></a>', ('<a name="bottomoffile" id="bottompadding"></a>' + ("`r`n`t" + $date )  )


# export HTML data to html file
$temp3 | Out-File $HTMLFile

# Open HTML in editor
C:\Tools\Notepad++\notepad++.exe $HTMLFile


