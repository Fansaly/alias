### rules for do not set proxy

`names.txt` file content example:
```
# this is a comment
wifi-ssid 0-1
wifi-ssid a-z # this is a comment
```

If the file is exists and content is valid, and connected WiFi ssid is `wifi-ssid 0-1` or `wifi-ssid a-z`, proxy server will not be set.