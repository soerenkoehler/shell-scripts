#!/bin/sh

#
# location of update-executor.sh - here it is assumed that the scripts reside in /opt/usrbin/
#
# Since it will run via sudo, you have to edit your sudoers file and include something like:
#
# <yourname> ALL=NOPASSWD: <file-path-to-update-executor.sh>
# Defaults!<file-path-to-update-executor.sh> !requiretty
#
UPDATE_EXECUTOR=/opt/usrbin/update-executor.sh

logger -t update-check "Start."

#
# set up working directory
#
mkdir -p ~/.update-check
cd ~/.update-check

#
# google says this is needed sometimes for kdialog
#
export $(dbus-launch)

#
# retrieve updates, filter packages (e.g. lines with dots), count lines
#
UPDATES=`dnf --refresh -q check-update | grep "." | wc -l`
logger -t update-check "Found $UPDATES update(s)."

#
# when updates are available: show dialog
# when "yes" is selected: run update-executor as root to install updates
#
if [ $UPDATES -gt 0 ]; then
	kdialog --yesno "$UPDATES new update(s) available. Install now?"
	if [ $? -eq 0 ]; then
		logger -t update-check "Installing $UPDATES update(s)."
		sudo $UPDATE_EXECUTOR
		kdialog --msgbox "$UPDATES new update(s) installed."
	else
		logger -t update-check "Do nothing."
	fi
fi

logger -t update-check "End."