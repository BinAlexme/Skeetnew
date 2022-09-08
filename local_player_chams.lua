local client_latency, client_log, client_draw_rectangle, client_draw_circle_outline, client_userid_to_entindex, client_draw_gradient, client_set_event_callback, client_screen_size, client_draw_text, client_visible = client.latency, client.log, client.draw_rectangle, client.draw_circle_outline, client.userid_to_entindex, client.draw_gradient, client.set_event_callback, client.screen_size, client.draw_text, client.visible 
local client_visible, client_exec, client_draw_circle, client_delay_call, client_world_to_screen, client_draw_hitboxes, client_get_cvar, client_draw_line, client_camera_angles, client_draw_debug_text, client_random_int, client_random_float = client.visible, client.exec, client.draw_circle, client.delay_call, client.world_to_screen, client.draw_hitboxes, client.get_cvar, client.draw_line, client.camera_angles, client.draw_debug_text, client.random_int, client.random_float 
local entity_get_local_player, entity_is_enemy, entity_get_player_name, entity_get_all, entity_set_prop, entity_get_player_weapon, entity_hitbox_position, entity_get_prop, entity_get_players, entity_get_classname = entity.get_local_player, entity.is_enemy, entity.get_player_name, entity.get_all, entity.set_prop, entity.get_player_weapon, entity.hitbox_position, entity.get_prop, entity.get_players, entity.get_classname 
local globals_mapname, globals_tickcount, globals_realtime, globals_absoluteframetime, globals_tickinterval, globals_curtime, globals_frametime, globals_maxplayers = globals.mapname, globals.tickcount, globals.realtime, globals.absoluteframetime, globals.tickinterval, globals.curtime, globals.frametime, globals.maxplayers 
local ui_new_slider, ui_new_combobox, ui_reference, ui_set_visible, ui_new_color_picker, ui_set_callback, ui_set, ui_new_checkbox, ui_new_hotkey, ui_new_button, ui_new_multiselect, ui_get = ui.new_slider, ui.new_combobox, ui.reference, ui.set_visible, ui.new_color_picker, ui.set_callback, ui.set, ui.new_checkbox, ui.new_hotkey, ui.new_button, ui.new_multiselect, ui.get 
local math_ceil, math_tan, math_correctRadians, math_fact, math_log10, math_randomseed, math_cos, math_sinh, math_random, math_huge, math_pi, math_max, math_atan2, math_ldexp, math_floor, math_sqrt = math.ceil, math.tan, math.correctRadians, math.fact, math.log10, math.randomseed, math.cos, math.sinh, math.random, math.huge, math.pi, math.max, math.atan2, math.ldexp, math.floor, math.sqrt 
local math_sqrt, math_deg, math_atan, math_fmod, math_acos, math_pow, math_abs, math_min, math_sin, math_frexp, math_log, math_tanh, math_exp, math_modf, math_cosh, math_asin, math_rad = math.sqrt, math.deg, math.atan, math.fmod, math.acos, math.pow, math.abs, math.min, math.sin, math.frexp, math.log, math.tanh, math.exp, math.modf, math.cosh, math.asin, math.rad 
local table_maxn, table_foreach, table_sort, table_remove, table_foreachi, table_move, table_getn, table_concat, table_insert = table.maxn, table.foreach, table.sort, table.remove, table.foreachi, table.move, table.getn, table.concat, table.insert 

local enabled_reference = ui_new_checkbox("VISUALS", "Colored models", "Local player")
local color_reference = ui_new_color_picker("VISUALS", "Colored models", "Local player color", 255, 5, 135, 255)
local teammate_chams_reference, teammate_chams_color_reference = ui_reference("VISUALS", "Colored models", "Show teammates")

function rgb_to_archex(r, g, b)
	return string.format('0x%.2X%.2X%.2X', b, g, r)
end

local function set_local_player_color(r, g, b, a)
	local player = entity_get_local_player()
	if player ~= nil then
		local a = a / 255
		entity_set_prop(player, "m_clrRender", rgb_to_archex(r*a, g*a, b*a))
	end
end

local function on_paint(ctx)
	if ui_get(enabled_reference) then
		local teammate_chams_enabled = ui_get(teammate_chams_reference)
		local r, g, b, a = 255, 255, 255, 255
		if teammate_chams_enabled then
			r, g, b = ui_get(teammate_chams_color_reference)
		else
			r, g, b, a = ui_get(color_reference)
		end
		set_local_player_color(r, g, b, a)
		ui_set_visible(color_reference, not teammate_chams_enabled)
	end
end

local function on_enabled_changed()
	if not ui_get(enabled_reference) then
		set_local_player_color(255, 255, 255, 255)
		ui_set_visible(color_reference, true)
	end
end

ui_set_callback(enabled_reference, on_enabled_changed)
client_set_event_callback("paint", on_paint)
