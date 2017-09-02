#!/bin/bash
node_modules/brunch/bin/brunch build -p
MIX_ENV=prod mix phoenix.digest
MIX_ENV=prod mix release --env=prod
