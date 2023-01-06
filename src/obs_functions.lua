obs = obslua

function get_scene(name)
    local source = get_source(name)
    if source == nil then
        return nil
    end
    local scene = obs.obs_scene_from_source(source)
    release_source(source)
    return scene
end

function get_group_as_scene(name)
    local source = get_source(name)
    if source == nil then
        return nil
    end
    local scene = obs.obs_group_from_source(source)
    release_source(source)
    return scene
end

function remove_source_or_scene(name)
    local source = get_source(name)
    obs.obs_source_remove(source)
    release_source(source)
end

--- Requires release after use
function get_source(name)
    return obs.obs_get_source_by_name(name)
end

function release_source(source)
    obs.obs_source_release(source)
end

function release_scene(scene)
    obs.obs_scene_release(scene)
end

function scene_exists(name)
    return get_scene(name) ~= nil
end

function create_scene(name)
    release_scene(obs.obs_scene_create(name))
end

function switch_to_scene(scene_name)
    local scene_source = get_source(scene_name)
    if (scene_source == nil) then return end
    obs.obs_frontend_set_current_scene(scene_source)
    release_source(scene_source)
end

function get_video_info()
    local video_info = obs.obs_video_info()
    obs.obs_get_video_info(video_info)
    return video_info
end

function set_position_with_bounds(scene_item, x, y, width, height)
    local bounds = obs.vec2()
    bounds.x = width
    bounds.y = height
    obs.obs_sceneitem_set_bounds_type(scene_item, obs.OBS_BOUNDS_STRETCH)
    set_position(scene_item, x, y)
    obs.obs_sceneitem_set_bounds(scene_item, bounds)
end

function set_position(scene_item, x, y)
    local pos = obs.vec2()
    pos.x = x
    pos.y = y
    obs.obs_sceneitem_set_pos(scene_item, pos)
end

function set_crop(scene_item, left, top, right, bottom)
    local crop = obs.obs_sceneitem_crop()
    crop.left = left
    crop.top = top
    crop.right = right
    crop.bottom = bottom
    obs.obs_sceneitem_set_crop(scene_item, crop)
end

function get_sceneitem_name(sceneitem)
    return obs.obs_source_get_name(obs.obs_sceneitem_get_source(sceneitem))
end

function bring_to_top(item)
    obs.obs_sceneitem_set_order(item, obs.OBS_ORDER_MOVE_TOP)
end

function bring_to_bottom(item)
    obs.obs_sceneitem_set_order(item, obs.OBS_ORDER_MOVE_BOTTOM)
end
