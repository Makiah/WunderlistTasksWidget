#! /bin/bash

# Required for OAuth2.  
CLIENT_ID="3badb48a0395375f93e0"
SERVER_ENDPOINT="http://127.0.0.1:4000/authorization_code_callback"
ACCESS_TOKEN=""

echo "Testing"

# Start the OAuth2 server if not already up.  
TOKEN_STATUS="$(curl --silent http://127.0.0.1:4000/pls-can-i-has-access-token)"

if [ "$TOKEN_STATUS" = "nope!" ] || [ "$TOKEN_STATUS" = "" ] # Server not started.  
then
	# Ensure server is started.  
	if [ "$TOKEN_STATUS" = "" ]
	then
		/usr/local/Cellar/node/8.9.0/bin/node "/Users/makiah/Library/Application Support/Übersicht/widgets/WunderlistTasksWidget/lib/oauthserver/server.js" & # This & tells the script to do it asynchronously.  
		sleep 2
	fi

	# Ask the user to allow this app to see their tasks.  
	echo "Requesting access..."
	WUNDERLIST_CODE_QUERY="https://www.wunderlist.com/oauth/authorize?client_id=$CLIENT_ID&redirect_uri=$SERVER_ENDPOINT&state=RANDOM"
	/usr/bin/open -a "/Applications/Safari.app" $WUNDERLIST_CODE_QUERY

	# Wait until the access token has been obtained.  
	while [ "$TOKEN_STATUS" == "nope!" ] || [ "$TOKEN_STATUS" == "" ]; do
		TOKEN_STATUS=$(curl --silent http://127.0.0.1:4000/pls-can-i-has-access-token)
	    sleep 3
	done
fi

# We've got the access token!  NOICE.  
ACCESS_TOKEN="$TOKEN_STATUS"

# Tell the other lib to use the SDK and print everything out!  
/usr/local/Cellar/node/8.9.0/bin/node "/Users/makiah/Library/Application Support/Übersicht/widgets/WunderlistTasksWidget/lib/datadisplay/datadisplayer.js" $CLIENT_ID $ACCESS_TOKEN