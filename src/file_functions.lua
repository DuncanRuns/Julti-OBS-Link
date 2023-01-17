function read_first_line(filename)
    local rfile = io.open(filename, "r")
    if rfile == nil then
        return ""
    end
    io.input(rfile)
    local out = io.read()
    io.close(rfile)
    return out
end

function write_file(filename, string)
    local wfile = io.open(filename, "w")
    io.output(wfile)
    io.write(string)
    io.close(wfile)
end

function get_state_file_string()
    local success, result = pcall(read_first_line, julti_dir .. "state")
    if success then
        return result
    end
    return nil
end

function get_square_crop_string()
    local success, result = pcall(read_first_line, julti_dir .. "loadingsquarecrop")
    if success then
        return result
    end
    return nil
end
