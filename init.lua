-- ==== VARS ====
local waywall = require("waywall")

-- local cfg     = {
--     fast_reset = "MB5",
--     main_reset = "F6",
--     thin_res = { w = 350, h = 1440 },
--     text = {
--         enabled = true,
--         text = "FAST RESET MODE",
--         x = 10,
--         y = 10,
--         size = 5,
--         color = "#F5793A"
--     }
-- }

local M       = {}
-- ==== PLUG ====
M.setup       = function(config, cfg)
    local text_obj = nil

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
            waywall.set_resolution(0, 0)
            reset_mode()
            if cfg.text.enabled then
                if text_obj then
                    text_obj:close()
                    text_obj = nil
                end
                text_obj = waywall.text(cfg.text.text, {
                    x = cfg.text.x,
                    y = cfg.text.y,
                    color = cfg.text.color,
                    size = cfg.text.size,
                })
            end
        end
    end)

    waywall.listen("resolution", function()
        local act_width, act_height = waywall.active_res()
        if act_width == cfg.thin_res.w and act_height == cfg.thin_res.h and reset_enabled then
            if text_obj then
                text_obj:close()
                text_obj = nil
            end
            normal_mode()
        end
    end)
end

return M
