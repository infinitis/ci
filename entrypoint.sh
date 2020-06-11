#!/usr/bin/env bash

set -euo pipefail

# verify that variables used only in sourced files are set
# so exit/failure will happen appropriately
# ( source returns 0 if no commands are run which happen with bash strict mode )
REMOTE=$REMOTE_LOCATION
REPOS=$REPOSITORY_NAMES

# setup ssh
runuser -u git -- mkdir -p /home/git/.ssh
echo "$HOST_FINGERPRINT" >> /home/git/.ssh/known_hosts
cat > /home/git/.ssh/config << EOF
Host github.com
	IdentityFile ~/.ssh/keys/github
	User git
	StrictHostKeyChecking no
EOF

chown git:git /home/git/.ssh/known_hosts
chown git:git /home/git/.ssh/config

# clone repos
. /clone.sh

# setup fcgiwrap
echo "FCGI_CHILDREN=2" > /etc/default/fcgiwrap
service fcgiwrap start

# setup nginx
cat > /etc/nginx/nginx.conf << EOF
user www-data www-data;
events { }
http {
	include mime.types;

	server {
		listen 80;
		root /usr/share/gitweb;

		# static repo files for cloning over https
		location ~ ^.*\.git/objects/([0-9a-f]+/[0-9a-f]+|pack/pack-[0-9a-f]+.(pack|idx))$ {
			root /repos/;
		}

		# requests that need to go to git-http-backend
		location ~ ^.*\.git/(HEAD|info/refs|objects/info/.*|git-(upload|receive)-pack)$ {
			root /repos/;

			fastcgi_pass  unix:/var/run/fcgiwrap.socket;
			fastcgi_param SCRIPT_FILENAME   /usr/lib/git-core/git-http-backend;
			fastcgi_param PATH_INFO         \$uri;
			fastcgi_param GIT_PROJECT_ROOT  \$document_root;
			fastcgi_param GIT_HTTP_EXPORT_ALL "";
			fastcgi_param REMOTE_USER \$remote_user;
			include fastcgi_params;
		}

		# Remove all conf beyond if you don't want Gitweb
		try_files \$uri @gitweb;
		location @gitweb {
			fastcgi_pass  unix:/var/run/fcgiwrap.socket;
			fastcgi_param SCRIPT_FILENAME   /usr/share/gitweb/gitweb.cgi;
			fastcgi_param PATH_INFO         \$uri;
			fastcgi_param GITWEB_CONFIG     /etc/gitweb.conf;
			include fastcgi_params;
	   }
	}
}
EOF

# setup gitweb
cat > /etc/gitweb.conf << EOF
\$projectroot = "/repos";
\$git_temp = "/tmp";
\$site_name = "$SITE_NAME";
\$base_url = "/";
EOF

# setup push.sh script for cron
cat > /push.sh << EOF
#!/usr/bin/env bash

set -euo pipefail

while IFS= read -r repo
do
	if [[ -n "\$repo" ]]; then
		cd "/repos/\$repo.git"
		if [[ -z "\`git remote | grep github\`" ]]; then
			git remote add github "git@github.com:$GITHUB_USERNAME/\$repo.git"
		fi
		git push --all -f github
	fi
done < <(echo "$REPOSITORY_NAMES")
EOF
chmod +x /push.sh

# setup fetch.sh script for cron
cat > /fetch.sh << EOF
#!/usr/bin/env bash

set -euo pipefail

while IFS= read -r repo
do
	if [[ -n "\$repo" ]]; then
		cd "/repos/\$repo.git"
		git fetch --prune --prune-tags
	fi
done < <(echo "$REPOSITORY_NAMES")
EOF
chmod +x /fetch.sh

# setup cron
service cron start

# start nginx
nginx -g 'daemon off;'