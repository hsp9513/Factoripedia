local pre ='factoripedia.'
local pre_='factoripedia_'


function dbg(str,b)
  b = b or false
  if false and b then
  -- if b then
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
  color = color or {r=1, g=1, b=1}
  return {"",'[color='..color.r..','..color.g..','..color.b..']',text,'[/color]'}
end

function setStyle(element, styles)
  for k,v in pairs(styles) do
    element.style[k]=v
  end
  return element
end

function makeProductInfo(localised_name, probability, amount, min, max)
  probability = probability~=nil and probability or 1
  local description = {""}
  table.insert(description,"[font=default-bold]")
  if probability~=1 then table.insert(description, (probability*100).."% ") end

  local avg
  if amount or (min==max) then 
    avg = amount or min 
    if not (probability~=1 and avg==1) then
      table.insert(description,avg.." × ")
    end
  else                         
    avg = (max + min)/2 
    table.insert(description,min.."-"..max.." × ")
  end

  if probability then avg = avg * probability end

  table.insert(description,"[/font]")
  table.insert(description, localised_name)

  return {description=description, avg=avg}
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

