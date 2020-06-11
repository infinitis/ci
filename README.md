### Continuous Integration Project
Project will automatically pull changes from a directory containing git repositories at REMOTE_LOCATION and push all changes to github. Also provides a gitweb interface and http mirroring for public facing git repositories.

Environmental Variables Required:
- GITHUB_USERNAME (username of user with which to push repositories to github)
- HOST_FINGERPRINT (ssh key fingerprint to be placed in known_hosts)
- REMOTE_LOCATION (location of remote git repositories)
- REPOSITORY_NAMES (repositories to mirror separated  by '\n')
- SITE_NAME (title of the gitweb site)

SSH Keys Required:
- /home/git/.ssh/remote (remote ssh key)
- /home/git/.ssh/remote.pub (remote ssh public key)
- /home/git/.ssh/github (github ssh key)
- /home/git/.ssh/github.pub (github ssh public key)