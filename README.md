# Automatically Disabling Inactive User Accounts in Active Directory

I present a script in the Windows PowerShell scripting language that will allow you to disable user accounts that have been inactive for a certain number of days and add a description with the date when the disconnect was performed.
Disabled user accounts will be transferred to the appropriate organizational unit, and a log file will be created with a list of disabled user accounts.

You need to open the script in a text editor or Windows PowerShell ISE and change several values so that the script runs correctly in your organization.

- In the variable “LogFolder”, you must specify the path to the folder where the log files will be created. These files will contain a list of disabled user accounts.
- In the “OU” variable, you must specify the path to the organizational unit where your organization's user accounts are stored.
- In the “InactiveUserOU” variable, you must specify the path to the organizational unit where disabled user accounts in your organization will be transferred.
- In the variable “UnusedDays”, specify the days after inactive user accounts are disabled.

Automate script execution through the task scheduler. To do this, you need to create a service account under which the task will be launched and also delegate to this account the necessary permissions to the organizational unit where user accounts are stored.

# Author

I’m Vladimir Mikhalev, the [Docker Captain](https://www.docker.com/captains/vladimir-mikhalev/), but my friends can call me Valdemar.

🌐 My [website](https://www.heyvaldemar.com/) with detailed IT guides\
🎬 Follow me on [YouTube](https://www.youtube.com/channel/UCf85kQ0u1sYTTTyKVpxrlyQ?sub_confirmation=1)\
🐦 Follow me on [Twitter](https://twitter.com/heyValdemar)\
🎨 Follow me on [Instagram](https://www.instagram.com/heyvaldemar/)\
🧵 Follow me on [Threads](https://www.threads.net/@heyvaldemar)\
🐘 Follow me on [Mastodon](https://mastodon.social/@heyvaldemar)\
🧊 Follow me on [Bluesky](https://bsky.app/profile/heyvaldemar.bsky.social)\
🎸 Follow me on [Facebook](https://www.facebook.com/heyValdemarFB/)\
🎥 Follow me on [TikTok](https://www.tiktok.com/@heyvaldemar)\
💻 Follow me on [LinkedIn](https://www.linkedin.com/in/heyvaldemar/)\
🐈 Follow me on [GitHub](https://github.com/heyvaldemar)

# Communication

👾 Chat with IT pros on [Discord](https://discord.gg/AJQGCCBcqf)\
📧 Reach me at ask@sre.gg

# Give Thanks

💎 Support on [GitHub](https://github.com/sponsors/heyValdemar)\
🏆 Support on [Patreon](https://www.patreon.com/heyValdemar)\
🥤 Support on [BuyMeaCoffee](https://www.buymeacoffee.com/heyValdemar)\
🍪 Support on [Ko-fi](https://ko-fi.com/heyValdemar)\
💖 Support on [PayPal](https://www.paypal.com/paypalme/heyValdemarCOM)
