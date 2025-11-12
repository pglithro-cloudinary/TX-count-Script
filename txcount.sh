#!/usr/bin/env bash
#
# cld-transform-counter.sh
# Usage:
#   ./cld-transform-counter.sh "https://res.cloudinary.com/<cloud_name>/image/upload/.../asset.jpg"
#   ./cld-transform-counter.sh --watch "https://res.cloudinary.com/<cloud_name>/image/upload/.../asset.jpg"

set -e

# ────────────────────────────────────────────────
# Argument handling
# ────────────────────────────────────────────────

WATCH_MODE=false
if [ "$1" == "--watch" ]; then
  WATCH_MODE=true
  URL="$2"
else
  URL="$1"
fi

if [ -z "$URL" ]; then
  echo "❌ Usage: $0 [--watch] <Cloudinary transformation URL>"
  exit 1
fi

INTERVAL=10      # seconds between checks
MAX_ATTEMPTS=30  # used only in one-shot mode

# ────────────────────────────────────────────────
# Helper functions
# ────────────────────────────────────────────────

get_usage_total() {
  cld admin usage | jq '.transformations.usage'
}

get_cloud_name() {
  cld admin config | jq -r '.cloud_name'
}

# Clear the current line completely
clear_line() {
  printf "\r\033[K"
}

# ────────────────────────────────────────────────
# Cloud name verification
# ────────────────────────────────────────────────

CLOUD_NAME=$(get_cloud_name)
if [[ -z "$CLOUD_NAME" || "$CLOUD_NAME" == "null" ]]; then
  echo "❌ Could not retrieve cloud_name from 'cld admin config'."
  exit 1
fi

if ! echo "$URL" | grep -q "res.cloudinary.com/$CLOUD_NAME"; then
  echo "⚠️  WARNING: The provided URL does not match your configured Cloudinary cloud_name."
  echo "Configured: $CLOUD_NAME"
  echo "URL:        $URL"
  echo "Proceeding anyway after 5 seconds... (Ctrl+C to abort)"
  sleep 5
fi

# ────────────────────────────────────────────────
# Baseline capture and monitoring
# ────────────────────────────────────────────────

echo "🔹 Fetching baseline transformation usage for cloud '$CLOUD_NAME'..."
BASE_TOTAL=$(get_usage_total)
echo "Baseline usage: $BASE_TOTAL"

echo -n "🔹 Requesting transformation URL... "
curl -s -o /dev/null "$URL"
echo "done."

# ────────────────────────────────────────────────
# Monitoring loop
# ────────────────────────────────────────────────

if [ "$WATCH_MODE" = true ]; then
  echo "🔹 Watching for transformation usage changes (Ctrl+C to stop)..."
  PREV_TOTAL="$BASE_TOTAL"
  while true; do
    sleep "$INTERVAL"
    CURRENT_TOTAL=$(get_usage_total)
    clear_line
    printf "⏳ Current usage = %s" "$CURRENT_TOTAL"
    if [ "$CURRENT_TOTAL" -gt "$PREV_TOTAL" ]; then
      DIFF=$((CURRENT_TOTAL - PREV_TOTAL))
      clear_line
      echo "✅ Transformation usage increased by $DIFF (total: $CURRENT_TOTAL)"
      PREV_TOTAL="$CURRENT_TOTAL"
    fi
  done
else
  echo "🔹 Polling for change in transformation usage..."
  ATTEMPT=0
  while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    sleep "$INTERVAL"
    CURRENT_TOTAL=$(get_usage_total)
    clear_line
    printf "⏳ Check #%-2d | current usage = %s" "$((ATTEMPT+1))" "$CURRENT_TOTAL"
    if [ "$CURRENT_TOTAL" -gt "$BASE_TOTAL" ]; then
      clear_line
      echo "✅ Transformation usage increased by $((CURRENT_TOTAL - BASE_TOTAL))."
      exit 0
    fi
    ATTEMPT=$((ATTEMPT + 1))
  done
  clear_line
  echo "⚠️  No change detected after $((INTERVAL * MAX_ATTEMPTS)) seconds."
fi
