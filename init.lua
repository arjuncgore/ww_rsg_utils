-- ==== VARS ====
local waywall = require("waywall")
--
-- local cfg = {
--     fast_reset = "MB5",
--     main_reset = "F6",
--     thin_res = {w = 350, h = 1100}
-- }

local M       = {}
-- ==== PLUG ====
M.setup       = function(config, cfg)
    local remaps_normal = {}
    local remaps_fast = {}
    for key, val in pairs(config.input.remaps) do
        remaps_normal[key] = val
        remaps_fast[key] = val
    end
    remaps_fast[cfg.fast_reset] = cfg.main_reset
    local reset_enabled = false

    local reset_mode = function()
        waywall.set_remaps(remaps_fast)
        reset_enabled = true
    end
    local normal_mode = function()
        waywall.set_remaps(remaps_normal)
        reset_enabled = false
    end


    waywall.listen("state", function()
        local state = waywall.state()
        if state.screen == "generating" or state.screen == "wall" and not reset_enabled then
            reset_mode()
        end
    end)

    waywall.listen("resolution", function()
        local act_width, act_height = waywall.active_res()
        if act_width == cfg.thin_res.w and act_height == cfg.thin_res.h and reset_enabled then
            normal_mode()
        end
    end)
end

return M
