#!/bin/sh

while ! pg_isready -q -h $PG_HOST -p 5432 -U $PG_USER
do
  echo "$(date) Waiting POSTGRES to start"
  sleep 2
done

./prod/rel/stoned/bin/stoned eval Stoned.Release.migrate

./prod/rel/stoned/bin/stoned eval Stoned.Seeds.run

./prod/rel/stoned/bin/stoned start
