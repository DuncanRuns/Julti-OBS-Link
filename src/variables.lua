obs = obslua

julti_dir = os.getenv("UserProfile"):gsub("\\", "/") .. "/.Julti/"
timers_activated = false
last_state_text = ""
last_scene_name = ""

gen_scenes_requested = false
gen_stream_scenes_requested = false

total_width = 0
total_height = 0


-- Script Settings
win_cap_instead = false
reuse_for_verification = false
invisible_dirt_covers = false
center_align_instances = false


-- Constants
ALIGN_TOP_LEFT = 5 -- equivalent to obs.OBS_ALIGN_TOP | obs.OBS_ALIGN_LEFT
ALIGN_CENTER = 0   -- equivalent to obs.OBS_ALIGN_CENTER
