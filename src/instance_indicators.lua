function disable_all_indicators()
    num = 0
    while true do
        num = num + 1
        local group = get_group_as_scene("Instance " .. num)
        if group == nil then
            return
        end
        local si = obs.obs_scene_find_source(group, "Instance " .. num .. " Indicator")
        if si ~= nil then
            obs.obs_sceneitem_set_visible(si, false)
        end
    end
end

function enable_indicators(instance_count)
    for num = 1, instance_count, 1 do
        local group = get_group_as_scene("Instance " .. num)
        if group == nil then
            return
        end
        local si = obs.obs_scene_find_source(group, "Instance " .. num .. " Indicator")
        if si ~= nil then
            obs.obs_sceneitem_set_visible(si, true)
        end
        set_position(si, 5, 0)
    end
end

function enable_indicator(num)
    local group = get_group_as_scene("Instance " .. num)
    if group == nil then
        return
    end
    local si = obs.obs_scene_find_source(group, "Instance " .. num .. " Indicator")
    if si ~= nil then
        obs.obs_sceneitem_set_visible(si, true)
    end
    set_position(si, 5, 0)
end
