#! /bin/bash

cd ~/Library/Application\ Support/Übersicht/widgets/WunderlistTasksWidget

if [ -e "WunderlistTasksWidget.zip" ]; then
	rm WunderlistTasksWidget.zip
fi

mkdir tozip

# Yeah this is gross but necessary
find . -maxdepth 1 -mindepth 1 -not -name tozip -not -name .git -not -name .gitignore -not -name accesstoken.txt -not -name doc -not -name testlog.txt -not -name autozip.sh -exec cp -rf '{}' tozip \;

# zip directory
zip -r WunderlistTasksWidget.zip tozip

# Remove zip workspace
rm -rf tozip