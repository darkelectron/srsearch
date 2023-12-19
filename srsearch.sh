#! /usr/bin/env bash
# version: 0.3.1

if [ -z "$1" ]; then
  # printf "Usage: $0 [clipboard|browser]"
  notify-send -i reddit "srsearch" "No Arguments Supplied"
  exit 1
fi

base_site="https://old.reddit.com"
results_json="/tmp/results.json"

# get subreddit
subreddit=$(echo | dmenu -p "Enter Subreddit Name: " | sed "s/ //g")

# get search term
if [ -n "$subreddit" ]; then
  search_term=$(echo | dmenu -p "Enter Search Term: " | sed "s/ /%20/g")
  search="$(echo 'https://www.reddit.com/r/SUBREDDIT/search/.json?q=SEARCH_TERM&restrict_sr=1' | sed "s/SUBREDDIT/$subreddit/" | sed "s/SEARCH_TERM/$search_term/")"
fi

# getting link
# use $search to view in browser
if [ -n "$search_term" ]; then
  # printf "Downloading Search Results For: %s ..." "$search"
  notify-send -i reddit "srsearch" "Downloading JSON ..."
  curl -H "User-Agent: 'your bot 0.1'" "$search" > "$results_json"

  no_link="$(grep -c permalink $results_json)"

  # loop
  while :
  do
    if [ -s "$results_json" ] && [ "$no_link" -ne 0 ]; then
      permalink=$(jq -r '.data.children[] | .data["title", "permalink"]' "$results_json" | paste -d "|" - - | dmenu -p "Results: " | cut -d'|' -f 2 | xargs)

      if [ -n "$permalink" ]; then
        case "$1" in
          clipboard)
            echo "$base_site$permalink" | xclip -selection c
            ;;
          browser)
            $BROWSER "$base_site$permalink"
            ;;
          *)
            notify-send -i reddit "srsearch" "incorrect option"  # will remove later
        esac
      else
        break
      fi
    else
      notify-send -i reddit "srsearch" "No Results Found"
      break
    fi
  done
fi
