# Description: Setting up an incident respone toolkit
# Needed are theses 6 tasks 
#1. Running Processes and the path for each process.
#2. All registered services and the path to the executable controlling the service (you'll need to use WMI).
#3. All TCP network sockets
#4. All user account information (you'll need to use WMI)
#5. All NetworkAdapterConfiguration information.
#6. Use Powershell cmdlets to save 4 other artifacts that would be useful 
#
# Other needs 
#
#+ Create a prompt that asks the user for the location of where to save the results for the commands above.
#
#+ Select a way to use at least one function within your code.
#
#+ Find the Powershell cmdlet that can create a 'FileHash' of the resulting CSV files, create a checksum for
#  each one, and save the results to a file within the results directory.  The file containing checksums should
#  have the filename and the corresponding checksum.


function export_hash (){

 Param([string]$result_file,[string]$cmd_output)
 
$p | Export-Csv -Path "C:\Users\$env:UserName\$location\$result_file" -NoTypeInformation 

Get-FileHash "C:\Users\$env:UserName\$location\$result_file"| Add-Content "C:\Users\$env:UserName\$location\hashes.txt"
}


#1. Getting the running processes.
function running_processes (){


$p = Get-Process | Select-Object ProcessName, Path, ID 
export_hash -result_file "myprocesses.csv"

}

#2. Getting all registarted services and the path to the executable controlling the service
function get_services (){

$p = Get-WmiObject win32_service | select Name, DisplayName, @{Name="Path"; Expression={PathFromServicePathName $_.PathName}} | Format-List 
export_hash -result_file "Myservices.csv" 
}

#3. All TCP network sockets
function TCP_sockets (){

$p = Get-NetTCPConnection | select-object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess 
export_hash -result_file "TCP_sockets.csv"

}

#4. All user account information (you'll need to use WMI)
function user_acc (){

$p = Get-WmiObject -Class Win32_Account | Get-Member 

export_hash -result_file "All_Users_Info.csv"

}


#5. All NetworkAdapterConfiguration information.
function network_adapters (){

$p = Get-WmiObject -Class Win32_NetworkAdapterConfiguration 

export_hash -result_file "Networkadapters.csv"


}


#6. Use Powershell cmdlets to save 4 other artifacts that would be useful
#   a. The extra cmdlets will be getting all users
#   b. grabbing the 40 newest logs
#   c. Checking cmd history 
#   d. Check update history
function additional_reqs (){

#a. The extra cmdlets will be getting all users

$p = Get-WMIObject -class Win32_ComputerSystem | select username 
export_hash -result_file "Logged_in_Users.csv"

#b. grabbing the 40 newest system logs

$p = Get-EventLog -LogName System -Newest 40 

export_hash -result_file "40 Newest logs.csv"

#c. Checking cmd history 
   
$p = Get-History | select Id, CommandLine, ExecutionStatus, StartExecutionTime, EndExecutionTime 


export_hash -result_file "CMD_line_history.csv"

#d. Checking updates 

$p = get-wmiobject -class win32_quickfixengineering 

export_hash -result_file "Updates.csv"
}

# Function to call all other functions as well as ask where files should be saved


function tool_kit (){

# asking for file location 
$filelocation = Read-Host -Prompt "please enter where you would like this data save to." 

$location = "$filelocation"

#creating the file under a user
New-Item -Path "C:\Users\$env:UserName\$location" -ItemType Directory




running_processes

get_services 

TCP_sockets

user_acc

network_adapters

additional_reqs


#Compressing the results file
Compress-Archive -LiteralPath "C:\Users\$env:UserName\$location" -DestinationPath "C:\Users\$env:UserName\Desktop\results.zip"

# Get a hash of the resulting zip file
Get-FileHash "C:\Users\$env:UserName\Desktop\results.zip" | Add-Content "C:\Users\$env:UserName\Desktop\ZipResults_checksum.txt"



#Sending the results to 192.168.4.50


Set-SCPFile -ComputerName '192.168.4.50' -Credential (Get-Credential connor.merchant@cyber.local) `
-RemotePath '/home/connor.merchant@cyber.local' -LocalFile "C:\Users\$env:UserName\Desktop\results.zip"

#Starting an SHH session  and then checking if the results are there.

New-SSHSession -ComputerName '192.168.4.50' -Credential (Get-Credential connor.merchant@cyber.local)
Invoke-SSHCommand -index 0 'ls -l'


}

tool_kit 