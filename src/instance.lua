obs = obslua

function teleport_off_canvas(num)
    local scene = get_scene("Julti")
    local item = obs.obs_scene_find_source(scene, "Instance " .. num)
    set_position(item, total_width + 1000, 0)
end

function set_instance_data(num, lock_visible, dirt_cover, freeze_active, x, y, width, height, center_align)
    center_align = center_align or false

    local group = get_group_as_scene("Instance " .. num)

    if invisible_dirt_covers and dirt_cover then
        teleport_off_canvas(num)
        return
    end

    -- Lock Display: visibility, position and crop
    local item = obs.obs_scene_find_source(group, "Lock Display")
    obs.obs_sceneitem_set_visible(item, lock_visible)
    set_position(item, 0, 0)
    set_crop(item, 0, 0, total_width - width, total_height - height)

    -- Dirt Cover: visibility and bounds
    local item = obs.obs_scene_find_source(group, "Dirt Cover Display")
    obs.obs_sceneitem_set_visible(item, dirt_cover)
    set_position_with_bounds(item, 0, 0, width, height, center_align)

    -- Minecraft capture: position, bounds
    local item = obs.obs_scene_find_source(group, "Minecraft Capture " .. num)
    set_position_with_bounds(item, 0, 0, width, height, center_align)

    -- Freeze filter activation for minecraft capture
    local source = obs.obs_sceneitem_get_source(item)
    local filter = obs.obs_source_get_filter_by_name(source, "Freeze filter")
    if filter == nil then
        local settings = obs.obs_data_create()
        filter = obs.obs_source_create_private("freeze_filter", "Freeze filter", settings)
        obs.obs_source_filter_add(source, filter)
    end
    if not (filter == nil) then
        obs.obs_source_set_enabled(filter, freeze_active)
    end

    -- Instance Group: position
    local scene = get_scene("Julti")
    local item = obs.obs_scene_find_source(scene, "Instance " .. num)
    set_position(item, x, y)
end

function set_instance_data_from_string(instance_num, data_string)
    -- data_string format: lock/cover state (flag bits: locked, dirt cover, freeze filter), x, y, w, h
    -- Example: "2,0,0,960,540"
    local nums = split_string(data_string, ",")

    local flagBits = tonumber(nums[1])

    local freezeActive = flagBits >= 4
    if freezeActive then
        flagBits = flagBits - 4
    end

    local coverVisible = flagBits >= 2
    if coverVisible then
        flagBits = flagBits - 2
    end

    local lockVisible = flagBits >= 1
    if lockVisible then
        flagBits = flagBits - 1
    end

    set_instance_data(
        instance_num,      -- instance number
        lockVisible,       -- lock visible
        coverVisible,      -- cover visible
        freezeActive,      -- freeze filter active
        tonumber(nums[2]), -- x
        tonumber(nums[3]), -- y
        tonumber(nums[4]), -- width
        tonumber(nums[5])  -- height
    )
end
