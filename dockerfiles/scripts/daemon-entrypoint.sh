#!/bin/bash

set -euo pipefail

# If glob doesn't match anything, return empty string rather than literal pattern
shopt -s nullglob


set -x

INPUT_ARGS="$@"

# Attempt to execute or source custom entrypoint scripts accordingly
for script in /entrypoint.d/*; do
  if [ -x "$script" ]; then
    "$script" $INPUT_ARGS
  else
    source "$script"
  fi
done

# Mina daemon initialization
mkdir -p .mina-config
touch .mina-config/mina-prover.log
touch .mina-config/mina-verifier.log
touch .mina-config/mina-best-tip.log

while true; do
  rm -f .mina-config/.mina-lock
  mina $INPUT_ARGS 2>&1 >mina.log &
  mina_pid=$!

  tail -q -f mina.log -f .mina-config/mina-prover.log -f .mina-config/mina-verifier.log -f .mina-config/mina-best-tip.log &
  tail_pid=$!

  wait "$mina_pid"
  echo "Mina process exited with status code $?"
  sleep 10

  kill "$tail_pid"
  if [ ! -f stay_alive ]; then
    exit 0
  fi
done
