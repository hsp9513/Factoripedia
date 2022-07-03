require "script.util"
require "script.proto"
require "script.informatron"

local pre ='factoripedia.'
local pre_='factoripedia_'

function reset()
  reset_proto()
  global.gui={}
  global.localised_string={}
end

script.on_init(function () 
  reset()
end)
script.on_configuration_changed(function () 
  reset()
end)

script.on_event(defines.events.on_gui_click,function (event)
  local success,message = pcall(function ()
    if event.element.name=='reset' then
      reset()
      game.print('factoripedia reset')
    elseif event.element.name=='run' then
      get_recipe_category_proto()
      get_modules()
      game.print('run')
    end
    -- recipe page 
    if event.element.parent and event.element.parent.name==pre..'recipe_group_table' then
      for _,group_button in pairs(event.element.parent.children) do
        if group_button.type=='sprite-button' then
          group_button.style='filter_group_button_tab'
          -- group_button.selected.state=false
        end
      end
      event.element.style='filter_group_button_tab_yellow'
      event.element.parent.__target__.caption=event.element.name
      -- event.element.selected.state=true

      renderFilteredRecipe(event.player_index)
    end
    if event.element.parent and event.element.parent.name==pre..'module_table' then
      renderFilteredRecipe(event.player_index)
    end
    if event.element.tags[pre.."renderFilteredRecipe"]==true then
      renderFilteredRecipe(event.player_index)
    end
    if event.element.name==pre..'module_filter_reset' then      
      local module_table=get_gui(event.player_index,pre..'module_table')
      for _,module in pairs(get_modules()) do
        if module_table[module.key].type=='switch' then
          module_table[module.key].switch_state = 'none'
        end
      end
      renderFilteredRecipe(event.player_index)
    end
    -- item page
    if event.element.parent and event.element.parent.name==pre..'item_group_table' then
      for _,group_button in pairs(event.element.parent.children) do
        if group_button.type=='sprite-button' then
          group_button.style='filter_group_button_tab'
          -- group_button.selected.state=false
        end
      end
      event.element.style='filter_group_button_tab_yellow'
      event.element.parent.__target__.caption=event.element.name
      -- event.element.selected.state=true

      renderFilteredItem(event.player_index)
    end

    -- FNEI recipe remote call(show_recipe_for_prot)
    if event.element.tags[pre.."FNEI"] then
      --game.print(event.element.name)
      if script.active_mods.FNEI then
        if event.element.type=="choose-elem-button" then
          if event.button == defines.mouse_button_type.left then
            remote.call("fnei", "show_recipe_for_prot", "craft", event.element.elem_type, event.element.elem_value)
          else
            remote.call("fnei", "show_recipe_for_prot", "usage", event.element.elem_type, event.element.elem_value)
          end
        elseif event.element.type=="sprite-button" then
          if event.button == defines.mouse_button_type.left then
            remote.call("fnei", "show_recipe_for_prot", "craft", event.element.tags[pre.."FNEI"].type, event.element.tags[pre.."FNEI"].value)
          else
            remote.call("fnei", "show_recipe_for_prot", "usage", event.element.tags[pre.."FNEI"].type, event.element.tags[pre.."FNEI"].value)
          end
        end
      end
    -- FNEI recipe remote call(show_recipe)
    elseif event.element.tags[pre.."FNEI_recipe"] then
      --game.print(event.element.name)
      if script.active_mods.FNEI then
        if event.element.type=="choose-elem-button" then
          remote.call("fnei", "show_recipe", event.element.elem_value)
        end
      end
    end

  end)
  if not success then
    reset()
    game.print{"factoripedia.error_message"}
    dbg(message,true)
  end


end)


script.on_event(defines.events.on_string_translated,function (event)
  local success,message = pcall(function ()
    if event.localised_string and event.localised_string[3] and event.localised_string[3][1]=="factoripedia.empty" then
      local parameter = event.localised_string[3] -- [1]:factoripedia.empty [2...]:parameter
      local module_key=parameter[2]
      local s=string.find(event.result," ?%d+$")  -- remove tier number
      local result = s and string.sub(event.result,1,s-1) or event.result

      s=string.find(result, " ?[Mm][Kk]$")
      result = s and string.sub(result,1,s-1) or result -- remove MK

      set_localised_string(event.player_index,module_key,result)
      get_gui(event.player_index,pre..'module_table')[module_key..'_label'].caption
        ={"","[img=item/"..get_modules()[module_key].icon.."]",result}
    end
  end)
  if not success then
    reset()
    game.print{pre..'error_message'}
    dbg(message,true)
  end
end)

if script.active_mods["gvv"] then require("__gvv__.gvv")() end
