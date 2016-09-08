# crash-span
Would you like to easily connect your OS X system to your headless CrashPlan servers?
This script is for you!

**NOTE**: For Windows; head over to [win-crashplan-uiswitcher](https://github.com/Hossy/win-crashplan-uiswitcher)

# Usage
```sh
crash-span.sh <your-headless-host>
```

It will fail the first time you run it, because you need a `ui_info`
file. To generate this file:
* Grab the information from `.ui_info` as described in [step 1 of the Crashplan headless documentation](https://support.code42.com/CrashPlan/4/Configuring/Using_CrashPlan_On_A_Headless_Computer).
* crash-span told you it needs you to create a file. Create that file
	now.
* Within this file, add the contents of `.ui_info` from
	your-headless-host.

# Background
Crashplan is a great tool for backing up your stuff. I don't work for
them, but I like their backup software!

That said, they state in big bold letters that they don't support
headless configurations. They do offer instructions for connecting to
headless CrashPlan servers. However these instructions are annoying to
run through manually. Thus this script was born!

Ideally, CrashPlan will start supporting headless better. Then this
script will become obsolete! You can encourage them to do so by
up-voting feature requests:
* [My ssh X11 feature request](https://helpdesk.code42.com/requests/742561)
* [All "headless" feature requests](https://helpdesk.code42.com/forums/24327-Feature-Requests/entries/search?utf8=✓&query=headless&for_search=1&commit=Search)

# Support
Enter a Github issue, or better yet a pull request!
