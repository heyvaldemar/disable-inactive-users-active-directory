# Log file location (replace with yours)
$LogFolder = "C:\Scripts\Disable-Inactive-Users\Log\"
$LogFile = $LogFolder + "Disable-Inactive-Users"

# Domain or organizational unit to search in (replace with yours)
$OU = "OU=Users,DC=heyvaldemar,DC=net"

# OU for inactive users (replace with yours)
$InactiveUserOU = "OU=Disabled,OU=Users,DC=heyvaldemar,DC=net"

# Number of days a user has not logged on (replace with yours)
$UnusedDays = 90

# Get current date in a sortable format
$CurrentDate = Get-Date -format yyyy_MM_dd
$CurrentTime = Get-Date -format HH_MM_ss

# Get the current date minus UnusedDays
$DateLastActive = (Get-Date) - (new-timespan -days $UnusedDays)

# Convert current date to timestamp
$DateLastActiveTimeStamp = (Get-Date $DateLastActive).ToFileTime()

# Add current date to log file name
$LogFile = $LogFile + "_Date_" + $CurrentDate + "_Time_" + $CurrentTime + ".csv"

# Never used date
$NeverUsed = (01/01/1601)

# Get users and set variable
$ADUsersForWork = Get-ADUser -Filter { (((lastLogonTimestamp -lt $DateLastActiveTimeStamp) -or (-not (lastLogonTimestamp -like "*"))) -and (whenCreated -lt $DateLastActive)) } -SearchBase "$OU" -Prop DisplayName,DistinguishedName,whenCreated,lastLogonTimestamp,lastLogonTimestamp,Description

# Get users and output to the log file
echo $ADUsersForWork | Select DisplayName,DistinguishedName,whenCreated,lastLogonTimestamp,Description,@{n="lastLogonDate";e={[datetime]::FromFileTime($_.lastLogonTimestamp)}} | Out-File $LogFile

ForEach($usr In $ADUsersForWork) {
    # Disable inactive users
    dsmod user $usr.DistinguishedName -disabled yes

    # Add a new description to the disabled users
    $new_desc = "Account Disabled Date: " + $CurrentDate
    Set-ADUser $usr.DistinguishedName -Description $new_desc

    # Move disabled users to the new OU
    Move-ADObject -Identity $usr.DistinguishedName -TargetPath $InactiveUserOU
}
