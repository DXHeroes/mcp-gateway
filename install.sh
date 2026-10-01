#!/bin/sh
# DXH Gateway Community Edition installer.
#
#   curl -fsSL https://raw.githubusercontent.com/DXHeroes/mcp-gateway/beta/install.sh | sh
#
# Installs the release this branch describes with Docker Compose. Running it again is the
# upgrade: it replaces the compose files and keeps .env (the secrets) and the database volume.
# Run with --help for the options.
set -eu

CE_TERMS_VERSION=2026-09-18.1
BASE_URL=${GATEWAY_INSTALL_BASE_URL:-https://raw.githubusercontent.com/DXHeroes/mcp-gateway/beta/}
BASE_URL=${BASE_URL%/}
TERMS_URL=$BASE_URL/LICENSE-CE.txt
UPGRADE_NOTES=https://github.com/DXHeroes/mcp-gateway/blob/main/docs/help/deployment/upgrade-notes.md

say() { printf '%s\n' "$*"; }
fail() {
  printf 'install.sh: %s\n' "$*" >&2
  exit 1
}
need() { command -v "$1" >/dev/null 2>&1 || fail "$1 is required, but it is not installed"; }

usage() {
  cat <<EOF
Usage: install.sh [--dir DIR] [--domain HOST] [--install-docker]

Installs DXH Gateway Community Edition with Docker Compose, or upgrades an installation this
script made: the compose files are replaced, .env (secrets, settings) and the database are kept.

  --dir DIR         where the installation lives (default: ./mcp-gateway)
  --domain HOST     serve https://HOST through Caddy with an automatic Let's Encrypt
                    certificate; DNS for HOST must point here and ports 80 and 443 be open
  --install-docker  on Linux, install Docker Engine first when it is missing (get.docker.com)
  -h, --help        show this help

The installer asks you to accept the CE terms ($TERMS_URL).
Without a terminal (cloud-init, CI), accept them with GATEWAY_CE_TERMS_ACCEPTED=$CE_TERMS_VERSION.
EOF
}

# The last value of KEY in an env file, without surrounding quotes; empty when unset.
env_value() {
  if [ -f "${2:-.env}" ]; then
    sed -n "s/^$1=//p" "${2:-.env}" | tail -n 1 | sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/"
  fi
}

# Sets KEY=VALUE in .env, in place when the key is there already.
set_env() {
  if grep -q "^$1=" .env; then
    KEY=$1 VALUE=$2 awk 'index($0, ENVIRON["KEY"] "=") == 1 { print ENVIRON["KEY"] "=" ENVIRON["VALUE"]; next } { print }' .env >.env.tmp
    mv .env.tmp .env
  else
    printf '%s=%s\n' "$1" "$2" >>.env
  fi
}

fetch() {
  curl -fsSL "$BASE_URL/$1" -o "$1.download" || {
    rm -f "$1.download"
    fail "could not download $BASE_URL/$1"
  }
  mv "$1.download" "$1"
}

install_docker_engine() {
  [ "$(uname -s)" = Linux ] || fail "--install-docker works on Linux only; install Docker Desktop: https://docs.docker.com/desktop/"
  sudo=
  if [ "$(id -u)" -ne 0 ]; then
    need sudo
    sudo=sudo
  fi
  say "Installing Docker Engine with https://get.docker.com"
  curl -fsSL https://get.docker.com | $sudo sh
}

dir=./mcp-gateway
domain=
install_docker=false
while [ $# -gt 0 ]; do
  case $1 in
  --dir)
    [ $# -ge 2 ] || fail "--dir needs a directory"
    dir=$2
    shift 2
    ;;
  --dir=*)
    dir=${1#--dir=}
    shift
    ;;
  --domain)
    [ $# -ge 2 ] || fail "--domain needs a host name"
    domain=$2
    shift 2
    ;;
  --domain=*)
    domain=${1#--domain=}
    shift
    ;;
  --install-docker)
    install_docker=true
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *) fail "unknown option $1 (see --help)" ;;
  esac
done
[ -n "$dir" ] || fail "--dir needs a directory"
case $domain in
*[!A-Za-z0-9.-]* | .* | *. | *..*)
  fail "--domain takes a host name such as gateway.example.com, not a URL: $domain"
  ;;
esac

need curl
need openssl

# Nothing is written before the terms are accepted: in the environment, on an earlier run, or now.
accepted=${GATEWAY_CE_TERMS_ACCEPTED:-}
if [ -n "$accepted" ]; then
  [ "$accepted" = "$CE_TERMS_VERSION" ] ||
    fail "GATEWAY_CE_TERMS_ACCEPTED=$accepted, but the current CE terms are version $CE_TERMS_VERSION. Read $TERMS_URL, then set GATEWAY_CE_TERMS_ACCEPTED=$CE_TERMS_VERSION."
elif [ "$(env_value GATEWAY_CE_TERMS_ACCEPTED "$dir/.env")" = "$CE_TERMS_VERSION" ]; then
  : # accepted on an earlier run
elif (: </dev/tty) 2>/dev/null; then
  {
    say "DXH Gateway Community Edition is distributed under the DXH Gateway CE terms,"
    say "version $CE_TERMS_VERSION: $TERMS_URL"
    printf 'Do you accept these terms? [y/N] '
  } >/dev/tty
  read -r answer </dev/tty || answer=
  case $answer in
  [yY] | [yY][eE][sS]) ;;
  *) fail "the CE terms were not accepted; nothing was installed" ;;
  esac
else
  fail "accept the CE terms first. Read $TERMS_URL, then run: curl -fsSL $BASE_URL/install.sh | GATEWAY_CE_TERMS_ACCEPTED=$CE_TERMS_VERSION sh"
fi

if ! command -v docker >/dev/null 2>&1; then
  [ "$install_docker" = true ] || fail "Docker is not installed. Install Docker Engine with the Compose plugin (https://docs.docker.com/engine/install/), or on Linux re-run with --install-docker."
  install_docker_engine
fi
docker compose version >/dev/null 2>&1 ||
  fail "Docker Compose v2 ('docker compose') is required: https://docs.docker.com/compose/install/"
docker info >/dev/null 2>&1 ||
  fail "Docker is installed, but this user cannot use it. Start the Docker daemon, or run the installer as root or as a member of the docker group."

mkdir -p "$dir"
cd "$dir"
umask 077
upgrade=false
[ -f .env ] && upgrade=true

https=false
[ -n "$domain" ] && https=true
case $(env_value COMPOSE_FILE) in *compose.https.yaml*) https=true ;; esac

fetch compose.yaml
[ "$https" = false ] || fetch compose.https.yaml

if [ "$upgrade" = false ]; then
  cat >.env <<'EOF'
# DXH Gateway settings, written by install.sh. Keep this file and back it up together with the
# database: GATEWAY_ENCRYPTION_KEY decrypts the credentials stored there. Re-running the
# installer keeps every value set here.
EOF
elif [ -s .env ] && [ -n "$(tail -c 1 .env)" ]; then
  echo >>.env
fi
chmod 600 .env
[ -n "$(env_value POSTGRES_PASSWORD)" ] || set_env POSTGRES_PASSWORD "$(openssl rand -hex 32)"
[ -n "$(env_value AUTH_SECRET)" ] || set_env AUTH_SECRET "$(openssl rand -base64 32)"
[ -n "$(env_value GATEWAY_ENCRYPTION_KEY)" ] || set_env GATEWAY_ENCRYPTION_KEY "$(openssl rand -base64 32)"
[ -n "$(env_value PUBLIC_URL)" ] || set_env PUBLIC_URL http://localhost:3001
[ -n "$(env_value AUTH_SIGNUP_MODE)" ] || set_env AUTH_SIGNUP_MODE open
[ "$(env_value GATEWAY_CE_TERMS_ACCEPTED)" = "$CE_TERMS_VERSION" ] ||
  set_env GATEWAY_CE_TERMS_ACCEPTED "$CE_TERMS_VERSION"
if [ -n "$domain" ]; then
  set_env PUBLIC_URL "https://$domain"
  compose_file=$(env_value COMPOSE_FILE)
  case $compose_file in
  *compose.https.yaml*) ;;
  '') set_env COMPOSE_FILE compose.yaml:compose.https.yaml ;;
  *) set_env COMPOSE_FILE "$compose_file:compose.https.yaml" ;;
  esac
fi

# shellcheck disable=SC2016 # the ${...} is the compose file's own syntax, matched literally
image=$(sed -n 's/^ *image: *\${GATEWAY_IMAGE:-\([^}]*\)}.*/\1/p' compose.yaml | head -n 1)
pinned=$(env_value GATEWAY_IMAGE)
if [ -n "$pinned" ]; then
  say "GATEWAY_IMAGE in $PWD/.env pins $pinned; remove it to run $image."
  image=$pinned
fi

say "Starting DXH Gateway ($image) in $PWD"
docker compose pull
docker compose up -d --wait ||
  fail "the gateway did not become healthy. See what it says: cd $PWD && docker compose logs gateway"

public_url=$(env_value PUBLIC_URL)
say ""
if [ "$upgrade" = true ]; then
  say "DXH Gateway is running $image at $public_url."
  say "Read the upgrade notes of every version you skipped: $UPGRADE_NOTES"
else
  say "DXH Gateway is running at $public_url."
  say ""
  say "Next steps:"
  say "  1. Open it and register the first account at once: it becomes the owner."
  say "  2. Close the sign-up: set AUTH_SIGNUP_MODE=invite_only in $PWD/.env,"
  say "     then run: cd $PWD && docker compose up -d"
  say "  3. Back up .env together with the database:"
  say "     docker compose exec -T postgres pg_dump -U gateway -Fc gateway > gateway-\$(date +%F).dump"
fi
if [ "$https" = false ]; then
  say ""
  say "It listens on 127.0.0.1:3001 only. From your computer: ssh -L 3001:localhost:3001 <server>,"
  say "then open http://localhost:3001. To serve it on a domain with HTTPS, run the installer"
  say "again with --domain <host>."
fi
if [ "$upgrade" = false ]; then
  say ""
  say "To upgrade later, run the installer again. Upgrade notes: $UPGRADE_NOTES"
fi
