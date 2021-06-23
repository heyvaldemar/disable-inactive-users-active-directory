# Automatically Disabling Inactive User Accounts in Active Directory

I present to you a script in the Windows PowerShell scripting language that will allow you to not only disable user accounts that are inactive for a certain number of days but also add a description to them with the date when the disconnect was performed. In addition, disabled user accounts will be transferred to the appropriate organizational unit, and a log file will be created with a list of disabled user accounts.

You need to open the script in a text editor or in Windows PowerShell ISE and change several values so that the script runs correctly in your organization.

* In the variable “LogFolder” you must specify the path to the folder where the log files will be created with a list of disabled user accounts.
* In the “OU” variable, you must specify the path to the organizational unit where the user accounts in your organization are stored.
* In the “InactiveUserOU” variable, you must specify the path to the organizational unit where disabled user accounts in your organization will be transferred.
* In the variable “UnusedDays” you must specify the number of days after which inactive user accounts will be disabled.

Automate script execution through the task scheduler. To do this, you need to create a service account under which the task will be launched, and also delegate to this account the necessary permissions to the organizational unit where user accounts are stored.
