#! /usr/bin/env bash
# version: 0.2

base_site="https://www.reddit.com"
results_json="/tmp/results.json"

# get subreddit
subreddit=$(echo | dmenu -h 25 -X 5 -Y 5 -p "Enter Subreddit Name: " | sed "s/ //g")

# get search term
if [ -n "$subreddit" ]; then
  search_term=$(echo | dmenu -h 25 -X 5 -Y 5 -p "Enter Search Term: " | sed "s/ /%20/g")
  search="$(echo 'https://www.reddit.com/r/SUBREDDIT/search/.json?q=SEARCH_TERM&restrict_sr=1' | sed "s/SUBREDDIT/$subreddit/" | sed "s/SEARCH_TERM/$search_term/")"
fi

# getting link
# use $search to view in browser
if [ -n "$search_term" ]; then
  printf "Downloading Search Results For: %s ..." "$search"
  curl -H "User-Agent: 'your bot 0.1'" "$search" > "$results_json"

  no_link="$(grep -c permalink $results_json)"

  # loop
  while :
  do
    if [ -s "$results_json" ] && [ "$no_link" -ne 0 ]; then
      permalink=$(jq -r '.data.children[] | .data["title", "permalink"]' "$results_json" | paste -d "|" - - | dmenu -h 25 -X 5 -Y 5 -l 15 | cut -d'|' -f 2 | xargs)

      if [ -n "$permalink" ]; then
        notify-send "Link in clipboard"
        firefox $base_site$permalink
        echo "$base_site$permalink" | xclip -selection c
      else
        break
      fi
    else
      notify-send "No Results Found"
      break
    fi
  done
fi
