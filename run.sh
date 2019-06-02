#!/bin/bash

DATABASE=data/listings.db

cd "${0%/*}"

if test -f "$DATABASE"; then
  echo "Commodity listings database already exists.."
else
  echo "Initializing commodity database data/listings.db from csv file.."
  cat listings.sql | sqlite3
fi
