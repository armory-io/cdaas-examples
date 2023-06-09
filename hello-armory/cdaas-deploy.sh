#!/bin/bash

SOURCE="https://raw.githubusercontent.com/matttharma/my-sample-app/main/hello-armory/first-deployment.yaml"

#CLIENT_ID="Jh9Vu3AIVkKiYpTQ2hwH4SS1LiqSlwRi"
#CLIENT_SECRET="kk9cZ9RkIPDvFBU1GN2eYkFNXg7rCl__E9Pz-IFzU99yj-q1uU44CjNXoL3h2vLI"

CLIENT_ID="8LxyEv5OPbsWdqXNmB2MpLMJMFy9KQlx"
CLIENT_SECRET="8tyZgjp7qbXVrLDvqzqs3FFYLwnPVVHeGNwxqiLAM2ntJhzGZT0Zj-5sXoTvKKjq"

echo "       SOURCE: $SOURCE"
echo "    CLIENT_ID: $CLIENT_ID"
echo "CLIENT_SECRET: $CLIENT_SECRET"

armory deploy start -f $SOURCE -c $CLIENT_ID -s $CLIENT_SECRET

echo

