local pre ='factoripedia.'
local pre_='factoripedia_'

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
    item=1,
    -- fluid=1,
    recipe=1,
    -- tech=1,
    fuel=1,
    resource=1,
  }
end

function factoripedia_page_content(page_name, player_index, element)
  
  local success,message = pcall(function ()
    -- main page
    if page_name == 'factoripedia' then
      element.add{type='label', caption={pre..'main_description'}}
      -- element.add{type='button', name='image_1', style='example_image_1'} -- defined in data.lua. MUST be a completely unique style name
      element.add{type='button', name='reset',caption='reset'} 
      -- element.add{type='button', name='run',caption='run'} 
    end
    if page_name == 'item' then
      item_page(page_name, player_index, element)
    end
    if page_name == 'recipe' then
      recipe_page(page_name, player_index, element)
    end    
    if page_name == 'fuel' then
      fuel_page(page_name, player_index, element)
    end
    if page_name == 'resource' then
      resource_page(page_name, player_index, element)
    end
  end)
  if not success then
    reset()
    game.print{pre..'error_message'}
    dbg(message,true)
  end    
end

function item_page(page_name, player_index, element)
  -- Make gorup table
  local valid_group = {}
  for _,item in pairs(get_item_proto()) do
    local lua_item = game.item_prototypes[item.name]
    valid_group[lua_item.group.name] = true
  end
  local group_table = element.add{type='table',name=pre..'item_group_table',style='filter_group_table',column_count=12}
  set_gui(player_index,pre..'item_group_table',group_table)
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
  local content_flow = element.add{type='flow',name=pre..'content_flow',direction='horizontal'}
  do
    local option_frame = content_flow.add{type='frame',name=pre..'option_frame',direction='vertical'}
    option_frame.style.vertically_stretchable=true
    option_frame.visible=false -- temporary
    
    local item_frame = content_flow.add{type='frame',name=pre..'item_frame',direction='vertical'}
    item_frame.style.vertically_stretchable=true
    item_frame.style.horizontally_stretchable=true
    do
      local item_scroll = item_frame.add{type='scroll-pane',name=pre..'item_scroll',direction='vertical'}
      item_scroll.style.vertically_stretchable=true
      item_scroll.style.horizontally_stretchable=true
      item_scroll.vertical_scroll_policy='always'
      
      local item_flow = item_scroll.add{type='flow', name=pre..'item_flow', caption='Item List',style='vertical_flow',direction="vertical"}
      item_flow.style.vertical_spacing=0
      set_gui(player_index,pre..'item_flow',item_flow)
    end
  end
end

function renderFilteredItem(player_index)
  local group_table =get_gui(player_index,pre..'item_group_table')
  local item_flow =get_gui(player_index,pre..'item_flow')
  item_flow.clear()

  local group_name = group_table.__target__.caption
  if group_name ~= "" then
    for subgroup_key,subgroup in pairs(get_groups()[group_name]) do
      local subgroup_table = item_flow.add{type="table", name=subgroup_key,style='filter_slot_table',column_count=14}
      for item_key,_ in pairs(get_groups()[group_name][subgroup_key].items) do
        local item=get_item_proto()[item_key]
        local lua_item=game.item_prototypes[item.name]
        --local valid=true
        --local valid=false


        
        -- item_button=subgroup_table.add{type='choose-elem-button',elem_type="item",item=item.name,caption=item.name}
        -- item_button.locked=true
        item_button=subgroup_table.add{type='sprite-button',sprite='item/'..item.name,number=lua_item.stack_size}
        item_button.tooltip={"","[img=item/"..lua_item.name.."] ",lua_item.localised_name,"\n",lua_item.name}
        
        item_button.add{type="label",name="__name__",caption=item.name}.visible=false
        --item_button.add{type="label",name="__stack__",caption=lua_item.stack_size}
      end
    end
  end
end

function recipe_page(page_name, player_index, element)
  -- Make gorup table
  local valid_group = {}
  for _,recipe in pairs(get_recipe_proto()) do
    local lua_recipe = game.recipe_prototypes[recipe.name]
    valid_group[lua_recipe.group.name] = true
  end
  local group_table = element.add{type='table',name=pre..'recipe_group_table',style='filter_group_table',column_count=12}
  set_gui(player_index,pre..'recipe_group_table',group_table)
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
  local content_flow = element.add{type='flow',name=pre..'content_flow',direction='horizontal'}
  do
    local option_frame = content_flow.add{type='frame',name=pre..'option_frame',direction='vertical'}
    option_frame.style.vertically_stretchable=true
    do
      option_frame.add{type='label',caption={pre..'module_filter'}}
      local module_flow = option_frame.add{type='flow',name=pre..'module_flow',direction='horizontal'}
      local module_table = module_flow.add{type='table',name=pre..'module_table', caption="Module List",style='filter_slot_table',column_count=2}
      set_gui(player_index,pre..'module_table',module_table)
      for _,module in pairs(get_modules()) do
        local module_label = module_table.add{type="label",name=module.key..'_label',caption="" }
        local module_localised_string = get_localised_string(player_index,module.key)
        if module_localised_string then 
          module_label.caption={"","[img=item/"..module.icon.."]",module_localised_string}
        else
          game.players[player_index].request_translation({"",module.localised_name,{pre..'empty',module.key}})
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
    local recipe_frame = content_flow.add{type='frame',name=pre..'recipe_frame',direction='vertical'}
    recipe_frame.style.vertically_stretchable=true
    recipe_frame.style.horizontally_stretchable=true
    do
      local recipe_scroll = recipe_frame.add{type='scroll-pane',name=pre..'recipe_scroll',direction='vertical'}
      recipe_scroll.style.vertically_stretchable=true
      recipe_scroll.style.horizontally_stretchable=true
      recipe_scroll.vertical_scroll_policy='always'
      
      local recipe_flow = recipe_scroll.add{type='flow', name=pre..'recipe_flow', caption='Recipe List',style='vertical_flow',direction="vertical"}
      recipe_flow.style.vertical_spacing=0
      set_gui(player_index,pre..'recipe_flow',recipe_flow)
    end
  end
end



function renderFilteredRecipe(player_index)
  local group_table =get_gui(player_index,pre..'recipe_group_table')
  local module_table=get_gui(player_index,pre..'module_table')
  local recipe_flow =get_gui(player_index,pre..'recipe_flow')
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

        local recipe_button
        if valid==true then
          recipe_button=subgroup_table.add{type='choose-elem-button',elem_type="recipe",recipe=recipe.name,style='yellow_slot_button'}
        else
          recipe_button=subgroup_table.add{type='choose-elem-button',elem_type="recipe",recipe=recipe.name}
        end
        recipe_button.locked=true
      end
    end

  
  end
end


function fuel_page(page_name, player_index, element)  
  local fuel_flow = element.add{type='flow',name=pre..'fuel_flow',direction='vertical'}


  local temp
  temp=fuel_flow.add{type='button',style='list_box_item' }
  temp.style.margin=-3
  temp.style.width=800

  temp=temp.add{type='flow'}
  temp.ignored_by_interaction=true
  setStyle(temp.add{type='label',caption={pre.."fuel_name"  }},{width=200,horizontal_align='center'})
  setStyle(temp.add{type='label',caption={pre.."calorie"    }},{width=100,horizontal_align='center'})
  setStyle(temp.add{type='label',caption={pre.."category"   }},{width=150,horizontal_align='center'})
  setStyle(temp.add{type='label',caption={pre.."emission"   }},{width=100,horizontal_align='center'})
  setStyle(temp.add{type='label',caption={pre.."accel_bonus"}},{width=100,horizontal_align='center'})
  setStyle(temp.add{type='label',caption={pre.."speed_bonus"}},{width=100,horizontal_align='center'})

  local items = get_item_proto()
  for _,item in pairs(items) do 
    local lua_item = game.item_prototypes[item.name]
    if lua_item.fuel_value>0 then 
      temp=fuel_flow.add{type='button',style='list_box_item'}
      temp.style.margin=-3
      temp.style.width=800

      temp=temp.add{type='flow'}
      temp.ignored_by_interaction=true
      setStyle(temp.add{type='label',caption={"","[img=item/"..lua_item.name.."] ",lua_item.localised_name}},{width=200,horizontal_align='left'  })
      setStyle(temp.add{type='label',caption=SI(lua_item.fuel_value)..'J '}                                 ,{width=100,horizontal_align='center'})
      setStyle(temp.add{type='label',caption=lua_item.fuel_category}                                        ,{width=150,horizontal_align='center'})
      setStyle(temp.add{type='label',caption=(lua_item.fuel_emissions_multiplier*100)..'%'}                 ,{width=100,horizontal_align='center'})
      setStyle(temp.add{type='label',caption=(lua_item.fuel_acceleration_multiplier*100)..'%'}              ,{width=100,horizontal_align='center'})
      setStyle(temp.add{type='label',caption=(lua_item.fuel_top_speed_multiplier*100)..'%'}                 ,{width=100,horizontal_align='center'})
    end
  end

  local fluids = get_fluid_proto()  
  for _,fluid in pairs(fluids) do 
    local lua_fluid = game.fluid_prototypes[fluid.name]
    if lua_fluid.fuel_value>0 then
      temp=fuel_flow.add{type='button',style='list_box_item'}
      temp.style.margin=-3
      temp.style.width=800

      temp=temp.add{type='flow'}
      temp.ignored_by_interaction=true
      setStyle(temp.add{type='label',caption={"","[img=fluid/"..lua_fluid.name.."] ",lua_fluid.localised_name}},{width=200,horizontal_align='left'  })
      setStyle(temp.add{type='label',caption=SI(lua_fluid.fuel_value)..'J '}                                   ,{width=100,horizontal_align='center'})
      setStyle(temp.add{type='label',caption='fluid'}                                                          ,{width=150,horizontal_align='center'})
      setStyle(temp.add{type='label',caption=(lua_fluid.emissions_multiplier*100)..'%'}                        ,{width=100,horizontal_align='center'})
      setStyle(temp.add{type='label',caption='N/A'}                                                            ,{width=100,horizontal_align='center'})
      setStyle(temp.add{type='label',caption='N/A'}                                                            ,{width=100,horizontal_align='center'})
    end
  end
end

function resource_page(page_name, player_index, element)  
  get_item_proto()
  local surface = game.surfaces[1]

  local resource_flow = element.add{type='flow',name=pre..'resource_flow'}  

  local resource_table = resource_flow.add{type='table',name=pre..'resource_table',column_count=7,draw_vertical_lines=false,draw_horizontal_lines=true,draw_horizontal_line_after_headers=true}  
  resource_table.style.column_alignments[1] = "left"
  resource_table.style.column_alignments[2] = "left"
  resource_table.style.column_alignments[3] = "center"
  resource_table.style.column_alignments[4] = "center"
  resource_table.style.column_alignments[5] = "center"
  resource_table.style.column_alignments[6] = "center"
  resource_table.style.column_alignments[7] = "center"
  setStyle(resource_table.add{type='label',caption=""                     },{          horizontal_align='left'    })
  setStyle(resource_table.add{type='label',caption={pre.."resource"      }},{width=100,horizontal_align='left'    })
  setStyle(resource_table.add{type='label',caption={pre.."mining_time"   }},{width=100,horizontal_align='center'  })
  setStyle(resource_table.add{type='label',caption={pre.."products"      }},{width=100,horizontal_align='center'  })
  setStyle(resource_table.add{type='label',caption=surface.name           },{width=100,horizontal_align='center'  })
  setStyle(resource_table.add{type='label',caption={pre.."required_fluid"}},{width=100,horizontal_align='center'  })
  setStyle(resource_table.add{type='label',caption={pre.."infinity"      }},{width=100,horizontal_align='center'  })

  for resource,_ in pairs(global.item_special_type['resource']) do
    local lua_entity = game.entity_prototypes[resource]
    setStyle(resource_table.add{type='choose-elem-button',elem_type='entity',entity=lua_entity.name},{}).locked=true
    setStyle(resource_table.add{type='label',caption=lua_entity.localised_name},{horizontally_stretchable=true,horizontal_align='left'})
    setStyle(resource_table.add{type='label',caption=lua_entity.mineable_properties.mining_time},{horizontally_stretchable=true,horizontal_align='center'})
    local products_flow = setStyle(resource_table.add{type='flow'},{horizontally_stretchable=true,horizontal_align='center'})
    for _,product in pairs(lua_entity.mineable_properties.products) do
      local amount
      if(product.amount) then amount = product.amount
      else amount = product.amount_max - product.amount_min
      end
      if(product.probability) then amount = amount * product.probability end
      products_flow.add{type='sprite-button', sprite=product.type..'/'..product.name, number=amount, tooltip = {"",(product.type=="item" and game.item_prototypes[product.name] or game.fluid_prototypes[product.name]).localised_name," ",amount}}
    end
    local setting = surface.map_gen_settings.autoplace_controls[lua_entity.name]
    setStyle(resource_table.add{type='label',caption=(setting and setting.frequency~=0) and "O" or "X"},{horizontally_stretchable=true,horizontal_align='center'})
    if(lua_entity.mineable_properties.required_fluid ) then
      setStyle(resource_table.add{type='sprite-button', sprite="fluid/"..lua_entity.mineable_properties.required_fluid, number=lua_entity.mineable_properties.fluid_amount,tooltip=game.fluid_prototypes[lua_entity.mineable_properties.required_fluid].localised_name },{horizontal_align='center'})
    else
      resource_table.add{type='empty-widget'}
    end
    setStyle(resource_table.add{type='label',caption=lua_entity.infinite_resource and "O" or "X"},{horizontally_stretchable=true,horizontal_align='center'})
  end
  


  -- resource_table.add{type='label',caption={pre.."resource_name"  }}

end