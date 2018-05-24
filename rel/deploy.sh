#!/bin/sh

echo "Building assets..."
node_modules/brunch/bin/brunch build -p

echo "Digesting files..."
MIX_ENV=prod mix phoenix.digest

echo "Building releae..."
MIX_ENV=prod mix release --env=prod

echo "Syncing to server"
rsync -avz --delete _build/prod/rel/artus ias:~/app
