obs = obslua

function generate_scenes()

    if not scene_exists("Lock Display") then
        _setup_lock_scene()
    else
        obs.script_log(200,
            'Warning: The lock display scene already exists, if you want it to be remade, please delete it and press the "Generate Scenes" button again.')
    end

    if not scene_exists("Dirt Cover Display") then
        _setup_cover_scene()
    else
        obs.script_log(200,
            'Warning: The dirt cover display scene already exists, if you want it to be remade, please delete it and press the "Generate Scenes" button again.')
    end

    if not scene_exists("Sound") then
        _setup_sound_scene()
    else
        obs.script_log(200,
            'Warning: The sound scene already exists, if you want it to be remade, please delete it and press the "Generate Scenes" button again.')
    end

    if not scene_exists("Verification") then
        _setup_verification_scene()
    else
        obs.script_log(200,
            'Warning: The verification scene already exists, if you want it to be remade, please delete it and press the "Generate Scenes" button again.')
    end

    _setup_julti_scene()
end

function _setup_cover_scene()
    create_scene("Dirt Cover Display")
    local scene = get_scene("Dirt Cover Display")

    local cover_data = obs.obs_data_create_from_json('{"file":"' .. julti_dir .. 'dirtcover.png' .. '"}')
    local cover_source = obs.obs_source_create("image_source", "Dirt Cover Image", cover_data, nil)
    obs.obs_scene_add(scene, cover_source)
    release_source(cover_source)
    obs.obs_data_release(cover_data)

    local item = obs.obs_scene_find_source(scene, "Dirt Cover Image")
    set_position_with_bounds(item, 0, 0, total_width, total_height)
    obs.obs_sceneitem_set_scale_filter(item, obs.OBS_SCALE_POINT)

end

function _setup_verification_scene()
    create_scene("Verification")
    local scene = get_scene("Verification")

    local out = get_state_file_string()
    if (out == nil) or not (string.find(out, ";")) then
        return
    end

    local instance_count = (#(split_string(out, ";"))) - 1

    if instance_count == 0 then
        return
    end

    if instance_count > 6 then
        obs.script_log(200, "Warning: You have a lot of instances, your verification scene may require further setup!")
    end

    local totalColumns = math.ceil(math.sqrt(instance_count))
    local totalRows = math.ceil(instance_count / totalColumns)

    local i_width = math.floor(total_width / totalColumns)
    local i_height = math.floor(total_height / totalRows)

    for instance_num = 1, instance_count, 1 do
        local instance_index = instance_num - 1
        local row = math.floor(instance_index / totalColumns)
        local col = math.floor(instance_index % totalColumns)

        local settings = obs.obs_data_create_from_json('{"priority": 1, "window": "Minecraft* - Instance ' ..
            instance_num .. ':GLFW30:javaw.exe"}')
        local source = obs.obs_source_create("window_capture", "Verification Capture " .. instance_num, settings, nil)
        local item = obs.obs_scene_add(scene, source)
        set_position_with_bounds(item, col * i_width, row * i_height, i_width, i_height)
        obs.obs_data_release(settings)
    end

    local source = get_source("Minecraft Audio")
    obs.obs_scene_add(scene, source)
    release_source(source)
end

function _setup_sound_scene()
    create_scene("Sound")
    local scene = get_scene("Sound")

    -- intuitively the scene item returned from add group would need to be released, but it does not
    if get_group_as_scene("Minecraft Audio") == nil then
        obs.obs_scene_add_group(scene, "Minecraft Audio")
    else
        local source = get_source("Minecraft Audio")
        obs.obs_scene_add(scene, source)
        release_source(source)
    end
    obs.obs_sceneitem_set_visible(obs.obs_scene_find_source(scene, "Minecraft Audio"), false)

    local desk_cap = obs.obs_source_create("wasapi_output_capture", "Desktop Audio", nil, nil)
    obs.obs_scene_add(scene, desk_cap)
    release_source(desk_cap)
end

function _setup_lock_scene()
    create_scene("Lock Display")
    local scene = get_scene("Lock Display")

    -- Example Instances Group
    -- intuitively the scene item returned from add group would need to be released, but it does not
    obs.obs_scene_add_group(scene, "Example Instances")
    local group = get_group_as_scene("Example Instances")
    obs.obs_sceneitem_set_locked(obs.obs_scene_find_source(scene, "Example Instances"), true)

    -- Blacksmith Example
    local blacksmith_data = obs.obs_data_create_from_json('{"file":"' ..
        julti_dir .. 'blacksmith_example.png' .. '"}')
    local blacksmith_source = obs.obs_source_create("image_source", "Blacksmith Example", blacksmith_data, nil)
    obs.obs_scene_add(group, blacksmith_source)
    release_source(blacksmith_source)
    obs.obs_data_release(blacksmith_data)

    -- Beach Example
    local beach_data = obs.obs_data_create_from_json('{"file":"' .. julti_dir .. 'beach_example.png' .. '"}')
    local beach_source = obs.obs_source_create("image_source", "Beach Example", beach_data, nil)
    obs.obs_scene_add(group, beach_source)
    release_source(beach_source)
    obs.obs_data_release(beach_data)

    -- Darken
    local darken_data = obs.obs_data_create_from_json('{"color": 3355443200}')
    local darken_source = obs.obs_source_create("color_source", "Darken", darken_data, nil)
    obs.obs_scene_add(scene, darken_source)
    release_source(darken_source)
    obs.obs_data_release(darken_data)
    local item = obs.obs_scene_find_source(scene, "Darken")
    obs.obs_sceneitem_set_visible(item, false)
    set_position_with_bounds(item, 0, 0, total_width, total_height)

    -- Lock image
    local lock_data = obs.obs_data_create_from_json('{"file":"' ..
        julti_dir .. 'lock.png' .. '"}')
    local lock_source = obs.obs_source_create("image_source", "Lock Image", lock_data, nil)
    obs.obs_scene_add(scene, lock_source)
    release_source(lock_source)
    obs.obs_data_release(lock_data)
    set_position_with_bounds(obs.obs_scene_find_source(scene, "Lock Image"), 20, 20, 130, 130)
end

function _setup_julti_scene()
    local out = get_state_file_string()
    if (out == nil) or not (string.find(out, ";")) then
        obs.script_log(100, "Julti has not yet been set up! Please setup Julti first!")
        return
    end

    local instance_count = (#(split_string(out, ";"))) - 1

    if instance_count == 0 then
        obs.script_log(100, "Julti has not yet been set up (No instances found)! Please setup Julti first!")
        return
    end

    if scene_exists("Julti") then
        local items = obs.obs_scene_enum_items(get_scene("Julti"))
        for _, item in ipairs(items) do
            if (string.find(get_sceneitem_name(item), "Instance ") ~= nil) or
                (string.find(get_sceneitem_name(item), "Sound") ~= nil) then
                obs.obs_sceneitem_remove(item)
            end
        end
        obs.sceneitem_list_release(items)
    else
        create_scene("Julti")
    end

    for i = 1, instance_count, 1 do
        make_minecraft_group(i, total_width, total_height)
    end

    local sound_scene_source = get_source("Sound")
    obs.obs_scene_add(get_scene("Julti"), sound_scene_source)
    release_source(sound_scene_source)

    _setup_minecraft_sounds(instance_count)

    switch_to_scene("Julti")
end

function _setup_minecraft_sounds(instance_count)
    local group = get_group_as_scene("Minecraft Audio")

    local items = obs.obs_scene_enum_items(group)
    for _, item in ipairs(items) do
        obs.obs_sceneitem_remove(item)
    end
    obs.sceneitem_list_release(items)

    for num = 1, instance_count, 1 do
        -- '{"priority": 1, "window": "Minecraft* - Instance 1:GLFW30:javaw.exe"}'
        local settings = obs.obs_data_create_from_json('{"priority": 1, "window": "Minecraft* - Instance ' ..
            num .. ':GLFW30:javaw.exe"}')
        local source = obs.obs_source_create("wasapi_process_output_capture", "Minecraft Audio " .. num, settings, nil)
        obs.obs_scene_add(group, source)
        release_source(source)
        obs.obs_data_release(settings)
    end
end

function make_minecraft_group(num, width, height)
    local scene = get_scene("Julti")

    -- intuitively the scene item returned from add group would need to be released, but it does not
    local group_si = obs.obs_scene_add_group(scene, "Instance " .. num)

    local source = get_source("Lock Display")
    local ldsi = obs.obs_scene_add(scene, source)
    obs.obs_sceneitem_group_add_item(group_si, ldsi)
    release_source(source)

    local source = get_source("Dirt Cover Display")
    obs.obs_sceneitem_group_add_item(group_si, obs.obs_scene_add(scene, source))
    release_source(source)

    local settings = obs.obs_data_create_from_json('{"capture_mode": "window","priority": 1,"window": "Minecraft* - Instance '
        .. num .. ':GLFW30:javaw.exe"}')
    local source = obs.obs_source_create("game_capture", "Minecraft Capture " .. num, settings, nil)
    obs.obs_data_release(settings)
    local mcsi = obs.obs_scene_add(scene, source)
    obs.obs_sceneitem_group_add_item(group_si, mcsi)
    set_position_with_bounds(mcsi, 0, 0, width, height)
    set_instance_data(num, false, false, 0, 0, width, height)
    release_source(source)
end
