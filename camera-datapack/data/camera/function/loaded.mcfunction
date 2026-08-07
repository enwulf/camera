scoreboard objectives add camera_mark dummy
tellraw @a [{"text":"Camera loaded. ","color":"gray"},{"text":"[ take a photo ]","color":"aqua","bold":true,"click_event":{"action":"run_command","command":"/function camera:shot"}}]
