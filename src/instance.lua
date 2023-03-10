obs = obslua

function set_instance_data(num, lock_visible, cover_visible, x, y, width, height)
    local group = get_group_as_scene("Instance " .. num)

    -- Lock Display: visibility and crop
    local item = obs.obs_scene_find_source(group, "Lock Display")
    obs.obs_sceneitem_set_visible(item, lock_visible)
    set_crop(item, 0, 0, total_width - width, total_height - height)

    -- Dirt Cover: visibility and bounds
    local item = obs.obs_scene_find_source(group, "Dirt Cover Display")
    obs.obs_sceneitem_set_visible(item, cover_visible)
    set_position_with_bounds(item, 0, 0, width, height)

    -- Minecraft capture: position and bounds
    local item = obs.obs_scene_find_source(group, "Minecraft Capture " .. num)
    set_position_with_bounds(item, 0, 0, width, height)

    -- Instance Group: position
    local scene = get_scene("Julti")
    local item = obs.obs_scene_find_source(scene, "Instance " .. num)
    set_position(item, x, y)
end

function set_instance_data_from_string(instance_num, data_string)
    -- data_string format: lock/cover state (1 = lock, 2 = cover, 3 = both, 0 = neither), x, y, w, h
    -- Example: "2,0,0,960,540"
    local nums = split_string(data_string, ",")
    set_instance_data(
        instance_num, --instance number
        (nums[1] == "1") or (nums[1] == "3"), -- lock visible
        (nums[1] == "2") or (nums[1] == "3"), -- cover visible
        tonumber(nums[2]), -- x
        tonumber(nums[3]), -- y
        tonumber(nums[4]), -- width
        tonumber(nums[5])) -- height
end
