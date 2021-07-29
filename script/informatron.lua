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
    tile=1,
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
    if page_name == 'tile' then
      tile_page(page_name, player_index, element)
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
        
        -- item_button.add{type="label",name="__name__",caption=item.name}.visible=false
        item_button.add{type='empty-widget',name=pre.."fnei_item",caption=lua_item.name} 
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
      temp.add{type='empty-widget',name=pre.."fnei_item",caption=lua_item.name} 

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
      temp.add{type='empty-widget',name=pre.."fnei_fluid",caption=lua_fluid.name} 

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
      local product_button = products_flow.add{type='sprite-button', sprite=product.type..'/'..product.name, number=amount, tooltip = {"",(product.type=="item" and game.item_prototypes[product.name] or game.fluid_prototypes[product.name]).localised_name," ",amount}}
      product_button.add{type='empty-widget',name=pre..(product.type=="item" and "fnei_item" or "fnei_fluid"),caption=product.name}       
    end
    local setting = surface.map_gen_settings.autoplace_controls[lua_entity.name]
    setStyle(resource_table.add{type='label',caption=(setting and setting.frequency~=0) and "O" or "X"},{horizontally_stretchable=true,horizontal_align='center'})
    if(lua_entity.mineable_properties.required_fluid ) then
      local mineable_properties = lua_entity.mineable_properties
      local fluid_button = setStyle(resource_table.add{type='sprite-button', sprite="fluid/"..mineable_properties.required_fluid, number=mineable_properties.fluid_amount,tooltip=game.fluid_prototypes[mineable_properties.required_fluid].localised_name },{horizontal_align='center'})
      fluid_button.add{type='empty-widget',name=pre.."fnei_fluid",caption=mineable_properties.required_fluid} 
    else
      resource_table.add{type='empty-widget'}
    end
    setStyle(resource_table.add{type='label',caption=lua_entity.infinite_resource and "O" or "X"},{horizontally_stretchable=true,horizontal_align='center'})
  end
  


  -- resource_table.add{type='label',caption={pre.."resource_name"  }}

end

function tile_page(page_name, player_index, element)  
  local items = get_item_proto()

  local tile_flow = element.add{type='flow',name=pre..'tile_flow'}  

  local tile_table = tile_flow.add{type='table',name=pre..'tile_table',column_count=8,draw_vertical_lines=false,draw_horizontal_lines=true,draw_horizontal_line_after_headers=true}  
  tile_table.style.column_alignments[1] = "left"
  tile_table.style.column_alignments[2] = "left"
  tile_table.style.column_alignments[3] = "center"
  tile_table.style.column_alignments[4] = "center"
  tile_table.style.column_alignments[5] = "center"
  tile_table.style.column_alignments[6] = "center"
  tile_table.style.column_alignments[7] = "center"
  tile_table.style.column_alignments[8] = "center"
  setStyle(tile_table.add{type='label',caption=""                                                                           },{          horizontal_align='left'    })
  setStyle(tile_table.add{type='label',caption={pre.."tile"               }                                                 },{width=120,horizontal_align='left'    })
  setStyle(tile_table.add{type='label',caption={pre.."craftable"          },tooltip={pre.."craftable_description"          }},{width=100,horizontal_align='center'  })
  setStyle(tile_table.add{type='label',caption={pre.."minable"            },tooltip={pre.."minable_description"            }},{width=100,horizontal_align='center'  })
  setStyle(tile_table.add{type='label',caption={pre.."natural"            },tooltip={pre.."natural_description"            }},{width=100,horizontal_align='center'  })
  setStyle(tile_table.add{type='label',caption={pre.."walking_speed"      }                                                 },{width=100,horizontal_align='center'  })
  setStyle(tile_table.add{type='label',caption={pre.."vehicle_friction"   }                                                 },{width=100,horizontal_align='center'  })
  setStyle(tile_table.add{type='label',caption={pre.."emission_absorption"},tooltip={pre.."emission_absorption_description"}},{width=120,horizontal_align='center'  })


  for _,lua_tile in pairs(game.tile_prototypes) do
    -- local lua_entity = game.entity_prototypes[resource]
    -- setStyle(tile_table.add{type='choose-elem-button',elem_type='entity',entity=lua_entity.name},{}).locked=true
    setStyle(tile_table.add{type='sprite-button', sprite='tile/'..lua_tile.name,tooltip=colorText(lua_tile.map_color,lua_tile.localised_name)},{})
    
    
    -- setStyle(tile_table.add{type='label',caption={"",'[color='..lua_tile.map_color.r..","..lua_tile.map_color.g..","..lua_tile.map_color.b..']',lua_tile.localised_name,'[/color]'},tooltip=lua_tile.localised_name},{horizontally_stretchable=true,horizontal_align='left'})
    setStyle(tile_table.add{type='label',caption=lua_tile.localised_name},{horizontally_stretchable=true,horizontal_align='left'})

    local craftable = false
    if lua_tile.items_to_place_this then
      for _,item in pairs(lua_tile.items_to_place_this) do       
        if items[item.name] then
          -- setStyle(tile_table.add{type='label',caption=item.name},{horizontally_stretchable=true,horizontal_align='center'})
          local cratable_button = setStyle(tile_table.add{type='choose-elem-button',elem_type="item",item=item.name,caption=item.name},{horizontally_stretchable=true,horizontal_align='center'})
          cratable_button.locked=true
          cratable_button.add{type='empty-widget',name=pre.."fnei_item",caption=item.name}          
          craftable = true
          break
        end
      end
    end
    if not craftable then
      setStyle(tile_table.add{type='label',caption=""},{horizontally_stretchable=true,horizontal_align='center'})
    end

    if lua_tile.mineable_properties.minable then
      local mineable_button = setStyle(tile_table.add{type='choose-elem-button',elem_type="item",item=lua_tile.mineable_properties.products[1].name,caption=""},{horizontally_stretchable=true,horizontal_align='center'})
      mineable_button.locked=true
      mineable_button.add{type='empty-widget',name=pre.."fnei_item",caption=lua_tile.mineable_properties.products[1].name}
    else
      setStyle(tile_table.add{type='label',caption=""},{horizontally_stretchable=true,horizontal_align='center'})
    end
    -- setStyle(tile_table.add{type='label',caption=lua_tile.mineable_properties.minable and "O" or "X"},{horizontally_stretchable=true,horizontal_align='center'})
    
    if lua_tile.autoplace_specification then
      setStyle(tile_table.add{type='sprite-button', sprite='tile/'..lua_tile.name,tooltip=colorText(lua_tile.map_color,lua_tile.localised_name)},{})
    else
      setStyle(tile_table.add{type='label',caption=""},{horizontally_stretchable=true,horizontal_align='center'})
    end
    -- setStyle(tile_table.add{type='label',caption=lua_tile.autoplace_specification and "O" or "X"},{width=100,horizontal_align='center'})
    
    setStyle(tile_table.add{type='label',caption=(lua_tile.walking_speed_modifier*100)..'%'},{width=100,horizontal_align='center'})
    setStyle(tile_table.add{type='label',caption=(lua_tile.vehicle_friction_modifier*100)..'%'},{width=100,horizontal_align='center'})
    -- setStyle(tile_table.add{type='label',caption=(lua_tile.emissions_per_second*60)..'/min'},{width=100,horizontal_align='center'})
    setStyle(tile_table.add{type='label',caption=(lua_tile.emissions_per_second*1000000*60)},{width=100,horizontal_align='center'})
    -- setStyle(tile_table.add{type='label',caption=(lua_tile.map_color.r..","..lua_tile.map_color.g..","..lua_tile.map_color.b)},{width=100,horizontal_align='center'})
    -- setStyle(tile_table.add{type='label',caption={"",'[color='..lua_tile.map_color.r..","..lua_tile.map_color.g..","..lua_tile.map_color.b..']',"■□",'[/color]'}},{horizontally_stretchable=true,horizontal_align='left'})


  end
  


  -- tile_table.add{type='label',caption={pre.."resource_name"  }}

end