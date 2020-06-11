#!/usr/bin/env bash

while IFS= read -r repo
do
	if [[ -n "$repo" ]]; then
		runuser -u git -- git clone --mirror -c core.sshcommand="ssh -i ~/.ssh/keys/remote" "$REMOTE$repo"
		runuser -u git -- echo "$repo" > "/repos/$repo.git/description"
	fi
done < <(echo "$REPOS")