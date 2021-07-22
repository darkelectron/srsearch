#! /usr/bin/env bash
# version: 0.2

base_site="https://www.reddit.com"
results_json="results.json"

# get subreddit
subreddit=$(echo | dmenu -p "Enter Subreddit Name: " | sed "s/ //g")

# get search term
if [ -n "$subreddit" ]; then
  search_term=$(echo | dmenu -p "Enter Search Term: ")
  search="$(echo 'https://www.reddit.com/r/SUBREDDIT/search/.json?q=SEARCH_TERM&restrict_sr=1' | sed "s/SUBREDDIT/$subreddit/" | sed "s/SEARCH_TERM/$search_term/")"
fi

# getting link
# use $search to view in browser
if [ -n "$search_term" ]; then
  printf "Downloading Search Results For: %s ..." "$search"
  curl -H "User-Agent: 'your bot 0.1'" "$search" > "$results_json"

  if [ -s "$results_json" ]; then
    permalink=$(jq '.data.children[] | .data["title", "permalink"]' "$results_json" | paste -d "|" - - | dmenu -l 15 | cut -d'|' -f 2 | xargs)

    if [ -n "$permalink" ]; then
      notify-send "Link in clipboard"
      echo "$base_site$permalink" | xclip -selection c
    fi
  else
    notify-send "No Results Found"
  fi
fi
