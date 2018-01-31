#! /bin/bash

# Determine whether node is installed first (doesn't work currently)
# function program_is_installed {
#   # set to 1 initially
#   local return_=1
#   # set to 0 if not found
#   type $1 >/dev/null 2>&1 || { local return_=0; }
#   # return value
#   echo "$return_"
# }

# if [ $(program_is_installed node) = 1 ]; then 
# 	echo "Yes"
# else
# 	echo "No"
# fi

# Check whether online (don't do anything otherwise)...
if ping -c 1 google.com >> /dev/null 2>&1; then
    echo "online"
else
    echo "OFFLINE"
    exit 0
fi

# Required for OAuth2.  
CLIENT_ID="3badb48a0395375f93e0"
SERVER_ENDPOINT="http://127.0.0.1:4000/authorization_code_callback"
ACCESS_TOKEN=""

# Apparently we start in the widgets directory.  
cd WunderlistTasksWidget

# Starts the OAuth server I made and requests the token from the Wunderlist server.  
function requestToken()
{
	# Start the OAuth2 server if not already up.  
	TOKEN_STATUS="$(curl --silent http://127.0.0.1:4000/pls-can-i-has-access-token)"

	if [ "$TOKEN_STATUS" = "nope!" ] || [ "$TOKEN_STATUS" = "" ] # Server not started.  
	then
		# Ensure server is started.  
		if [ "$TOKEN_STATUS" = "" ]
		then
			echo "Starting oauthserver"
			/usr/local/Cellar/node/*/bin/node "$HOME/Library/Application Support/Übersicht/widgets/WunderlistTasksWidget/lib/oauthserver/server.js" & # This & tells the script to do it asynchronously.  
			sleep 2
		fi

		# Ask the user to allow this app to see their tasks.  
		echo "Requesting access..."
		WUNDERLIST_CODE_QUERY="https://www.wunderlist.com/oauth/authorize?client_id=$CLIENT_ID&redirect_uri=$SERVER_ENDPOINT&state=RANDOM"
		/usr/bin/open -a "/Applications/Safari.app" $WUNDERLIST_CODE_QUERY

		# Wait until the access token has been obtained.  
		while [ "$TOKEN_STATUS" == "nope!" ] || [ "$TOKEN_STATUS" == "" ]; do
			TOKEN_STATUS=$(curl --silent http://127.0.0.1:4000/pls-can-i-has-access-token)
			echo "Got $TOKEN_STATUS"
		    sleep 3
		done
	fi

	echo "$TOKEN_STATUS" >> "accesstoken.txt"
	ACCESS_TOKEN=$TOKEN_STATUS
}

# Try to read the token from a file first, if it doesn't exist, then ask the user for it.  
if [ -e "accesstoken.txt" ]; then
	if [[ $(< accesstoken.txt) != "" ]]; then
		# Ensure that the access token is valid.  
		POSSIBLE_TOKEN=$(< accesstoken.txt)

		echo "Checking \"$POSSIBLE_TOKEN\""

		# Indicates something other than an invalid token, just a weird ubersicht error.  
		STATUS_RESULT=500
		while [ $STATUS_RESULT = 500 ]; 
		do
			STATUS_RESULT=$(curl --write-out %{http_code} --silent --output /dev/null -H "X-Access-Token: $POSSIBLE_TOKEN" -H "X-Client-ID: $CLIENT_ID" -I https://a.wunderlist.com/api/v1/user)
			echo "Got response $STATUS_RESULT"
		done

		if [ $STATUS_RESULT = 200 ]; then 
			ACCESS_TOKEN=$POSSIBLE_TOKEN
		else
			rm accesstoken.txt
			requestToken
		fi
	else
		requestToken
	fi
else 
	requestToken
fi

# Tell the other lib to use the SDK and print everything out!  
echo "Starting datadisplayer"
/usr/local/Cellar/node/*/bin/node "$HOME/Library/Application Support/Übersicht/widgets/WunderlistTasksWidget/lib/datadisplay/datadisplayer.js" $CLIENT_ID $ACCESS_TOKEN

