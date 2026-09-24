#!/bin/bash
# Print an OmniFocus-ready ISO 8601 timestamp WITH the local UTC offset.
#
# omnifocus-mcp 1.3.0+ reads a bare "2026-09-28" as that local date at the default
# defer/planned/due time, so this script is only needed for other times. (Older
# servers read a bare date as UTC midnight, the previous evening in Pacific time.)
#
# Usage: of_date.sh YYYY-MM-DD [defer|planned|due|HH:MM]
#   defer   -> 00:00 local (start of day; matches Heath's existing defer dates)
#   planned -> 09:00 local
#   due     -> 17:00 local (end of workday)
#   HH:MM   -> explicit local time (use when the deadline has a real time)
# Handles PDT/PST automatically via the system timezone.
set -euo pipefail
day="${1:?usage: of_date.sh YYYY-MM-DD [defer|planned|due|HH:MM]}"
kind="${2:-defer}"
case "$kind" in
  defer)   t="00:00" ;;
  planned) t="09:00" ;;
  due)     t="17:00" ;;
  [0-2][0-9]:[0-5][0-9]) t="$kind" ;;
  *) echo "unknown kind: $kind" >&2; exit 1 ;;
esac
raw=$(date -j -f "%Y-%m-%d %H:%M" "$day $t" "+%Y-%m-%dT%H:%M:00%z")
# -0700 -> -07:00 for strict ISO 8601
echo "${raw:0:22}:${raw:22:2}"
