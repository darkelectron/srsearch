# srsearch
<p align="center">
<img src="./scrot.png" />
</p>

Search subreddit using dmenu.

In cases where input is not required, `fzf` or `rofi` can be used.

## Dependencies
- jq
- dmenu
- xclip
- curl

## How to use
- run script and you'll see a dmenu window.
- type a subreddit to search, _e.g commandline_.
- type in search term, _e.g bash is cool_.
- you'll see results in a dmenu window, choose topic or link, which will be copied to your clipboard and opened through `firefox`.

## TODO
- [ ] results limit.
- [x] loop through results
- [ ] ~~choose what to do with results~~
