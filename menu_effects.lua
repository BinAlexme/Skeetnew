local client_latency, client_log, client_draw_rectangle, client_draw_circle_outline, client_userid_to_entindex, client_draw_indicator, client_draw_gradient, client_set_event_callback, client_screen_size, client_eye_position = client.latency, client.log, client.draw_rectangle, client.draw_circle_outline, client.userid_to_entindex, client.draw_indicator, client.draw_gradient, client.set_event_callback, client.screen_size, client.eye_position 
local client_draw_circle, client_color_log, client_delay_call, client_draw_text, client_visible, client_exec, client_trace_line, client_set_cvar = client.draw_circle, client.color_log, client.delay_call, client.draw_text, client.visible, client.exec, client.trace_line, client.set_cvar 
local client_world_to_screen, client_draw_hitboxes, client_get_cvar, client_draw_line, client_camera_angles, client_draw_debug_text, client_random_int, client_random_float = client.world_to_screen, client.draw_hitboxes, client.get_cvar, client.draw_line, client.camera_angles, client.draw_debug_text, client.random_int, client.random_float 
local entity_get_local_player, entity_is_enemy, entity_get_player_name, entity_get_steam64, entity_get_bounding_box, entity_get_all, entity_set_prop, entity_get_player_weapon = entity.get_local_player, entity.is_enemy, entity.get_player_name, entity.get_steam64, entity.get_bounding_box, entity.get_all, entity.set_prop, entity.get_player_weapon 
local entity_hitbox_position, entity_get_prop, entity_get_players, entity_get_classname = entity.hitbox_position, entity.get_prop, entity.get_players, entity.get_classname 
local globals_realtime, globals_absoluteframetime, globals_tickcount, globals_curtime, globals_mapname, globals_tickinterval, globals_framecount, globals_frametime, globals_maxplayers = globals.realtime, globals.absoluteframetime, globals.tickcount, globals.curtime, globals.mapname, globals.tickinterval, globals.framecount, globals.frametime, globals.maxplayers 
local ui_new_slider, ui_new_combobox, ui_reference, ui_set_visible, ui_is_menu_open, ui_new_color_picker, ui_set_callback, ui_set, ui_new_checkbox, ui_new_hotkey, ui_new_button, ui_new_multiselect, ui_get = ui.new_slider, ui.new_combobox, ui.reference, ui.set_visible, ui.is_menu_open, ui.new_color_picker, ui.set_callback, ui.set, ui.new_checkbox, ui.new_hotkey, ui.new_button, ui.new_multiselect, ui.get 
local math_ceil, math_tan, math_log10, math_randomseed, math_cos, math_sinh, math_random, math_huge, math_pi, math_max, math_atan2, math_ldexp, math_floor, math_sqrt, math_deg, math_atan, math_fmod = math.ceil, math.tan, math.log10, math.randomseed, math.cos, math.sinh, math.random, math.huge, math.pi, math.max, math.atan2, math.ldexp, math.floor, math.sqrt, math.deg, math.atan, math.fmod 
local math_acos, math_pow, math_abs, math_min, math_sin, math_frexp, math_log, math_tanh, math_exp, math_modf, math_cosh, math_asin, math_rad = math.acos, math.pow, math.abs, math.min, math.sin, math.frexp, math.log, math.tanh, math.exp, math.modf, math.cosh, math.asin, math.rad 
local table_maxn, table_foreach, table_sort, table_remove, table_foreachi, table_move, table_getn, table_concat, table_insert = table.maxn, table.foreach, table.sort, table.remove, table.foreachi, table.move, table.getn, table.concat, table.insert 
local string_find, string_format, string_rep, string_gsub, string_len, string_gmatch, string_dump, string_match, string_reverse, string_byte, string_char, string_upper, string_lower, string_sub = string.find, string.format, string.rep, string.gsub, string.len, string.gmatch, string.dump, string.match, string.reverse, string.byte, string.char, string.upper, string.lower, string.sub 

local function distance(x1, y1, x2, y2)
	return math_sqrt((x2-x1)^2 + (y2-y1)^2)
end

local function hsv_to_rgb(h, s, v, a)
  local r, g, b

  local i = math_floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return r * 255, g * 255, b * 255, a * 255
end

local function contains(table, val)
	for i=1,#table do
		if table[i] == val then 
			return true
		end
	end
	return false
end

local menu_hotkey_reference = ui.reference("MISC", "Settings", "Menu key")
local menu_color_reference = ui.reference("MISC", "Settings", "Menu color")

local effects_reference = ui.new_multiselect("MISC", "Settings", "Menu effects", {"Lines", "Gradient", "Dots", "Text"})

local lines_distance_reference = ui.new_slider("MISC", "Settings", "Line distance", 4, 100, 15, true, "px")
local lines_color_reference = ui.new_color_picker("MISC", "Settings", "Line color", 100, 100, 100, 20)
local lines_speed_reference = ui.new_slider("MISC", "Settings", "Line speed", 1, 30, 5)

local gradient_distance_reference = ui.new_slider("MISC", "Settings", "Gradient distance", 1, 2048, 1400, true, "px")
local gradient_color_reference = ui.new_color_picker("MISC", "Settings", "Gradient color", 16, 16, 16, 210)

local dots_speed_reference = ui.new_slider("MISC", "Settings", "Dots speed", 1, 100, 20, true, "%")
local dots_color_reference = ui.new_color_picker("MISC", "Settings", "Dots color", 255, 255, 255, 150)
local dots_amount_reference = ui.new_slider("MISC", "Settings", "Dots amount", 1, 300, 80)
local dots_connet_distance_reference = ui.new_slider("MISC", "Settings", "Dots connect distance", 1, 500, 180, true, "px")
local dots_connect_color_reference = ui.new_color_picker("MISC", "Settings", "Dots connect color", 255, 255, 255, 50)

local function on_effects_change()
	local effects = ui_get(effects_reference)
	ui_set_visible(lines_distance_reference, contains(effects, "Lines"))
	ui_set_visible(lines_color_reference, contains(effects, "Lines"))
	ui_set_visible(lines_speed_reference, contains(effects, "Lines"))
	
	ui_set_visible(gradient_distance_reference, contains(effects, "Gradient"))
	ui_set_visible(gradient_color_reference, contains(effects, "Gradient"))
	
	ui_set_visible(dots_speed_reference, contains(effects, "Dots"))
	ui_set_visible(dots_color_reference, contains(effects, "Dots"))
	ui_set_visible(dots_amount_reference, contains(effects, "Dots"))
	ui_set_visible(dots_connet_distance_reference, contains(effects, "Dots"))
	ui_set_visible(dots_connect_color_reference, contains(effects, "Dots"))
end
on_effects_change()
ui_set_callback(effects_reference, on_effects_change)

local key_last_press = 0

local key_pressed_prev = false
local last_change = globals_realtime()-1

local x_dir, y_dir = "+", "+"
local x, y = 0, 0
local flags = "b"
local additional = 2
local tr, tg, tb = 149, 213, 72

local rainbow_progress = 0
local lines_progress = 0
local menu_open_prev = true

local dots = {}
local dot_size = 3
local function on_paint(ctx)
	local menu_open = ui_is_menu_open()
	local realtime = globals_realtime()
	if menu_open and not menu_open_prev then
		last_change = realtime
	end
	menu_open_prev = menu_open

	if not menu_open then
		return
	end

	local key_pressed = ui_get(menu_hotkey_reference)
	if key_pressed and not key_pressed_prev then
		key_last_press = realtime
	end
	key_pressed_prev = key_pressed

	local opacity_multiplier = menu_open and 1 or 0

	local menu_fade_time = 0.2

	if realtime - last_change < menu_fade_time then
		opacity_multiplier = (realtime - last_change) / menu_fade_time
	elseif realtime - key_last_press < menu_fade_time then
		opacity_multiplier = (realtime - key_last_press) / menu_fade_time
		opacity_multiplier = 1 - opacity_multiplier
	end

	if opacity_multiplier ~= 1 then
		--client.log(opacity_multiplier)
	end

	--draw effects
	if opacity_multiplier > 0 then
		local effects = ui_get(effects_reference)
		if #effects > 0 then
			local screen_width, screen_height = client_screen_size()

			--draw gradient
			if contains(effects, "Gradient") then
				local gradient_r, gradient_g, gradient_b, gradient_a = ui_get(gradient_color_reference)
				local gradient_thickness = ui_get(gradient_distance_reference)
				gradient_a = gradient_a * opacity_multiplier
				client_draw_gradient(ctx, 0, screen_height - gradient_thickness, screen_width, gradient_thickness, 0, 0, 0, 0, gradient_r, gradient_g, gradient_b, gradient_a, false) -- bottom gradient
				client_draw_gradient(ctx, screen_width - gradient_thickness, 0, gradient_thickness, screen_height, 0, 0, 0, 0, gradient_r, gradient_g, gradient_b, gradient_a, true)  -- right gradient
				client_draw_gradient(ctx, 0, 0, screen_width, gradient_thickness, gradient_r, gradient_g, gradient_b, gradient_a, 0, 0, 0, 0, false) 		 -- top gradient
				client_draw_gradient(ctx, 0, 0, gradient_thickness, screen_height, gradient_r, gradient_g, gradient_b, gradient_a, 0, 0, 0, 0, true) 
			end

			--draw lines
			if contains(effects, "Lines") then
				local r, g, b, a = ui_get(lines_color_reference)
				a = a * opacity_multiplier
				for i=1, screen_width*1.6, ui_get(lines_distance_reference) do
					local i = i + lines_progress*ui_get(lines_distance_reference)
					client_draw_line(ctx, i, 0, i-screen_height, screen_height, r, g, b, a)
				end
				lines_progress = lines_progress + 0.1*ui_get(lines_speed_reference)/80
				if lines_progress > 1 then
					lines_progress = 0
				end
			end

			--draw retarded text effect
			if contains(effects, "Text") then
				local x_max, y_max = screen_width-80, screen_height-20

				local change_dir = false

				if x_dir == "+" and x >= x_max then
					x_dir = "-"
					change_dir = true
				elseif x_dir == "-" and 0 >= x then
					x_dir = "+"
					change_dir = true
				end

				if y_dir == "+" and y >= y_max then
					y_dir = "-"
					change_dir = true
				elseif y_dir == "-" and 0 >= y then
					y_dir = "+"
					change_dir = true
				end

				if x_dir == "+" then
					x = x + additional
				else
					x = x - additional
				end

				if y_dir == "+" then
					y = y + additional
				else
					y = y - additional
				end

				if change_dir then
					rainbow_progress = rainbow_progress + 0.2
					if rainbow_progress == 1.2 then
						rainbow_progress = 0
					end
					tr, tg, tb = hsv_to_rgb(rainbow_progress, 1, 1, 255)
				end

				client_draw_text(ctx, x+1, y, 0, 0, 0, 100 * opacity_multiplier, flags, 0, "gamesense.pub")
				client_draw_text(ctx, x-1, y, 0, 0, 0, 100 * opacity_multiplier, flags, 0, "gamesense.pub")
				client_draw_text(ctx, x, y+1, 0, 0, 0, 100 * opacity_multiplier, flags, 0, "gamesense.pub")
				client_draw_text(ctx, x, y-1, 0, 0, 0, 100 * opacity_multiplier, flags, 0, "gamesense.pub")

				client_draw_text(ctx, x, y, tr, tg, tb, 255 * opacity_multiplier, flags, 0, "gamesense.pub")

				local x_additional = 0
				local w = 75
				for i=1, w do
					local r, g, b = hsv_to_rgb(i/w - (x/x_max)*5, 1, 1, 255)
					client_draw_rectangle(ctx, x+i, y+14, 1, 2, r, g, b, 255 * opacity_multiplier)
				end
			end

			--draw dots
			if contains(effects, "Dots") then
				local r, g, b, a = ui_get(dots_color_reference)
				a = a * opacity_multiplier
				local r_connect, g_connect, b_connect, a_connect = ui_get(dots_connect_color_reference)
				a_connect = a_connect * opacity_multiplier * 0.5
				local speed_multiplier = ui_get(dots_speed_reference) / 100
				local dots_amount = ui_get(dots_amount_reference)
				local dots_connect_distance = ui_get(dots_connet_distance_reference)
				local line_a = a/4
				while #dots > dots_amount do
					table_remove(dots, #dots)
				end
				while #dots < dots_amount do
					local x, y = client_random_int(-dots_connect_distance, screen_width+dots_connect_distance), client_random_int(-dots_connect_distance, screen_height+dots_connect_distance)
					local max = 12
					local min = 4

					local velocity_x
					if client_random_int(0, 1) == 1 then
						velocity_x = client_random_float(-max, -min)
					else
						velocity_x = client_random_float(min, max)
					end

					local velocity_y
					if client_random_int(0, 1) == 1 then
						velocity_y = client_random_float(-max, -min)
					else
						velocity_y = client_random_float(min, max)
					end

					local size = client_random_float(dot_size-1, dot_size+1)
					table_insert(dots, {x, y, velocity_x, velocity_y, size})
				end

				local dots_new = {}
				for i=1, #dots do
					local dot = dots[i]
					local x, y, velocity_x, velocity_y, size = dot[1], dot[2], dot[3], dot[4], dot[5]
					x = x + velocity_x*speed_multiplier*0.2
					y = y + velocity_y*speed_multiplier*0.2
					if x > -dots_connect_distance and x < screen_width+dots_connect_distance and y > -dots_connect_distance and y < screen_height+dots_connect_distance then
						table_insert(dots_new, {x, y, velocity_x, velocity_y, size})
					end
				end
				dots = dots_new

				for i=1, #dots do
					local dot = dots[i]
					local x, y, velocity_x, velocity_y, size = dot[1], dot[2], dot[3], dot[4], dot[5]
					for i2=1, #dots do
						local dot2 = dots[i2]
						local x2, y2 = dot2[1], dot2[2]
						local distance = distance(x, y, x2, y2)
						if distance <= dots_connect_distance then
							local a_connect_multiplier = 1
							if distance > dots_connect_distance * 0.7 then
								a_connect_multiplier = (dots_connect_distance - distance) / (dots_connect_distance * 0.3)
								--distance - dots_connect_distance / 
							end
							client_draw_line(ctx, x, y, x2, y2, r_connect, g_connect, b_connect, a_connect*a_connect_multiplier)
						end
					end
				end

				for i=1, #dots do
					local dot = dots[i]
					local x, y, velocity_x, velocity_y, size = dot[1], dot[2], dot[3], dot[4], dot[5]
					client_draw_circle(ctx, x, y, r, g, b, a, size, 0, 1, 1)
				end
			end

		end
	end
end

client_set_event_callback("paint", on_paint)
