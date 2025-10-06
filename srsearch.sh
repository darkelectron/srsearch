#!/usr/bin/env bash
# version: 0.3.2

set -e

base_site="https://old.reddit.com"
results_json="/tmp/results.json"

usage() {
  notify-send -i reddit "srsearch" "Usage: $0 [clipboard|browser]"
  exit 1
}

if [[ -z "$1" || ! "$1" =~ ^(clipboard|browser)$ ]]; then
  usage
fi

# Subreddit input loop
while true; do
  subreddit=$(echo | fuzzel --dmenu --prompt "Enter Subreddit Name:" | sed "s/ //g")
  [[ -z "$subreddit" ]] && notify-send -i reddit "srsearch" "No subreddit entered" && exit 1

  http_code=$(curl -H "User-Agent: srsearch/1.0" -s -o /dev/null -w "%{http_code}" \
    "https://old.reddit.com/r/$subreddit/about.json")

  if [[ "$http_code" == "200" ]]; then
    break
  else
    notify-send -i reddit -u critical "srsearch" "Subreddit '$subreddit' does not exist"
  fi
done

# Get search term
search_term=$(echo | fuzzel --dmenu --prompt "Enter Search Term:" | sed "s/ /%20/g")
[[ -z "$search_term" ]] && notify-send -i reddit "srsearch" "No search term entered" && exit 1

search_url="https://www.reddit.com/r/$subreddit/search/.json?q=$search_term&restrict_sr=on&include_over_18=on"

notify-send -i reddit "srsearch" "Downloading JSON ..."
curl -H "User-Agent: srsearch/1.0" -s "$search_url" > "$results_json"

no_link=$(grep -c permalink "$results_json")

if [[ ! -s "$results_json" || "$no_link" -eq 0 ]]; then
  notify-send -i reddit "srsearch" "No Results Found"
  exit 0
fi

while true; do
  # Present results with dmenu
  result=$(jq -r '.data.children[] | [.data.title, .data.permalink] | @tsv' "$results_json" | \
    awk -F'\t' '{print $1 "|" $2}' | fuzzel --dmenu --prompt "Results:")

  permalink=$(cut -d'|' -f2 <<< "$result" | xargs)
  [[ -z "$permalink" ]] && break

  url="$base_site$permalink"
  case "$1" in
    clipboard)
      echo "$url" | wl-copy

      notify-send -i reddit "srsearch" "Copied to clipboard: $url"
      ;;
    browser)
      "${BROWSER:-xdg-open}" "$url"
      notify-send -i reddit "srsearch" "Opened in browser: $url"
      ;;
  esac
done
