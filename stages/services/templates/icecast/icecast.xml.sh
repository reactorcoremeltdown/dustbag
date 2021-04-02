#!/usr/bin/env bash

set -e

SOURCE_PASSWORD=$(jq -r '.secrets.icecast["source-password"]' /etc/secrets/secrets.json)
RELAY_PASSWORD=$(jq -r '.secrets.icecast["relay-password"]' /etc/secrets/secrets.json)
ADMIN_PASSWORD=$(jq -r '.secrets.icecast["admin-password"]' /etc/secrets/secrets.json)

cat <<EOF > /etc/icecast2/icecast.xml
<icecast>
    <location>Falkenstein, DE</location>
    <admin>admin@tiredsysadmin.cc</admin>
    <limits>
        <clients>100</clients>
        <sources>2</sources>
        <queue-size>524288</queue-size>
        <client-timeout>120</client-timeout>
        <header-timeout>15</header-timeout>
        <source-timeout>60</source-timeout>
        <burst-on-connect>1</burst-on-connect>
        <burst-size>65535</burst-size>
    </limits>

    <authentication>
        <source-password>${SOURCE_PASSWORD}</source-password>
        <relay-password>${RELAY_PASSWORD}</relay-password>
        <admin-user>admin</admin-user>
        <admin-password>${ADMIN_PASSWORD}</admin-password>
    </authentication>


    <!--<shoutcast-mount>/play</shoutcast-mount> -->

    <hostname>radio.tiredsysadmin.cc</hostname>

    <listen-socket>
        <port>8000</port>
        <bind-address>127.0.0.1</bind-address>
    </listen-socket>

    <http-headers>
        <header name="Access-Control-Allow-Origin" value="*" />
    </http-headers>

    <mount>
        <mount-name>/play</mount-name>
        <fallback-mount>/silence.ogg</fallback-mount>
        <fallback-override>1</fallback-override>
    </mount>

    <fileserve>1</fileserve>

    <paths>
        <basedir>/usr/share/icecast2</basedir>

        <logdir>/var/log/icecast2</logdir>
        <webroot>/usr/share/icecast2/web</webroot>
        <adminroot>/usr/share/icecast2/admin</adminroot>
        <alias source="/" destination="/status.xsl"/>
    </paths>

    <logging>
        <accesslog>access.log</accesslog>
        <errorlog>error.log</errorlog>
        <loglevel>3</loglevel> <!-- 4 Debug, 3 Info, 2 Warn, 1 Error -->
        <logsize>10000</logsize> <!-- Max size of a logfile -->
    </logging>

    <security>
        <chroot>0</chroot>
    </security>
</icecast>
EOF

chmod 640 /etc/icecast2/icecast.xml
chown root:icecast /etc/icecast2/icecast.xml
