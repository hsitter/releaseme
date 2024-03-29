# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2015-2021 Jonathan Riddell <jr@jriddell.org>
# SPDX-FileCopyrightText: 2016 David Edmundson <kde@davidedmundson.co.uk>
# SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>

LANG=en_GB.UTF-8
LANGUAGE=en
LC_ALL=en_GB.UTF-8

MAJOR_VERSION=5
VERSION=5.24.7
SHORT_VERSION=5.24
OLD_VERSION=5.24.6
ORIGIN=lts  # git branch as set in projects.k.o, set to trunk or stable or lts
FTPSTABLE=stable  # set to unstable or stable
OLD_FTPSTABLE=stable  # set to unstable or stable of previous release
BRANCH=Plasma/5.24 # set to master or Plasma/5.x

RELEASETYPE=Bugfix # for changelog, set to beta, feature or bugfix

INFOCHECKOUT="/home/jr/src/websites/kde-org/content/info"                   # git@invent.kde.org:websites/kde-org.git
ANNOUNCECHECKOUT="/home/jr/src/websites/kde-org/content/announcements"  # git@invent.kde.org:websites/kde-org.git
L10NSCRIPTSCHECKOUT="/home/jr/src/sysadmin/l10n-scripty"    # git clone git@invent.kde.org:sysadmin/l10n-scripty.git
WWWCHECKOUT="/home/jr/src/websites/kde-org"                     # git@invent.kde.org:websites/kde-org.git
UPLOADSERVER="ftpadmin@deino.kde.org"
#UPLOADSERVER="weegie"

RELEASEDATE="Friday, 14 October 2022" # usually  `LC_ALL=C date "+%A, %d %B %Y" --date="next Tue"`
RELEASEDATEISO="2022-10-14" # usually  `LC_ALL=C date "+%Y-%m-%d" --date="next Tue"`

SCRATCH_SERVER=embra:tmp/ # somewhere to scp QA and tag files to
SCRATCH_SERVER_URL=http://embra.edinburghlinux.co.uk/~jr/tmp # URL to view this

VIDEO_KEY="youtube" # type of video: "youtube", "peertube", "video"
VIDEO_VALUE="ahEWG4JCA1w" # The video ID used in URL for "youtube" and "peertube", and "true" for "video"

# command from   git clone invent:sysadmin/appstream-metainfo-release-update
APPSTREAM_UPDATER="/home/jr/src/sysadmin/appstream-metainfo-release-update/appstream-metainfo-release-update"

GPG_KEY=D7574483BB57B18D
RELEASE_DUDE="Jonathan Esk-Riddell"

BROWSER=firefox  # chromium, firefox etc
