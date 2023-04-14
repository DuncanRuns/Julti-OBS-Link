obs = obslua

julti_dir = os.getenv("UserProfile"):gsub("\\", "/") .. "/.Julti/"
timers_activated = false
last_state_text = ""
last_scene_name = ""

total_width = 0
total_height = 0

-- script settings
win_cap_instead = false
reuse_for_verification = false
invisible_dirt_covers = false
