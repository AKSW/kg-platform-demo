
.env:
	echo UID=$$(id -u) > .env
	echo GID=$$(id -g) >> .env

.PHONY:

env: .env
