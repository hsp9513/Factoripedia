remote.add_interface('factoripedia', {
  informatron_menu = function(data)
    return factoripedia_menu(data.player_index)
  end,
  informatron_page_content = function(data)
    return factoripedia_page_content(data.page_name, data.player_index, data.element)
  end
})

function factoripedia_menu(player_index)
  return {
    -- item=1,
    -- fluid=1,
    recipe=1,
    -- tech=1,
  }
end

function factoripedia_page_content(page_name, player_index, element)
  
  local success,message = pcall(function ()
    -- main page
    if page_name == 'factoripedia' then
      element.add{type='label', caption={'factoripedia.main_description'}}
      -- element.add{type='button', name='image_1', style='example_image_1'} -- defined in data.lua. MUST be a completely unique style name
      element.add{type='button', name='reset',caption='reset'} 
      -- element.add{type='button', name='run',caption='run'} 
    end



    if page_name == 'recipe' then
      -- Make gorup table
      local valid_group = {}
      for _,recipe in pairs(get_recipe_proto()) do
        local lua_recipe = game.recipe_prototypes[recipe.name]
        valid_group[lua_recipe.group.name] = true
      end
      local group_table = element.add{type='table',name='group_table',style='filter_group_table',column_count=12}
      set_gui(player_index,'group_table',group_table)
      group_table.add{type="label",name="__target__",caption=""}.visible=false
      do          
        for _,group in pairs(game.item_group_prototypes) do
          if valid_group[group.name] then
            local group_button=group_table.add{type='sprite-button',name=group.name,sprite='item-group/'..group.name ,style='filter_group_button_tab',tooltip=group.localised_name}
            -- group_button.add{type="checkbox",name="selected",state=false}.visible=false

          end
        end      
      end
      
      -- Make content
      local content_flow = element.add{type='flow',name='content_flow',direction='horizontal'}
      do
        local option_frame = content_flow.add{type='frame',name='option_frame',direction='vertical'}
        option_frame.style.vertically_stretchable=true
        do
          option_frame.add{type='label',caption={'factoripedia.module_filter'}}
          local module_flow = option_frame.add{type='flow',name='module_flow',direction='horizontal'}
          local module_table = module_flow.add{type='table',name='module_table', caption="Module List",style='filter_slot_table',column_count=2}
          set_gui(player_index,'module_table',module_table)
          for _,module in pairs(get_modules()) do
            local module_label = module_table.add{type="label",name=module.key..'_label',caption="" }
            local module_localised_string = get_localised_string(player_index,module.key)
            if module_localised_string then 
              module_label.caption={"","[img=item/"..module.icon.."]",module_localised_string}
            else
              game.players[player_index].request_translation({"",module.localised_name,{"factoripedia.empty",module.key}})
            end
            if module.enabled then
              module_table.add{
                type="switch",name=module.key,allow_none_state=true,switch_state="none",
                left_label_caption=" on",right_label_caption="off"
              }
            else
              module_table.add{type="label", name=module.key,caption="everything" ,tooltip="This module can be used every recipe."}            
            end
            module_table.style.column_alignments[#module_table.children]='center'
          end
        end
        local recipe_frame = content_flow.add{type='frame',name='recipe_frame',direction='vertical'}
        recipe_frame.style.vertically_stretchable=true
        recipe_frame.style.horizontally_stretchable=true
        do
          local recipe_scroll = recipe_frame.add{type='scroll-pane',name='recipe_scroll',direction='vertical'}
          recipe_scroll.style.vertically_stretchable=true
          recipe_scroll.style.horizontally_stretchable=true
          recipe_scroll.vertical_scroll_policy='always'
          
          local recipe_flow = recipe_scroll.add{type='flow', name='recipe_flow', caption='Recipe List',style='vertical_flow',direction="vertical"}
          recipe_flow.style.vertical_spacing=0
          set_gui(player_index,'recipe_flow',recipe_flow)
        end
      end


    end
  end)
  if not success then
    reset()
    game.print{"factoripedia.error_message"}
    dbg(message,true)
  end
    
end

function renderFilteredRecipe(player_index)
  local group_table =get_gui(player_index,'group_table')
  local module_table=get_gui(player_index,'module_table')
  local recipe_flow =get_gui(player_index,'recipe_flow')
  recipe_flow.clear()

  local group_name = group_table.__target__.caption
  if group_name ~= "" then
    for subgroup_key,subgroup in pairs(get_groups()[group_name]) do
      local subgroup_table = recipe_flow.add{type="table", name=subgroup_key,style='filter_slot_table',column_count=14}
      for recipe_key,_ in pairs(get_groups()[group_name][subgroup_key].recipes) do
        local recipe=get_recipe_proto()[recipe_key]
        local lua_recipe=game.recipe_prototypes[recipe.name]
        local valid=true
        for _,module in pairs(get_modules()) do
          if module_table[module.key].type=='switch' then
            local state=module_table[module.key].switch_state
            if state=='left' then
              if recipe.module_info[module.key]~=true then valid=false break end
            elseif state=='right' then
              if recipe.module_info[module.key]==true then valid=false break end
            end
          end
        end

        if valid==true then
          subgroup_table.add{type='choose-elem-button',elem_type="recipe",recipe=recipe.name,style='yellow_slot_button'}
        else
          subgroup_table.add{type='choose-elem-button',elem_type="recipe",recipe=recipe.name}
        end
      end
    end

  
  end
end