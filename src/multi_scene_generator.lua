obs = obslua

function generate_multi_scenes()
    local instance_count = 0
    ::go_again::
    local temp_source = get_source("Minecraft Capture " .. (instance_count + 1))
    if temp_source ~= nil then
        instance_count = instance_count + 1
        release_source(temp_source)
        goto go_again
    end


    if instance_count == 0 then
        obs.script_log(100, "You have not generated regular scenes yet!")
        return
    end

    remove_individual_multi_captures()

    gen_overlay_scene()

    for i = 1, instance_count, 1 do
        generate_multi_playing_scene(i)
    end
end

function gen_overlay_scene()
    local scene = get_scene("Playing Overlay")
    if (scene ~= nil) then
        return
    end
    create_scene("Playing Overlay")
    local num_over = get_source("Current Location")
    if num_over == nil then
        local settings = obs.obs_data_create_from_json(
            '{"file":"' .. julti_dir ..
            'currentlocation.txt","font":{"face":"Arial","flags":0,"size":48,"style":"Regular"},"opacity":15,"read_from_file":true}'
        )
        num_over = obs.obs_source_create("text_gdiplus", "Current Location", settings, nil)
    end
    obs.obs_scene_add(get_scene("Playing Overlay"), num_over)
    release_source(num_over)
end

function generate_multi_playing_scene(i)
    local scene = get_scene("Playing " .. i)

    if (scene == nil) then
        create_scene("Playing " .. i)
        scene = get_scene("Playing " .. i)

        local source = get_source("Sound")
        obs.obs_scene_add(scene, source)
        release_source(source)

        local source = get_source("Playing Overlay")
        obs.obs_scene_add(scene, source)
        release_source(source)
    end

    local source = get_source("Minecraft Capture " .. i)
    local si = obs.obs_scene_add(scene, source)
    bring_to_bottom(si)
    release_source(source)
end

function remove_individual_multi_captures()
    local i = 0
    local scene = nil

    ::go_again::
    i = i + 1
    scene = get_scene("Playing " .. i)

    if scene == nil then
        return
    end

    local si = obs.obs_scene_find_source(scene, "Minecraft Capture " .. i)
    if (si == nil) then
        goto go_again
    end

    obs.obs_sceneitem_remove(si)

    goto go_again
end

function regenerate_multi_scenes()
    local scene = get_scene("Playing 1")
    if scene == nil then
        return
    end
    remove_individual_multi_captures()
    generate_multi_scenes()
end
