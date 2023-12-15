obs = obslua

function script_description()
    return "<h1>Julti OBS Link</h1><p>Links OBS to Julti.</p>"
end

function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_bool(props, "win_cap_instead",
        "[Generation Option]\nUse Window Capture for Julti Scene Sources")
    obs.obs_properties_add_bool(props, "reuse_for_verification",
        "[Generation Option]\nReuse Julti Scene Sources for Verification Scene\n(Better for source record or window cap)")

    obs.obs_properties_add_button(
        props, "generate_scenes_button", "Generate Scenes", request_generate_scenes)
    obs.obs_properties_add_button(
        props, "generate_stream_scenes_button", "Generate Stream Scenes", request_generate_stream_scenes)
    obs.obs_properties_add_button(
        props, "generate_multi_scenes_button", "Generate Multi Scenes (1 scene per instance)", generate_multi_scenes)

    -- Moved into Julti options
    -- obs.obs_properties_add_bool(props, "invisible_dirt_covers", "Invisible Dirt Covers")
    -- obs.obs_properties_add_bool(props, "center_align_instances",
    --     "Align Active Instance to Center\n(for EyeZoom/stretched window users)")

    return props
end

function script_load(settings)
    local video_info = get_video_info()
    total_width = video_info.base_width
    total_height = video_info.base_height

    pcall(write_file, julti_dir .. "obsscenesize", total_width .. "," .. total_height)

    switch_to_scene("Julti")
end

function script_update(settings)
    win_cap_instead = obs.obs_data_get_bool(settings, "win_cap_instead")
    reuse_for_verification = obs.obs_data_get_bool(settings, "reuse_for_verification")
    center_align_instances = obs.obs_data_get_bool(settings, "center_align_instances")
    invisible_dirt_covers = obs.obs_data_get_bool(settings, "invisible_dirt_covers")

    if timers_activated then
        return
    end
    timers_activated = true
    obs.timer_add(loop, 20)
end

function loop()
    -- Check Gen Requests
    if gen_scenes_requested then
        gen_scenes_requested = false
        generate_scenes()
    end
    if gen_stream_scenes_requested then
        gen_stream_scenes_requested = false
        generate_stream_scenes()
    end

    -- Scene Change Check

    local current_scene_source = obs.obs_frontend_get_current_scene()
    local current_scene_name = obs.obs_source_get_name(current_scene_source)
    release_source(current_scene_source)
    if last_scene_name ~= current_scene_name then
        on_scene_change(last_scene_name, current_scene_name)
        last_scene_name = current_scene_name
    end

    -- Check doing stuff too early
    if current_scene_name == nil then
        return
    end

    -- Check on Julti scene before continuing

    local is_on_a_julti_scene = (current_scene_name == "Julti") or (current_scene_name == "Lock Display") or
        (current_scene_name == "Dirt Cover Display") or (current_scene_name == "Walling") or
        (current_scene_name == "Playing") or (string.find(current_scene_name, "Playing ") ~= nil)

    if not is_on_a_julti_scene then
        return
    end

    -- Ensure hidden lock example

    if current_scene_name ~= "Lock Display" then
        hide_example_instances()
    end

    -- Get state output

    local out = get_state_file_string()
    if out ~= nil and last_state_text ~= out then
        last_state_text = out
    else
        return
    end

    -- Process state data

    local data_strings = split_string(out, ";")
    local instance_count = (#data_strings) - 2
    local user_location = nil
    local global_options_unset = true
    local instance_num = 0
    for k, data_string in pairs(data_strings) do
        if user_location == nil then
            -- Should take first item from data_strings
            user_location = data_string
            -- Prevent wall updates if switching to a single instance scene to allow transitions to work
            if user_location ~= "W" and switch_to_scene("Playing " .. user_location) then
                return
            end
        elseif global_options_unset then
            -- Should take second item from data_strings
            global_options_unset = false
            set_globals_from_state(data_string)
        else
            instance_num = instance_num + 1
            set_instance_data_from_string(instance_num, data_string)
        end
    end

    disable_all_indicators()

    if user_location == "W" then
        bring_to_top(obs.obs_scene_find_source(get_scene("Julti"), "Wall On Top"))
        if show_indicators then enable_indicators(instance_count) end
        if (scene_exists("Walling")) then
            switch_to_scene("Walling")
        else
            switch_to_scene("Julti")
        end
    else
        if (scene_exists("Playing")) then
            switch_to_scene("Playing")
        else
            switch_to_scene("Julti")
        end
    end

    if user_location ~= "W" then
        local scene = get_scene("Julti")
        if show_indicators then enable_indicator(user_location) end
        bring_to_top(obs.obs_scene_find_source(scene, "Instance " .. user_location))
        set_instance_data(tonumber(user_location), false, false, false, 0, 0, total_width, total_height,
            center_align_instances)

        -- hide bordering instances
        if not center_align_instances then
            return
        end
        for k, data_string in pairs(data_strings) do
            if k == tonumber(user_location) then
                goto continue
            end
            teleport_off_canvas(k)
            ::continue::
        end
    end
end

function set_globals_from_state(options_section)
    local args = split_string(data_string, ",")
    set_globals_from_bits(tonumber(args[1]))
    center_align_scale_x = tonumber(args[2]) or 1.0
    center_align_scale_y = tonumber(args[3]) or 1.0
end

function set_globals_from_bits(flag_int)
    show_indicators = flag_int >= 4
    if show_indicators then
        flag_int = flag_int - 4
    end
    center_align_instances = flag_int >= 2
    if center_align_instances then
        flag_int = flag_int - 2
    end
    invisible_dirt_covers = flag_int >= 1
    if invisible_dirt_covers then
        flag_int = flag_int - 1
    end
end

function on_scene_change(last_scene_name, new_scene_name)
    if new_scene_name == "Lock Display" then
        local state = get_state_file_string()
        if state == nil then
            return
        end
        local data_strings = split_string(state, ";")
        if #data_strings == 1 then
            return
        end
        local nums = split_string(data_strings[3], ",")

        local scene = get_scene("Lock Display")
        local item = obs.obs_scene_find_source(scene, "Example Instances")
        obs.obs_sceneitem_set_visible(item, true)
        set_position_with_bounds(item, 0, 0, tonumber(nums[4]), tonumber(nums[5]))
    elseif last_scene_name == "Lock Display" then
        hide_example_instances()
    end
end

function hide_example_instances()
    local scene = get_scene("Lock Display")
    local item = obs.obs_scene_find_source(scene, "Example Instances")
    obs.obs_sceneitem_set_visible(item, false)
end
