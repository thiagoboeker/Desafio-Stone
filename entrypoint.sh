#!/bin/sh

./prod/rel/stoned/bin/stoned eval Stoned.Release.migrate

./prod/rel/stoned/bin/stoned eval Stoned.Release.seeds

./prod/rel/stoned/bin/stoned start
