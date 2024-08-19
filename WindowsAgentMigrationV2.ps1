<#

This script is not mine, it is just an update based on the original script made available by qualys
via the link https://success.qualys.com/support/s/article/000007448.

Change lines 45, 46 and 46 by your Activation ID, Customer ID and URI

If you need to use a network path because your asset is not allowed to be downloaded via the internet,
change lines 193 and 199 to your network path. If not, you don't need to change anything.

In the "function QualysFolderAccess" function on line 235 I fixed the way the script handles the Qualys folder,
this seems to bypass the requirement that the agent needs to have self-protection disabled and also allows us to create/edit
the Config.DB and the log inside the Qualys folder. 
You can create a new function to return the folder's original properties after the task is executed.

Remove this initial comment (line 1 to 19) before placing the script in the CAR module (if you are using it). 
For some reason it is not possible to move forward with this comment.

#>
$RehomeScript = @'
function DBUpdate 
{ 	
    $QService = Get-Service -Name QualysAgent
		
		if($QService.Status -eq 'Running')
		{

			WriteToLog -LogText " [Action]	Terminating Qualys Agent process"
			
			try
			{
			#$null = Taskkill /IM "QualysAgent.exe" /F
			$null = cmd.exe /c sc stop QualysAgent
			}
           catch
		    {
			Write-Warning "Failed to kill qualys service"
		    }			
                
		}
	$null = Start-Sleep -Seconds 30	
           
	WriteToLog -LogText " [Action]	Fetching WEB_SERVICE URL from Database "
    $WEB_SERVICE_URL =cmd.exe /c "C:\Windows\Temp\sqlite3.exe"  "C:\ProgramData\Qualys\QualysAgent\config.db" "select [Value] from Settings where [Group] = 'WEB_SERVICE' and [Item] = 'URL';"
    WriteToLog -LogText "`n [Validation]	WEB_SERVICE_URL from Database is : $WEB_SERVICE_URL "

    WriteToLog -LogText " [Action]	Fetching ACTIVATIONID from Database "
    $ACTIVATIONID=cmd.exe /c "C:\Windows\Temp\sqlite3.exe"  "C:\ProgramData\Qualys\QualysAgent\config.db" "select [Value] from Settings where [Group] = 'AGENT' and [Item] = 'ACTIVATION';"
    WriteToLog -LogText "`n [Validation]	ACTIVATIONID from Database is : $ACTIVATIONID "
	
	WriteToLog -LogText " [Action]	Fetching CUSTOMERID from Database "
    $CUSTOMERID=cmd.exe /c "C:\Windows\Temp\sqlite3.exe"  "C:\ProgramData\Qualys\QualysAgent\config.db" "select [Value] from Settings where [Group] = 'AGENT' and [Item] = 'CUSTOMER';"
    WriteToLog -LogText "`n [Validation]	CUSTOMERID from Database is : $CUSTOMERID "
	
	WriteToLog -LogText " [Action]	Fetching provisioning status from Database "
    $Provision=cmd.exe /c "C:\Windows\Temp\sqlite3.exe"  "C:\ProgramData\Qualys\QualysAgent\config.db" "select [Value] from Settings where [Group] = 'AGENT' and [Item] = 'NOT_PROVISIONED';"
    WriteToLog -LogText "`n [Validation]	provisioning status from Database is : $Provision "
    


cmd.exe /c "C:\Windows\Temp\sqlite3.exe" "C:\ProgramData\Qualys\QualysAgent\Config.db" "update Settings SET [Value] = 'https://URL/CloudAgent/' where [Group] = 'WEB_SERVICE' and [Item] = 'URL';"
cmd.exe /c "C:\Windows\Temp\sqlite3.exe" "C:\ProgramData\Qualys\QualysAgent\Config.db" "update Settings SET [Value] = '{xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}' where [Group] = 'AGENT' and [Item] = 'ACTIVATION';"	
cmd.exe /c "C:\Windows\Temp\sqlite3.exe" "C:\ProgramData\Qualys\QualysAgent\Config.db" "update Settings SET [Value] = '{xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}' where [Group] = 'AGENT' and [Item] = 'CUSTOMER';"	
cmd.exe /c "C:\Windows\Temp\sqlite3.exe" "C:\ProgramData\Qualys\QualysAgent\Config.db" "update Settings SET [Value] = '1' where [Group] = 'AGENT' and [Item] = 'NOT_PROVISIONED';"	

    WriteToLog -LogText " New DB values after the update "
	
    WriteToLog -LogText " [Action]	Fetching WEB_SERVICE URL from Database "
    $WEB_SERVICE_URL =cmd.exe /c "C:\Windows\Temp\sqlite3.exe"  "C:\ProgramData\Qualys\QualysAgent\config.db" "select [Value] from Settings where [Group] = 'WEB_SERVICE' and [Item] = 'URL';"
    WriteToLog -LogText "`n [Validation]	WEB_SERVICE URL from Database is : $WEB_SERVICE_URL "

    WriteToLog -LogText " [Action]	Fetching ACTIVATIONID from Database "
    $ACTIVATIONID=cmd.exe /c "C:\Windows\Temp\sqlite3.exe"  "C:\ProgramData\Qualys\QualysAgent\config.db" "select [Value] from Settings where [Group] = 'AGENT' and [Item] = 'ACTIVATION';"
    WriteToLog -LogText "`n [Validation]	ACTIVATIONID from Database is : $ACTIVATIONID "
	
	WriteToLog -LogText " [Action]	Fetching CUSTOMERID from Database "
    $CUSTOMERID=cmd.exe /c "C:\Windows\Temp\sqlite3.exe"  "C:\ProgramData\Qualys\QualysAgent\config.db" "select [Value] from Settings where [Group] = 'AGENT' and [Item] = 'CUSTOMER';"
    WriteToLog -LogText "`n[Validation]	CUSTOMERID from Database is : $CUSTOMERID "
	
	WriteToLog -LogText " [Action]	Fetching provisioning status from Database "
    $Provision=cmd.exe /c "C:\Windows\Temp\sqlite3.exe"  "C:\ProgramData\Qualys\QualysAgent\config.db" "select [Value] from Settings where [Group] = 'AGENT' and [Item] = 'NOT_PROVISIONED';"
    WriteToLog -LogText "`n[Validation]	provisioning status from Database is : $Provision "
		
	WriteToLog -LogText " [Action]	Starting Qualys Windows Cloud Agent Service ."  
   
	Start-Service -Name "QualysAgent"
	$null = Start-Sleep -Seconds 30

}

Function removefiles
{
	$sqltool_file_path = "C:\Windows\Temp\sqlite-tools.zip"

	#Test-Path cmdlet to check if the sqltool.zip file exists
	if (-not (Test-Path -Path $sqltool_file_path -PathType Leaf)) 
	{
	WriteToLog -LogText "`nThe file $sqltool_file_path does not exist."
	}
	else
	{
	WriteToLog -LogText "`nThe file $sqltool_file_path exist so removing the file"
	remove-item "C:\Windows\Temp\sqlite-tools.zip"
	}


	$sqlite3_file_path = "C:\Windows\Temp\sqlite3.exe"

	#Test-Path cmdlet to check if the sqlite extracted file exists
	if (-not (Test-Path -Path $sqlite3_file_path -PathType Leaf)) 
	{
	WriteToLog -LogText "`nThe file $sqlite3_file_path does not exist."
	}
	else
	{
	WriteToLog -LogText "`nThe file $sqlite3_file_path exist so removing the file"
	remove-item "C:\Windows\Temp\sqlite3.exe"
	}

	$sqldiff_file_path = "C:\Windows\Temp\sqldiff.exe"

	#Test-Path cmdlet to check if the sqlite extracted file exists
	if (-not (Test-Path -Path $sqldiff_file_path -PathType Leaf)) 
	{
	WriteToLog -LogText "`nThe file $sqldiff_file_path does not exist."				
	}
	else
	{
	WriteToLog -LogText "`nThe file $sqldiff_file_path exist so removing the file"
	remove-item "C:\Windows\Temp\sqldiff.exe"
	remove-item "C:\Windows\Temp\sqlite3_analyzer.exe"
    }
}	
	
# Defining a Log writing function
function WriteToLog 
{
	param ([string]$LogText)
	Add-Content -Path $Logfile_Path -Value "$LogText" -Encoding Unicode
}
	
	
# Create log file
$rehomelog= "C:\ProgramData\Qualys\QualysAgent\Rehomelog.txt"
$Logfile_Path = "C:\ProgramData\Qualys\QualysAgent\Rehomelog.txt"

	#Test-Path cmdlet to check if the rehome log file exists
	if (-not (Test-Path -Path $rehomelog -PathType Leaf)) 
	{
	  $log_path = New-Item -ItemType File -Path "C:\ProgramData\Qualys\QualysAgent" -Name "Rehomelog.txt"		
	}
    else
    {	
	WriteToLog -LogText "`nThe file $rehomelog exist."	
	}	

DBUpdate

# remove the Sqltool.zip and the extraced files
WriteToLog -LogText "[Action] removing downloaded and extracted files"
removefiles


#set proxy if required by uncommenting the below line and updating the proxy as per your enviornment
#WriteToLog -LogText "[Action] setting proxy using proxy tool"
#$null = cmd.exe /c "C:\Program Files\Qualys\QualysAgent\QualysProxy.exe" /u http://10.10.10.10:8080

If ( Get-ScheduledTask -TaskName "Rehome Qualys Agent")
{
WriteToLog -LogText "[Action] scheduled task exist unregistering the same"
Unregister-ScheduledTask 'Rehome Qualys Agent' -Confirm:$false
}
else
{
WriteToLog -LogText "scheduled task does not exist"
}

Add-Content -Path $Logfile_Path -Value "`n`n$(Get-Date) ---------------------- Qualys Windows Cloud Agent - Rehome Script - END  ---------------------- `n"  -Encoding Unicode

WriteToLog -LogText "[Action] deleting rehome script"
Remove-Item -Path "C:\Windows\Temp\Rehome.ps1" -Force

'@


# Defining a Log writing function
function WriteToLog 
{
	param ([string]$LogText)
	Add-Content -Path $Logfile_Path -Value "$LogText" -Encoding Unicode
}


function copyFiles 
{
    WriteToLog -LogText " [Action] Copying sqlite tool."

    $sqlite_file_path = "C:\Windows\Temp\sqlite-tools.zip"
    $dest = "C:\Windows\Temp\sqlite-tools.zip"
	
    # Test-Path cmdlet to check if the sqlite file exists
    if (-not (Test-Path -Path $sqlite_file_path -PathType Leaf)) 
    {
        try
        {
            # First network path
            if (-not (Test-Path -Path $dest -PathType Leaf)) {
                Copy-Item "\\XXXXXXX\f$\sqlite-tools-win-x64-3450200.zip" -Destination $dest
                WriteToLog -LogText " [Action] Downloaded sqlite tool from XXXXXXXX"
            }

            # Second network path if the first one fail
            if (-not (Test-Path -Path $dest -PathType Leaf)) {
                Copy-Item "\\XXXXXXX\f$\sqlite-tools-win-x64-3450200.zip" -Destination $dest
                WriteToLog -LogText " [Action] Downloaded sqlite tool from XXXXXXXX"
            }

            # Download via URL if both fail
            if (-not (Test-Path -Path $dest -PathType Leaf)) {
                Invoke-WebRequest -Uri "https://www.sqlite.org/2024/sqlite-tools-win-x64-3450200.zip" -UseBasicParsing -OutFile $dest -TimeoutSec 180
                WriteToLog -LogText " [Action] Downloaded sqlite tool from URL"
            }

            $null = Start-Sleep -Seconds 10
            WriteToLog -LogText " [Action] Extracting zip file"
            Expand-Archive $dest -DestinationPath "C:\Windows\Temp\" -Force
            $null = Start-Sleep -Seconds 10
        }
        catch
        {
            Write-Warning "Failed to download sqlite files"
            WriteToLog -LogText "Failed to download sqlite files so further processing of script is stopped"
            exit
        }
    }
    else
    {
        WriteToLog -LogText "`nThe file $sqlite_file_path exist."
        WriteToLog -LogText " [Action] Extracting zip file"
        Expand-Archive $sqlite_file_path -DestinationPath "C:\Windows\Temp\" -Force
        $null = Start-Sleep -Seconds 10
    }
}
	
function QualysFolderAccess 
{
    takeown /F "C:\ProgramData\Qualys" /A /R /D Y
    icacls "C:\ProgramData\Qualys" /grant "Administrators:(OI)(CI)(F)" /T /C
    icacls "C:\ProgramData\Qualys" /grant "Users:(OI)(CI)(F)" /T /C
    icacls "C:\ProgramData\Qualys\*" /setowner "Administrators" /T /C /L
    icacls "C:\ProgramData\Qualys" /grant "Administrators:F" /T /C
}

#Check to see if Temp folder exists, if not create it
$path = 'C:\Windows\Temp'
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
QualysFolderAccess


# Create log file
$rehomelog= "C:\ProgramData\Qualys\QualysAgent\Rehomelog.txt"
$Logfile_Path = "C:\ProgramData\Qualys\QualysAgent\Rehomelog.txt"

Add-Content -Path $Logfile_Path -Value "`n`n$(Get-Date) ---------------------- Qualys Windows Cloud Agent - Rehome Script - START ---------------------- `n"  -Encoding Unicode


	#Test-Path cmdlet to check if the rehome log file exists
	if (-not (Test-Path -Path $rehomelog -PathType Leaf)) 
	{
	  $log_path = New-Item -ItemType File -Path "C:\ProgramData\Qualys\QualysAgent" -Name "Rehomelog.txt"		
	}
    else
    {	
	WriteToLog -LogText "`n [Validation] The file $rehomelog exist."	
	}	
	
	
	
copyFiles

Set-Content C:\Windows\Temp\Rehome.ps1 $RehomeScript

# Checking for Qualys Cloud Agent Service and QualysAgent.exe file presence to decide if to run Script further or Exit.
WriteToLog -LogText " [Validation]	Checking if Qualys Windows Cloud Agent Service is installed and running."

    $Service_Exists = Get-Service -Name QualysAgent -ErrorAction SilentlyContinue
    if ($Service_Exists.Name -eq "QualysAgent") 
	{
         WriteToLog -LogText "[Validation]	Qualys Agent Service found "
         if (Test-Path -Path "C:\Program Files\Qualys\QualysAgent\QualysAgent.exe" -ErrorAction SilentlyContinue) 
		 {
            WriteToLog -LogText "[Validation]	Qualys Agent Binary found at : C:\Program Files\Qualys\QualysAgent\QualysAgent.exe " 
            #Create Scheduled Task
			WriteToLog -LogText "[Action] creating task"
			$scriptpath="C:\Windows\Temp\Rehome.ps1"
		$action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File $scriptpath"
			WriteToLog -LogText "[Action] registering task"
			$null=Register-ScheduledTask -Action $action  -TaskName 'Rehome Qualys Agent' -Description 'This will rehome Qualys Cloud Agent to the new POD' -User 'NT AUTHORITY\SYSTEM'

			$null = Start-Sleep -Seconds 10
			WriteToLog -LogText "[Action] starting task"
			#Start Scheduled Task
			$null=Start-ScheduledTask -TaskName 'Rehome Qualys Agent'

         }
        else 
		{
            WriteToLog -LogText "[Validation]	System's state is inconsistent. Please contact Qualys Support Team as Windows Cloud Agent Service exists and binary is missing"
            WriteToLog -LogText "[Action]	Script is exiting without further actions."
            WriteToLog -LogText "[End]	Qualys Windows Cloud Agent - Rehome Script exited without doing any modification to Current System's state"
            Write-host "Failed"
            Exit
        }
    }
    else  
	{
		WriteToLog -LogText " [Validation]	Qualys Cloud Agent Service is not installed"
		WriteToLog -LogText "[Action]	Script is exiting without further actions as Agent is not installed."
		WriteToLog -LogText "[End]	Qualys Windows Cloud Agent - Rehome Script exited without doing any modification to Current System's state"
		Write-host "Failed"
		Exit
    }
