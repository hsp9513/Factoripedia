local pre ='factoripedia.'
local pre_='factoripedia_'


function dbg(str,b)
  b = b or false
  if false and b then
    game.print(str)
  end
end

function toFixed(value,n)
  return math.floor(value*(10^n))/10^n
end

function SI(value) 
  if     value>=1000000000 then return toFixed(value/1000000000,2)..' G'
  elseif value>=1000000    then return toFixed(value/1000000   ,2)..' M'
  elseif value>=1000       then return toFixed(value/1000      ,2)..' k'
  else                          return toFixed(value           ,2)..'' 
  end
end

function colorText(color,text)
  return {"",'[color='..color.r..','..color.g..','..color.b..']',text,'[/color]'}
end

function setStyle(element, styles)
  for k,v in pairs(styles) do
    element.style[k]=v
  end
  return element
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

