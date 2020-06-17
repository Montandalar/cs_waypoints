



local mod_name = minetest.get_current_modname()

local function log(level, message)
    minetest.log(level, ('[%s] %s'):format(mod_name, message))
end

log('action', 'CSM loading...')

local mod_storage = minetest.get_mod_storage()


local search_delta_default = 10

--
--
-- local functions
--
--

local function load_waypoints()
    if string.find(mod_storage:get_string('waypoints'), 'return') then
        return minetest.deserialize(mod_storage:get_string('waypoints'))
    else
        return {}
    end
end

local function load_waypoints_stack()
    if string.find(mod_storage:get_string('waypoints_stack'), 'return nil') then
       return {}
    end
    if string.find(mod_storage:get_string('waypoints_stack'), 'return') then
        return minetest.deserialize(mod_storage:get_string('waypoints_stack'))
    else
        return {}
    end
end

local waypoints = load_waypoints()


local function safe(func)
    -- wrap a function w/ logic to avoid crashing the game
    local f = function(...)
        local status, out = pcall(func, ...)
        if status then
            return out
        else
            log('warning', 'Error (func):  ' .. out)
            return nil
        end
    end
    return f
end


local function round(x)
   return math.floor(x+0.5)
end


local function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0
    return function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
end


local function lc_cmp(a, b)
    return a:lower() < b:lower()
end


local function tostring_point(point)
    return ('%i %i.5 %i'):format(round(point.x), round(point.y), round(point.z))
end




local function teleport_to(position_name)
   local wpname = position_name
   local waypoint = waypoints[wpname]
   if waypoint ~= nil then
      minetest.run_server_chatcommand('teleport', tostring_point(waypoint))
   else
      minetest.display_chat_message(('waypoint "%s" not found.'):format(wpname))
   end
   return true
end



local function stack_push()
   local point = minetest.localplayer:get_pos()
   wp_stack = load_waypoints_stack()
   count = #wp_stack +1
   wp_stack[count] = point
   mod_storage:set_string('waypoints_stack', minetest.serialize(wp_stack))
end

local function stack_pop()
   wp_stack = load_waypoints_stack()
   count = 0
   if nil ~= wp_stack then count = #wp_stack end
   if count<1 then
      minetest.display_chat_message('stack empty - no teleporting')
      return
   end
   minetest.run_server_chatcommand('teleport', tostring_point(wp_stack[count]))
   wp_stack[count] = nil
   mod_storage:set_string('waypoints_stack', minetest.serialize(wp_stack))
   return true   
end

local function stack_show()
   wp_stack = load_waypoints_stack()
   count = 0
   if nil ~= wp_stack then count = #wp_stack end
   if count<1 then
      minetest.display_chat_message('stack empty')
      return true
   end
   output = ""
   for i = count,1,-1 do
      output = output .. tostring(i) .. "  " ..  tostring_point(wp_stack[i]).."\n"
   end
   return true ,output
end

local function stack_clear()
   mod_storage:set_string('waypoints_stack', minetest.serialize(nil))
end

local function  stack_search(d)   
   local delta = d
   if delta then       delta = tonumber(delta) end
   if nil == delta then delta = search_delta_default  end 
   if delta < 0 then delta = 0 end
   
   here = minetest.localplayer:get_pos()
   minetest.display_chat_message(
                ('%s : %s'):format("current position", tostring_point(here))
            )
   for name,pos in pairsByKeys(waypoints, lc_cmp) do
      if math.abs(here.y-pos.y) <= delta then
	 if math.abs(here.x-pos.x) <= delta then
	    if math.abs(here.z-pos.z) <= delta then
	       minetest.display_chat_message(
		     ('%s -> %s'):format(name, tostring_point(pos)))
	    end
	 end
      end
   end
   return true
end


--
--
-- chat commands
--
--


minetest.register_chatcommand('wp_set', {
    params = '<name>',
    description = 'set a waypoint',
    func = safe(function(param)
        waypoints = load_waypoints()
        local point = minetest.localplayer:get_pos()
        waypoints[param] = point
        mod_storage:set_string('waypoints', minetest.serialize(waypoints))

        minetest.display_chat_message(
            ('set waypoint "%s" to "%s"'):format(param, tostring_point(point))
        )
    end),
})


minetest.register_chatcommand('wp_unset', {
    params = '<name>',
    description = 'remove a waypoint',
    func = safe(function(param)
        waypoints = load_waypoints()
        waypoints[param] = nil
        mod_storage:set_string('waypoints', minetest.serialize(waypoints))

        minetest.display_chat_message(
            ('removed waypoint "%s"'):format(param)
        )
    end),
})


minetest.register_chatcommand('wp_list', {
    params = '',
    description = 'lists waypoints',
    func = safe(function(_)
        for name, point in pairsByKeys(waypoints, lc_cmp) do
            minetest.display_chat_message(
                ('%s -> %s'):format(name, tostring_point(point))
            )
        end
    end),
})


minetest.register_chatcommand('tw', {
	params = '<waypoint>',
	description = 'teleport to a waypoint',
	func = safe(function(param)
		       safe(teleport_to(param))
		    end),
     }
  )


minetest.register_chatcommand('tw_push', {
	params = '<waypoint>',
	description = 'teleport to a waypoint and save old position',
	func = safe(function(param)
		       stack_push()
		       safe(teleport_to(param))
		    end),
     }
  )

minetest.register_chatcommand('wp_push', {
	params = '<position/player>',
	description = 'teleport to a position/player and save old position',
	func = safe(function(param)
		       stack_push()
		       minetest.run_server_chatcommand('teleport', param)
		    end),
     }
  )



minetest.register_chatcommand('tw_pop', {
	params = '',
	description = 'return to the last saved position',
	func = stack_pop,
     }
  )

minetest.register_chatcommand('wp_pop', {
	params = '',
	description = 'return to the last saved position',
	func = stack_pop,
     }
  )

minetest.register_chatcommand('wp_stack', {
	params = '',
	description = 'shows the stack content',
	func = stack_show,
     }
  )

minetest.register_chatcommand('wp_stack_clear', {
	params = '',
	description = 'clears the position stack',
	func = stack_clear,
     }
  )


minetest.register_chatcommand('wp_search', {
	params = '(<delta>)',
	description = 'search a waypoint near the current position',
	func = stack_search,
     }
  )


        

