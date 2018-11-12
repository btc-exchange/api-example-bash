#!/bin/bash

API_KEY=d62a2b9e-9602-484c-85dc-b257224eacad
PRIVATE_KEY=/home/ubuntu/btc-exchange.com/btc-exchange-api.pem

generateJwtToken()
{
    jwt_header=$(echo -n '{"typ":"JWT","alg":"RS256"}'| base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    jwt_payload=$(echo -n \{\"iat\":`date +%s`,\"exp\":`date -d '+30 seconds' +%s`,\"sub\":\"api_key_jwt\",\"iss\":\"external\",\"jti\":\"`cat /dev/urandom | tr -dc 'A-Z0-9'| fold -w 12 | head -n 1`\"\}| base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')

    jwt_sign=$(echo -n "$jwt_header.$jwt_payload" |openssl dgst -binary -sha256 -sign $PRIVATE_KEY | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')

    printf '%s' "$jwt_header.$jwt_payload.$jwt_sign"
}

getToken()
{
    printf '%s' $(curl -s -X POST -H "x-api-key: $API_KEY" -d "kid=$API_KEY&jwt_token=`generateJwtToken`" "https://api.btc-exchange.com/pauth/web/sessions/generate_jwt" |cut -d'"' -f4)
}

curl -X GET \
-H "x-api-key: $API_KEY" \
-H "Authorization: Bearer `getToken`" \
"https://api.btc-exchange.com/papi/web/members/me"
