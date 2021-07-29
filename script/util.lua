function dbg(str,b)
  b = b or false
  if false and b then
    game.print(str)
  end
end
  
function set_gui(player_index,key,gui)
if not global.gui[player_index] then global.gui[player_index]={} end
global.gui[player_index][key]=gui
end

function get_gui(player_index,key)
    return global.gui[player_index] and global.gui[player_index][key]
end

function set_localised_string(player_index,key,localised_string)
    if not global.localised_string[player_index] then global.localised_string[player_index]={} end
    global.localised_string[player_index][key]=localised_string
end

function get_localised_string(player_index,key)
  return global.localised_string[player_index] and global.localised_string[player_index][key]
end

