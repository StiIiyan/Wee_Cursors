SMODS.Atlas({
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34
})


local CURSOR_IMAGES = {}
local ANCHOR_COORDINATES = {}
local cursor_image_amount = 9
for i=1,cursor_image_amount do
    local CURSOR_MOD_PATH = SMODS.Mods["WeeCursors"].path .. "assets/2x/cursor" .. i .. ".png"
    local CURSOR_FIXED_PATH = assert(NFS.newFileData(CURSOR_MOD_PATH),('Failed to collect file data for Atlas %s'):format('cursor'))
    CURSOR_IMAGES[i] = love.graphics.newImage(CURSOR_FIXED_PATH, { mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling })
    -- manual checks
    if i == 1 or i == 8 or i == 5 then
        ANCHOR_COORDINATES[i] = {x=10,y=0}
    elseif i == 2 then
        ANCHOR_COORDINATES[i] = {x=2,y=6}
    elseif i == 3 then
        ANCHOR_COORDINATES[i] = {x=11,y=32}
    elseif i == 4 then
        ANCHOR_COORDINATES[i] = {x=9,y=0}
    elseif i == 6 then
        ANCHOR_COORDINATES[i] = {x=15,y=0}
    elseif i == 7 then
        ANCHOR_COORDINATES[i] = {x=4,y=4}
    elseif i == 9 then
        ANCHOR_COORDINATES[i] = {x=4,y=6}
    else
        ANCHOR_COORDINATES[i] = {x=0,y=0}
    end
end
local CURSOR_HELD_IMAGES = {}
local cursor_held_image_amount = 8
for i=1,cursor_held_image_amount do
    local CURSOR_MOD_PATH = SMODS.Mods["WeeCursors"].path .. "assets/2x/cursor_held" .. i .. ".png"
    local CURSOR_FIXED_PATH = assert(NFS.newFileData(CURSOR_MOD_PATH),('Failed to collect file data for Atlas %s'):format('cursor'))
    CURSOR_HELD_IMAGES[i] = love.graphics.newImage(CURSOR_FIXED_PATH, { mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling })
end

local i1 = SMODS.Mods['WeeCursors'].config.cursor_index
local i2 = SMODS.Mods['WeeCursors'].config.held_cursor_index
local CURSOR = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() / 2,
    sensitivity = 1,
    in_game_windowed = true,

    image = CURSOR_IMAGES[i1],
    -- offsets
    ox = ANCHOR_COORDINATES[i1].x,
    oy = ANCHOR_COORDINATES[i1].y,
    image_held = CURSOR_HELD_IMAGES[i2],
    held = false,
}
local function keepCursorInBorder()
    local outside_game = false
    if CURSOR.x < 0 then
        CURSOR.x = 0
        outside_game = true
    elseif CURSOR.x > love.graphics.getWidth() then
        CURSOR.x = love.graphics.getWidth()
        outside_game = true
    end
    if CURSOR.y < 0 then
        CURSOR.y = 0
        outside_game = true
    elseif CURSOR.y > love.graphics.getHeight() then
        CURSOR.y = love.graphics.getHeight()
        outside_game = true
    end
    return outside_game
end
local function getOutsideCoordinates()
    local x,y = getCursorPosition()
    if x == 0 then x = -1
    elseif y == 0 then y = -1
    elseif y == love.graphics.getHeight() then y = love.graphics.getHeight() + 1
    elseif x == love.graphics.getWidth() then x = love.graphics.getWidth() + 1
    end
    return x,y
end

function G.FUNCS.set_m1_cursor(args)
    SMODS.Mods['WeeCursors'].config.cursor_index = args.to_key
    local i = args.to_key

    CURSOR.image = CURSOR_IMAGES[i] or CURSOR_IMAGES[1]
    CURSOR.ox = ANCHOR_COORDINATES[i] and ANCHOR_COORDINATES[i].x or ANCHOR_COORDINATES[1].x
    CURSOR.oy = ANCHOR_COORDINATES[i] and ANCHOR_COORDINATES[i].y or ANCHOR_COORDINATES[1].y
end
function G.FUNCS.set_m1_held_cursor(args)
    SMODS.Mods['WeeCursors'].config.held_cursor_index = args.to_key

    CURSOR.image_held = CURSOR_HELD_IMAGES[args.to_key] or CURSOR_HELD_IMAGES[1]
end
function G.FUNCS.reset_sensitivity()
    resetSensitivity()
end

function setSensitivity(new_sens)
    CURSOR.sensitivity = new_sens
end
function resetSensitivity()
    setSensitivity(SMODS.Mods['WeeCursors'].config.default_sensitivity)
end
function getCursorPosition()
    return CURSOR.x, CURSOR.y
end
function setCursorPosition(x,y)
    CURSOR.x = x
    CURSOR.y = y
end


SMODS.current_mod.config_tab = function()
  return {n=G.UIT.ROOT, config = {align = "cm", padding = 0.05, r = 0.1, colour = G.C.CLEAR}, nodes = {
      create_slider({label = 'Sensitivity', w = 4, h = 0.4, ref_table = SMODS.Mods['WeeCursors'].config, ref_value = 'default_sensitivity', callback = 'reset_sensitivity', min = 0.5, max = 2, decimal_places = 2, current_option = SMODS.Mods['WeeCursors'].config.default_sensitivity or 1}),
      create_option_cycle({w = 4, scale = 0.8, label = 'M1 Cursor', options = {'Four Fingers','Banner','Cloud 9','Arrowhead','Gros Michel','Bootstraps','Ceremonial Dagger','Rocket','Seltzer'}, opt_callback = 'set_m1_cursor', current_option = SMODS.Mods['WeeCursors'].config.cursor_index or 1}),
      create_toggle({label = "Held Cursor", ref_table = SMODS.Mods['WeeCursors'].config, ref_value = 'is_m1_held', current_option = SMODS.Mods['WeeCursors'].config.is_m1_held or true}),
      create_option_cycle({w = 4, scale = 0.8, label = 'Held Cursor', options = {'Fist','Bean','Egg','Oops','Bull','8 ball','Square','Delayed Grat'}, opt_callback = 'set_m1_held_cursor', current_option = SMODS.Mods['WeeCursors'].config.held_cursor_index or 1}),
  }}
end

------------------------------- LOVE FUNCTIONS
local prev_update = love.update
function love.update(dt)
    prev_update(dt)
    
    love.mouse.setVisible(false)
    if CURSOR.in_game_windowed then
        love.mouse.setRelativeMode(true)
    else
        love.mouse.setRelativeMode(false)
    end
end

local prev_draw = love.draw
function love.draw()
    prev_draw()

    if CURSOR.held == true and SMODS.Mods['WeeCursors'].config.is_m1_held then
        love.graphics.draw(
            CURSOR.image_held,
            CURSOR.x,
            CURSOR.y
        )
    else 
        love.graphics.draw(
            CURSOR.image,
            CURSOR.x - CURSOR.ox,
            CURSOR.y - CURSOR.oy
        )
    end
end

local prev_mousepressed = love.mousepressed
function love.mousepressed(x, y, button)
    local cx, cy = getCursorPosition()
    prev_mousepressed(cx, cy, button)
    if button == 1 then CURSOR.held = true end
end

local prev_mousereleased = love.mousereleased
function love.mousereleased(x, y, button)
    local cx, cy = getCursorPosition()
    prev_mousereleased(cx, cy,button)
    if button == 1 then CURSOR.held = false end
end

local prev_mousemoved = love.mousemoved
function love.mousemoved(x, y, dx, dy)
    if CURSOR.in_game_windowed then -- move only when in border
        CURSOR.x = CURSOR.x + dx * CURSOR.sensitivity
        CURSOR.y = CURSOR.y + dy * CURSOR.sensitivity
    end

    -- KEEP IN BORDER
    local outside_game = keepCursorInBorder()
    if outside_game and G.SETTINGS.WINDOW.screenmode == 'Windowed' then
        if CURSOR.in_game_windowed then
            love.mouse.setPosition(getOutsideCoordinates())
        end
        CURSOR.in_game_windowed = false
    else
        if not CURSOR.in_game_windowed then
            setCursorPosition(love.mouse.getPosition())
        end
        CURSOR.in_game_windowed = true
    end

    prev_mousemoved(x, y, dx, dy)
end