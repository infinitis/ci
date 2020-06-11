#!/usr/bin/env bash

set -euo pipefail

cat /etc/nginx/nginx.conf << EOF
http {
	server {
		listen 80;

		location / {
			gzip off;
			root /home/git/repos;

			fastcgi_pass localhost:9418;
			fastcgi_param SCRIPT_FILENAME /usr/lib/git-core/git-http-backend;
			fastcgi_param DOCUMENT_ROOT /usr/lib/git-core/;
			fastcgi_param SCRIPT_NAME git-http-backend;
			fastcgi_param GIT_HTTP_EXPORT_ALL "";
		}
	}
}
EOF

nginx -g 'daemon off;'