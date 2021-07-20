#! /usr/bin/env bash
# version: 0.1

# get subreddit
subreddit=$(echo | dmenu -p "Enter Subreddit Name: " | sed "s/ //g")

# get search term
if [ -n "$subreddit" ]; then
  search_term=$(echo | dmenu -p "Enter Search Term: ")
  search="$(echo 'https://www.reddit.com/r/SUBREDDIT/search/.json?q=SEARCH_TERM&restrict_sr=1' | sed "s/SUBREDDIT/$subreddit/" | sed "s/SEARCH_TERM/$search_term/")"
fi

# getting link
# use $search to view in browser
if [ -n "$search" ]; then
  printf "Opening Link: %s ..." "$search"
  # firefox -new-tab "$search"
  curl -H "User-Agent: 'your bot 0.1'" "$search" > file.json

  if [ -s file.json ]; then
    # sed for removing comma at the end
    permalink=$(jq . file.json | grep -E '"title":|"permalink":' | sed 's/^[ \t]*//' | sed 's/,\([^,]*\)$/ \1/' | paste -d "|" - - | sed 's/"title"://' | sed 's/"permalink"://' | dmenu -l 15 | cut -d'|' -f 2 | xargs)
    echo "https://www.reddit.com$permalink"
  fi
fi
