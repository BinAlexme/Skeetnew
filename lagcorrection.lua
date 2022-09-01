local interface = {
	get = ui.get,
	set = ui.set,
	ref = ui.reference,
	callback = ui.set_callback,
	checkbox = ui.new_checkbox,
	visible = ui.set_visible,
	slider = ui.new_slider,
	multiselect = ui.new_multiselect
}

local ent = {
	get_local = entity.get_local_player,
	get_prop = entity.get_prop,
	get_all = entity.get_all
}

local cl = {
	indicator = client.draw_indicator,
	circle_outline = client.draw_circle_outline,

	draw = client.draw_text,
	size = client.screen_size,
	exec = client.exec,
	ute = client.userid_to_entindex,
	latency = client.latency,
	tickcount = globals.tickcount,
	curtime = globals.curtime,
	realtime = globals.realtime
}

local colors = {
	{ 124, 195, 13 },
	{ 176, 205, 10 },
	{ 213, 201, 19 },
	{ 220, 169, 16 },
	{ 228, 126, 10 },
	{ 229, 104, 8 },
	{ 235, 63, 6 },
	{ 237, 27, 3 },
	{ 255, 0, 0 }
}

-- Some functions

local function inArr(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local function getlatency()
	local prop = ent.get_all("CCSPlayerResource")[1]
	local latency_client = ent.get_prop(prop, string.format("%03d", ent.get_local()))
	local latency_server = math.floor(math.min(1000, cl.latency() * 1000) + 0.5)

	latency_client = (latency_client > 999 and 999 or latency_client)

	local latency_decl = latency_client - latency_server - 5
	if latency_decl < 1 then latency_decl = 1 end

	return latency_client, latency_server, latency_decl
end

local function setMath(int, max, declspec)
	local int = (int > max and max or int)

	local tmp = max / int;
	local i = (declspec / tmp)
	i = (i >= 0 and math.floor(i + 0.5) or math.ceil(i - 0.5))

	return i
end

local function getColor(number, max, inverse)
	local i = setMath(number, max, 9)
	if inverse == true then
		i = 9 - i
	end

	if i < 1 then i = 1 end

	return colors[i][1], colors[i][2], colors[i][3]
end

local function draw_indicator_circle(c, x, y, r, g, b, a, percentage, outline)
    local outline = outline or true
    local radius, start_degrees = 9, 0

	if outline then 
		cl.circle_outline(c, x, y, 0, 0, 0, 200, radius, start_degrees, 1.0, 5)
	end

    cl.circle_outline(c, x, y, r, g, b, 255, radius-1, start_degrees, percentage, 3) -- Inner Circle
end

-- Menu
local flag, flag_hotkey = interface.ref("AA", "Fake lag", "Enabled")
local slowmo, slowmo_hotkey = interface.ref("AA", "Other", "Slow motion")
local pingspike, pingspike_hotkey = interface.ref("MISC", "Miscellaneous", "Ping spike")
local accuracyboost = interface.ref("RAGE", "Other", "Accuracy boost options")

local ms = { "Refine shot", "Extended backtrack" }
local actions = { "Ping spike correction", "Accuracy boost correction" }

local apr_active = interface.checkbox("MISC", "Miscellaneous", "Lag correction")
local apr_mselect = interface.multiselect("MISC", "Miscellaneous", "Lag triggers", actions)
local apr_pingthreshold = interface.slider("MISC", "Miscellaneous", "Ping spike threshold", 1, 750, 250, true, "ms")
local apr_acthreshold = interface.slider("MISC", "Miscellaneous", "Accuracy boost threshold", 0, 450, 180, true, "ms")
local apr_acboost = interface.multiselect("MISC", "Miscellaneous", "Accuracy boost flags", ms)

-- Event Functions

local factor, timechange, nD = 0, 0, 0, 0
local idm, lat_success, lat_old = 0, 0, 0

local stime, numeric, z = 0, 7, 0

local function on_paint(c)
	if not interface.get(apr_active) or ent.get_prop(ent.get_local(), "m_iHealth") <= 0 then
		return
	end

	local alpha, show = 255, 0
	local latency_client, latency_server, latency_decl = getlatency()
	local pNum, d = setMath(latency_decl, interface.get(apr_pingthreshold), 100)

	if factor ~= pNum and timechange < cl.realtime() then
		if factor > pNum then d = -1 else d = 1 end
		
		timechange = cl.realtime() + 0.05
		factor = factor + d
	end

	local r, g, b = getColor(factor, 100, false)
	if factor >= 1 then show = 1 end

	if not (interface.get(flag) and interface.get(apr_pingthreshold) > latency_client) then

		local tickcount = (cl.tickcount() % 127.5)
		if not interface.get(pingspike_hotkey) and (interface.get(apr_pingthreshold) <= latency_client) then
			-- Indicator drops
			if idm < cl.realtime() then 
				idm = cl.realtime() + 1
			end

			r, g, b = 255, 0, 0
			lat_success, show = 0, 1
			factor = math.floor((idm - cl.realtime()) * 100)

			-- Fade In/Out
			if tickcount > 63.75 then
				alpha = 255 - (tickcount * 4)
			else
				alpha = tickcount * 4
			end
		end

	end

	if inArr(interface.get(apr_mselect), actions[1]) and not interface.get(flag) and interface.get(apr_pingthreshold) < latency_client then
		r, g, b = 124, 195, 13
	else
		if inArr(interface.get(apr_mselect), actions[2]) and interface.get(apr_acthreshold) > 0 then
			if interface.get(pingspike_hotkey) and interface.get(apr_acthreshold) < latency_decl then
				r, g, b = 53, 110, 254
			end
		end
	end

	if show > 0 then
		if interface.get(pingspike_hotkey) and lat_success > latency_client then
			numeric = 7
		else if not interface.get(pingspike_hotkey) then
				numeric = 9
			else
				numeric = 1
			end
		end

		if nD ~= numeric and stime < cl.realtime() then
			if nD > numeric then z = -1 else z = 1 end
			
			stime = cl.realtime() + 0.4
			nD = nD + z
		end

		local y = cl.indicator(c, colors[nD][1], colors[nD][2], colors[nD][3], alpha, "LAG") -- Lag Factor
		draw_indicator_circle(c, 75, (y + 14), r, g, b, alpha, factor / 100)
	end

	if lat_old ~= latency_client then
		if lat_old < latency_client then
			lat_success = latency_client
			numeric = 7
		else
			numeric = 1
		end

		lat_old = latency_client
	end
end

local function on_run_cmd(e)
	if not interface.get(apr_active) or ent.get_prop(ent.get_local(), "m_iHealth") <= 0 then
		return
	end

	local choked = e.chokedcommands
	local latency_client, latency_server, latency_decl = getlatency()
	
	if inArr(interface.get(apr_mselect), actions[1]) then
		interface.set(flag, not (interface.get(pingspike_hotkey) and interface.get(apr_pingthreshold) <= latency_client))
	end

	if inArr(interface.get(apr_mselect), actions[2]) and interface.get(apr_acthreshold) > 0 then
		if interface.get(pingspike_hotkey) and interface.get(apr_acthreshold) < latency_decl then
			interface.set(accuracyboost, interface.get(apr_acboost))
		else
			interface.set(accuracyboost, "")
		end
	end
end

local function visibility(this)
	interface.visible(apr_mselect, interface.get(this))
	interface.visible(apr_pingthreshold, interface.get(this))

	-- Accuracy boost
	interface.visible(apr_acthreshold, interface.get(this))
	interface.visible(apr_acboost, interface.get(this))
end

interface.callback(apr_active, visibility)

client.set_event_callback("paint", on_paint)
client.set_event_callback("run_command", on_run_cmd)