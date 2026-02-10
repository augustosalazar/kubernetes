#!/bin/sh

SERVICE_URL="$1"
REQUESTS=20     # default: 5 requests
PARALLELISM=6          # default: 4 parallel requests

if [ -z "$SERVICE_URL" ]; then
  echo "Usage: $0 <SERVICE_URL> [REQUESTS] [PARALLELISM]"
  exit 1
fi

echo "Service URL : $SERVICE_URL"
echo "Requests    : $REQUESTS"
echo "Parallelism : $PARALLELISM"
echo

time sh -c "
seq 1 $REQUESTS | xargs -n1 -P$PARALLELISM -I{} sh -c '
  echo \"Request {}\"
  curl -w \"  took %{time_total}s\n\" -o /dev/null -s $SERVICE_URL
'
"
