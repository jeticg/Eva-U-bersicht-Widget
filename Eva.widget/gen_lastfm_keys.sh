#!/bin/bash

echo "This script will generate secrets for Eva.widget to make calls to scrobble your music."
echo "Before execute script, please create an API account (http://www.last.fm/api/account/create) to get your API key and shared secret."

printf "API key: "
read API_KEY
printf "Shared secret: "
read SECRET

while true; do
    API_SIG=`md5 -qs "api_key${API_KEY}methodauth.getToken${SECRET}"`
    TOKEN=`curl -s "http://ws.audioscrobbler.com/2.0/?api_key=${API_KEY}&api_sig=${API_SIG}&format=json&method=auth.getToken" | sed 's/[{}:"(token)]//g'`
    token_size=${#TOKEN}
    printf "Token[len:${token_size}]: ${TOKEN}"
    # It is weird Last.fm will return tokens with length less than 32 characters.
    if [[ $token_size != 32 ]]; then
        echo "\t(error: incorrect token length!)"
    else
        echo "\n"
        break
    fi
done

echo "Your request token: ${TOKEN}"

echo "IMPORTANT! Please grant permission of use on Last.fm in browser."
read -n1 -r -p "Press any key to open authorization page..."
open "http://www.last.fm/api/auth/?api_key=${API_KEY}&token=${TOKEN}"

read -n1 -r -p "If you've granted permission, press any key to continue process..."
api_sig=`md5 -qs "api_key${API_KEY}methodauth.getSessiontoken${TOKEN}${SECRET}"`

echo "auth.getSession signature: ${api_sig}"
SESSION_RESP=`curl -s "http://ws.audioscrobbler.com/2.0/?api_key=${API_KEY}&api_sig=${api_sig}&format=json&method=auth.getSession&token=${TOKEN}"`
SESSION_KEY=$(echo $SESSION_RESP | sed -e 's/.*"key":"\([0-9a-z]\{32\}\)".*/\1/g')
USERNAME=$(echo $SESSION_RESP | sed -e 's/.*"name":"\([^"]\+\)".*/\1/g')

echo "session key=${SESSION_KEY}, username=${USERNAME}"

echo "${USERNAME}~${API_KEY}~${SECRET}~${SESSION_KEY}" > "lastfm.auth.conf"

