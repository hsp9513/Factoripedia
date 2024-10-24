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
    collection=1,
    enemy=1,
    spoil=1,
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
    if page_name == 'collection' then
      collection_page(page_name, player_index, element)
    end
    if page_name == 'enemy' then
      enemy_page(page_name, player_index, element)
    end
    if page_name == 'spoil' then
      spoil_page(page_name, player_index, element)
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
    local lua_item = prototypes.item[item.name]
    valid_group[lua_item.group.name] = true
  end
  --local group_table = element.add{type='table',name=pre..'item_group_table',style='filter_group_table',column_count=12}
  local group_table = element.add{type='table',name=pre..'item_group_table',column_count=12}
  set_gui(player_index,pre..'item_group_table',group_table)
  group_table.add{type="label",name="__target__",caption=""}.visible=false
  do          
    for _,group in pairs(prototypes.item_group) do
      if valid_group[group.name] then
        local group_button=group_table.add{type='tab',name=group.name,sprite='item-group/'..group.name ,style='filter_group_slot_tab',tooltip=group.localised_name}
        -- group_button.add{type="checkbox",name="selected",state=false}.visible=false
        setStyle(group_button,{ vertically_stretchable=false, horizontally_stretchable=false  })
        group_button.add{type="sprite",sprite='item-group/'..group.name}
        setStyle(group_button.add{type="sprite",sprite='item-group/'..group.name},{ vertically_stretchable=true, horizontally_stretchable=true  })
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
        local lua_item=prototypes.item[item.name]
        --local valid=true
        --local valid=false


        
        -- item_button=subgroup_table.add{type='choose-elem-button',elem_type="item",item=item.name,caption=item.name}
        -- item_button.locked=true
        item_button=subgroup_table.add{type='sprite-button',sprite='item/'..item.name,number=lua_item.stack_size}
        item_button.tooltip={"","[img=item/"..lua_item.name.."] ",lua_item.localised_name,"\n",lua_item.name}
        item_button.tags={[pre.."FNEI"]={type="item",value=item.name}}
        -- item_button.add{type="label",name="__name__",caption=item.name}.visible=false
        --item_button.add{type="label",name="__stack__",caption=lua_item.stack_size}
      end
    end
  end
end

function recipe_page(page_name, player_index, element)
  -- Make gorup table
  -- local valid_group = {}
  -- for _,recipe in pairs(get_recipe_proto()) do
  --   local lua_recipe = prototypes.recipe[recipe.name]
  --   valid_group[lua_recipe.group.name] = true
  -- end
  --local group_table = element.add{type='table',name=pre..'recipe_group_table',style='filter_group_table',column_count=12}
  local group_table = element.add{type='table',name=pre..'recipe_group_table',column_count=12}
  set_gui(player_index,pre..'recipe_group_table',group_table)
  group_table.add{type="label",name="__target__",caption=""}.visible=false
  do          
    for groupkey,_ in pairs(get_recipe_groups()) do
      local group = prototypes.item_group[groupkey]
      local group_button=group_table.add{type='tab',name=group.name,sprite='item-group/'..group.name ,style='filter_group_slot_tab',tooltip=group.localised_name}
      -- group_button.add{type="checkbox",name="selected",state=false}.visible=false
         group_button.add{type="sprite",sprite='item-group/'..group.name}

    end      
  end
  
  -- Make content
  local content_flow = element.add{type='flow',name=pre..'content_flow',direction='horizontal'}
  do
    local option_frame = content_flow.add{type='frame',name=pre..'option_frame',direction='vertical'}
    option_frame.style.vertically_stretchable=true
    local option_scroll = option_frame.add{type='scroll-pane',name=pre..'option_scroll',direction='vertical'}
    option_scroll.style.vertically_stretchable=true
    option_scroll.vertical_scroll_policy='always'
    do -- general filter option
      option_scroll.add{type='label',caption={pre..'general_filter'}}
      local filter_flow = option_scroll.add{type='flow',name=pre..'filter_flow',direction='horizontal'}
      local filter_table = filter_flow.add{type='table',name=pre..'filter_table', caption="Filter List",style='filter_slot_table',column_count=2}
      set_gui(player_index,pre..'filter_table',filter_table)

      filter_table.add{type="label",name='scope_label',caption="scope_label  ", visible=false }
      filter_table.add{
        type="switch",name=pre.."scope_switch",allow_none_state=false,switch_state="left",
        left_label_caption="all",right_label_caption="related",
        left_label_tooltip={pre.."recipe_filter_all"},right_label_tooltip={pre.."recipe_filter_related"},
        tags = {[pre.."renderFilteredRecipe"]=true}
      }
      -- Void Recipe Filtering
      -- filter_table.add{type="label",name='void_label',caption="Void recipe  " }
      -- filter_table.add{
      --   type="switch",name=pre.."void_switch",allow_none_state=false,switch_state="left",
      --   left_label_caption="include",right_label_caption="exclude",
      --   tags = {[pre.."renderFilteredRecipe"]=true}
      -- }
    end
    do -- module filter option
      local module_top=option_scroll.add{type='flow',name=pre..'module_top',direction='horizontal'}
      module_top.add{type='label',caption={pre..'module_filter'}}
      setStyle(module_top.add{type='button',name=pre..'module_filter_reset',caption='reset'},{width=60,height=18})
      local module_flow = option_scroll.add{type='flow',name=pre..'module_flow',direction='horizontal'}
      local module_table = module_flow.add{type='table',name=pre..'module_table', caption="Module List",style='filter_slot_table',column_count=2}
      set_gui(player_index,pre..'module_table',module_table)
      --for _,module in pairs(get_modules()) do
      for _,module_effect in pairs(get_module_effects()) do
        local module_label = module_table.add{type="label",name=module_effect.key..'_label',caption="" }
        --local module_localised_string = get_localised_string(player_index,module_effect.localised_name)
        local module_localised_string = module_effect.localised_name
        --module_label.caption={"","[img=item/"..module_effect.icon.."]",module_localised_string}
        module_label.caption={"",module_localised_string}

        module_label.tooltip=module_effect.tooltip
        if module_effect.enabled then
          module_table.add{
            type="switch",name=module_effect.key,allow_none_state=true,switch_state="none",
            left_label_caption=" on",right_label_caption="off",
            tags = {[pre.."renderFilteredRecipe"]=true}
          }
        else
          module_table.add{type="label", name=module_effect.key,caption="everything" ,tooltip={pre.."module_filter_everything"}} 
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
  local filter_table=get_gui(player_index,pre..'filter_table')
  local module_table=get_gui(player_index,pre..'module_table')
  local recipe_flow =get_gui(player_index,pre..'recipe_flow')
  recipe_flow.clear()

  local scope_state = filter_table[pre.."scope_switch"].switch_state
  local module_table_state={}
  for _,module_effect in pairs(get_module_effects()) do
    if module_table[module_effect.key].type=='switch' then
      module_table_state[module_effect.key] = module_table[module_effect.key].switch_state      
    -- else
    --   module_table_state[module_effect.key] = nil
    end
  end

  local group_name = group_table.__target__.caption
  if group_name ~= "" then
    for subgroup_key,subgroup in pairs(get_groups()[group_name]) do
      local subgroup_valid = false
      local subgroup_table = recipe_flow.add{type="table", name=subgroup_key,style='filter_slot_table',column_count=14}
      for recipe_key,_ in pairs(get_groups()[group_name][subgroup_key].recipes) do
        local recipe=get_recipe_proto()[recipe_key]
        --local lua_recipe=prototypes.recipe[recipe.name]
        local lua_recipe=prototypes.recipe[recipe.name]
        local valid=true
        for _,module_effect in pairs(get_module_effects()) do
          if module_table_state[module_effect.key] ~=nil then
            local state=module_table_state[module_effect.key]
            if state=='left' then
              if lua_recipe.allowed_effects[module_effect.key]~=true then valid=false break end
            elseif state=='right' then
              if lua_recipe.allowed_effects[module_effect.key]==true then valid=false break end
            end
          end
        end

        local recipe_button
        if valid==true then
          recipe_button=subgroup_table.add{type='choose-elem-button',elem_type="recipe",recipe=recipe.name,style='yellow_slot_button'}
          subgroup_valid=true
        else
          recipe_button=subgroup_table.add{type='choose-elem-button',elem_type="recipe",recipe=recipe.name}
        end
        recipe_button.locked=true
        recipe_button.tags={[pre.."FNEI_recipe"]=true}
      end
      if subgroup_valid==false and scope_state=='right' then
        subgroup_table.visible = false
      end
    end  
  end
end


-- function fuel_old_page(page_name, player_index, element)  
--   local fuel_flow = element.add{type='flow',name=pre..'fuel_flow',direction='vertical'}


--   local temp
--   temp=fuel_flow.add{type='button',style='list_box_item' }
--   temp.style.margin=-3
--   temp.style.width=800

--   temp=temp.add{type='flow'}
--   temp.ignored_by_interaction=true
--   setStyle(temp.add{type='label',caption={pre.."fuel_name"  }},{width=200,horizontal_align='center'})
--   setStyle(temp.add{type='label',caption={pre.."calorie"    }},{width=100,horizontal_align='center'})
--   setStyle(temp.add{type='label',caption={pre.."category"   }},{width=150,horizontal_align='center'})
--   setStyle(temp.add{type='label',caption={"description.fuel-pollution"   }},{width=100,horizontal_align='center'})
--   setStyle(temp.add{type='label',caption={"description.fuel-acceleration"}},{width=100,horizontal_align='center'})
--   setStyle(temp.add{type='label',caption={"description.fuel-top-speed"}},{width=100,horizontal_align='center'})

--   local items = get_item_proto()
--   for _,item in pairs(items) do 
--     local lua_item = prototypes.item[item.name]
--     if lua_item.fuel_value>0 then 
--       temp=fuel_flow.add{type='button',style='list_box_item'}
--       temp.style.margin=-3
--       temp.style.width=800
--       temp.add{type='empty-widget',name=pre.."fnei_item",caption=lua_item.name} 

--       temp=temp.add{type='flow'}
--       temp.ignored_by_interaction=true
--       setStyle(temp.add{type='label',caption={"","[img=item/"..lua_item.name.."] ",lua_item.localised_name}},{width=200,horizontal_align='left'  })
--       setStyle(temp.add{type='label',caption=SI(lua_item.fuel_value)..'J '}                                 ,{width=100,horizontal_align='center'})
--       setStyle(temp.add{type='label',caption=lua_item.fuel_category}                                        ,{width=150,horizontal_align='center'})
--       setStyle(temp.add{type='label',caption=(lua_item.fuel_emissions_multiplier*100)..'%'}                 ,{width=100,horizontal_align='center'})
--       setStyle(temp.add{type='label',caption=(lua_item.fuel_acceleration_multiplier*100)..'%'}              ,{width=100,horizontal_align='center'})
--       setStyle(temp.add{type='label',caption=(lua_item.fuel_top_speed_multiplier*100)..'%'}                 ,{width=100,horizontal_align='center'})      
--     end
--   end

--   local fluids = get_fluid_proto()  
--   for _,fluid in pairs(fluids) do 
--     local lua_fluid = prototypes.fluid[fluid.name]
--     if lua_fluid.fuel_value>0 then
--       temp=fuel_flow.add{type='button',style='list_box_item'}
--       temp.style.margin=-3
--       temp.style.width=800
--       temp.add{type='empty-widget',name=pre.."fnei_fluid",caption=lua_fluid.name} 

--       temp=temp.add{type='flow'}
--       temp.ignored_by_interaction=true
--       setStyle(temp.add{type='label',caption={"","[img=fluid/"..lua_fluid.name.."] ",lua_fluid.localised_name}},{width=200,horizontal_align='left'  })
--       setStyle(temp.add{type='label',caption=SI(lua_fluid.fuel_value)..'J '}                                   ,{width=100,horizontal_align='center'})
--       setStyle(temp.add{type='label',caption='fluid'}                                                          ,{width=150,horizontal_align='center'})
--       setStyle(temp.add{type='label',caption=(lua_fluid.emissions_multiplier*100)..'%'}                        ,{width=100,horizontal_align='center'})
--       setStyle(temp.add{type='label',caption='N/A'}                                                            ,{width=100,horizontal_align='center'})
--       setStyle(temp.add{type='label',caption='N/A'}                                                            ,{width=100,horizontal_align='center'})
--     end
--   end
-- end
function fuel_page(page_name, player_index, element)  
  local fuel_flow = element.add{type='flow',name=pre..'fuel_flow',direction='vertical'}

  local fuel_table = fuel_flow.add{type='table',name=pre..'fuel_table',column_count=8,draw_vertical_lines=false,draw_horizontal_lines=true,draw_horizontal_line_after_headers=true}  
  fuel_table.style.column_alignments[1] = "left"
  fuel_table.style.column_alignments[2] = "left"
  fuel_table.style.column_alignments[3] = "center"
  fuel_table.style.column_alignments[4] = "center"
  fuel_table.style.column_alignments[5] = "center"
  fuel_table.style.column_alignments[6] = "center"
  fuel_table.style.column_alignments[7] = "center"
  fuel_table.style.column_alignments[8] = "center"
  setStyle(fuel_table.add{type='label',caption=""                               },{          horizontal_align='left'    })
  setStyle(fuel_table.add{type='label',caption={pre.."fuel_name"               }},{width=100,horizontal_align='left'    })
  setStyle(fuel_table.add{type='label',caption={pre.."calorie"                 }},{width=100,horizontal_align='center'  })
  setStyle(fuel_table.add{type='label',caption={pre.."category"                }},{width=100,horizontal_align='center'  })
  setStyle(fuel_table.add{type='label',caption={"description.fuel-pollution"   }},{width=100,horizontal_align='center'  })
  setStyle(fuel_table.add{type='label',caption={"description.fuel-acceleration"}},{width=100,horizontal_align='center'  })
  setStyle(fuel_table.add{type='label',caption={"description.fuel-top-speed"   }},{width=100,horizontal_align='center'  })
  setStyle(fuel_table.add{type='label',caption={"description.spent-result"     }},{width=100,horizontal_align='center'  })


  local fuel_item_category = {}

  local items = get_item_proto()
  for _,item in pairs(items) do 
    local lua_item = prototypes.item[item.name]
    if lua_item.fuel_value>0 then 
      if not fuel_item_category[lua_item.fuel_category] then
        fuel_item_category[lua_item.fuel_category] = {}
      end
      table.insert(fuel_item_category[lua_item.fuel_category], lua_item)
    end
  end

  for _,category in pairs(fuel_item_category) do
    for _,lua_item in pairs(category) do
      setStyle(fuel_table.add{type='choose-elem-button',elem_type='item',item=lua_item.name,tags={[pre.."FNEI"]=true}},{}).locked=true
    -- setStyle(resource_table.add{type='label',caption=lua_entity.localised_name},{horizontally_stretchable=true,horizontal_align='left'})
      setStyle(fuel_table.add{type='label',caption=lua_item.localised_name,tooltip={"",lua_item.localised_name,"\n",lua_item.name}},{horizontally_stretchable=true,horizontal_align='left'})
      setStyle(fuel_table.add{type='label',caption=SI(lua_item.fuel_value)..'J '}                                 ,{width=100,horizontal_align='center'})
      setStyle(fuel_table.add{type='label',caption=lua_item.fuel_category}                                        ,{width=150,horizontal_align='center'})
      setStyle(fuel_table.add{type='label',caption=(lua_item.fuel_emissions_multiplier*100)..'%'}                 ,{width=100,horizontal_align='center'})
      setStyle(fuel_table.add{type='label',caption=(lua_item.fuel_acceleration_multiplier*100)..'%'}              ,{width=100,horizontal_align='center'})
      setStyle(fuel_table.add{type='label',caption=(lua_item.fuel_top_speed_multiplier*100)..'%'}                 ,{width=100,horizontal_align='center'})    
      if lua_item.burnt_result then  
        setStyle(fuel_table.add{type='choose-elem-button',elem_type='item',item=lua_item.burnt_result.name,tags={[pre.."FNEI"]=true}},{}).locked=true    
      else
        fuel_table.add{type='empty-widget'}
      end
    end
  end

  local fluids = get_fluid_proto()  
  for _,fluid in pairs(fluids) do 
    local lua_fluid = prototypes.fluid[fluid.name]
    if lua_fluid.fuel_value>0 then
      setStyle(fuel_table.add{type='choose-elem-button',elem_type='fluid',fluid=lua_fluid.name,tags={[pre.."FNEI"]=true}},{}).locked=true
    -- setStyle(resource_table.add{type='label',caption=lua_entity.localised_name},{horizontally_stretchable=true,horizontal_align='left'})
      setStyle(fuel_table.add{type='label',caption=lua_fluid.localised_name,tooltip={"",lua_fluid.localised_name,"\n",lua_fluid.name}},{horizontally_stretchable=true,horizontal_align='left'})
      setStyle(fuel_table.add{type='label',caption=SI(lua_fluid.fuel_value)..'J '}                                 ,{width=100,horizontal_align='center'})
      setStyle(fuel_table.add{type='label',caption='fluid'                }                                        ,{width=150,horizontal_align='center'})
      setStyle(fuel_table.add{type='label',caption=(lua_fluid.emissions_multiplier*100)..'%'}                 ,{width=100,horizontal_align='center'})
      setStyle(fuel_table.add{type='label',caption='N/A'                                         }                 ,{width=100,horizontal_align='center'})
      setStyle(fuel_table.add{type='label',caption='N/A'                                         }                 ,{width=100,horizontal_align='center'})    
      fuel_table.add{type='empty-widget'}
      
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
  setStyle(resource_table.add{type='label',caption=""                            },{          horizontal_align='left'    })
  setStyle(resource_table.add{type='label',caption={"gui-map-editor.resources"  }},{width=100,horizontal_align='left'    })
  setStyle(resource_table.add{type='label',caption={"description.mining-time"   }},{width=100,horizontal_align='center'  })
  setStyle(resource_table.add{type='label',caption={"description.products"      }},{width=100,horizontal_align='center'  })
  --setStyle(resource_table.add{type='label',caption=surface.name                  },{width=100,horizontal_align='center'  })
  setStyle(resource_table.add{type='label',caption={"space-location-name.nauvis"}},{width=100,horizontal_align='center'  })
  setStyle(resource_table.add{type='label',caption={"description.required-fluid"}},{width=100,horizontal_align='center'  })
  setStyle(resource_table.add{type='label',caption={pre.."infinity"             }},{width=100,horizontal_align='center'  })

  for resource,_ in pairs(storage.item_special_type['resource']) do
    local lua_entity = prototypes.entity[resource]
    setStyle(resource_table.add{type='choose-elem-button',elem_type='entity',entity=lua_entity.name},{}).locked=true
    -- setStyle(resource_table.add{type='label',caption=lua_entity.localised_name},{horizontally_stretchable=true,horizontal_align='left'})
    setStyle(resource_table.add{type='label',caption=lua_entity.localised_name,tooltip={"",lua_entity.localised_name,"\n",lua_entity.name}},{horizontally_stretchable=true,horizontal_align='left'})
    
    setStyle(resource_table.add{type='label',caption=lua_entity.mineable_properties.mining_time},{horizontally_stretchable=true,horizontal_align='center'})
    local products_flow = setStyle(resource_table.add{type='flow'},{horizontally_stretchable=true,horizontal_align='center'})
    for _,product in pairs(lua_entity.mineable_properties.products) do
      local info = makeProductInfo(
        (product.type=="item" and prototypes.item[product.name] or prototypes.fluid[product.name]).localised_name, 
        product.probability, product.amount, product.amount_min, product.amount_max
      )
      -- local product_button = products_flow.add{type='sprite-button', sprite=product.type..'/'..product.name, number=amount, tooltip = {"",(product.type=="item" and prototypes.item[product.name] or prototypes.fluid[product.name]).localised_name," ",amount}}
      local product_button = products_flow.add{type='sprite-button', sprite=product.type..'/'..product.name, number=info.avg, tooltip = info.description,
                                               tags={[pre.."FNEI"]={type=product.type,value=product.name}}}
    end
    local setting = surface.map_gen_settings.autoplace_controls[lua_entity.name]
    setStyle(resource_table.add{type='label',caption=(setting and setting.frequency~=0) and "O" or "X"},{horizontally_stretchable=true,horizontal_align='center'})
    if(lua_entity.mineable_properties.required_fluid ) then
      local mineable_properties = lua_entity.mineable_properties
      local fluid_button = setStyle(resource_table.add{type='sprite-button', sprite="fluid/"..mineable_properties.required_fluid, number=mineable_properties.fluid_amount,
                                                       tooltip=prototypes.fluid[mineable_properties.required_fluid].localised_name,tags={[pre.."FNEI"]={type="fluid",value=mineable_properties.required_fluid} }},
                                   {horizontal_align='center'})
    else
      resource_table.add{type='empty-widget'}
    end
    setStyle(resource_table.add{type='label',caption=lua_entity.infinite_resource and "O" or "X"},{horizontally_stretchable=true,horizontal_align='center'})
  end
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
  setStyle(tile_table.add{type='label',caption=""                                                                                 },{          horizontal_align='left'    })
  setStyle(tile_table.add{type='label',caption={"gui-map-editor.tiles"     }                                                      },{width=160,horizontal_align='left'    })
  setStyle(tile_table.add{type='label',caption={pre.."craftable"           },tooltip={pre.."craftable_description"               }},{width=100,horizontal_align='center'  })
  setStyle(tile_table.add{type='label',caption={pre.."minable"             },tooltip={pre.."minable_description"                 }},{width=100,horizontal_align='center'  })
  setStyle(tile_table.add{type='label',caption={pre.."natural"             },tooltip={pre.."natural_description"                 }},{width=100,horizontal_align='center'  })
  setStyle(tile_table.add{type='label',caption={"description.walking-speed"}                                                      },{width=100,horizontal_align='center'  })
  setStyle(tile_table.add{type='label',caption={pre.."vehicle_friction"    }                                                      },{width=100,horizontal_align='center'  })
  setStyle(tile_table.add{type='label',caption={pre.."emission_absorption" },tooltip={pre.."tile_emission_absorption_description"}},{width=120,horizontal_align='center'  })


  for _,lua_tile in pairs(prototypes.tile) do
    -- local lua_entity = prototypes.entity[resource]
    setStyle(tile_table.add{type='choose-elem-button',elem_type='tile',tile=lua_tile.name},{}).locked=true
    -- setStyle(tile_table.add{type='sprite-button', sprite='tile/'..lua_tile.name,tooltip=colorText(lua_tile.map_color,lua_tile.localised_name)},{})
    
    
    -- setStyle(tile_table.add{type='label',caption={"",'[color='..lua_tile.map_color.r..","..lua_tile.map_color.g..","..lua_tile.map_color.b..']',lua_tile.localised_name,'[/color]'},tooltip=lua_tile.localised_name},{horizontally_stretchable=true,horizontal_align='left'})
    -- setStyle(tile_table.add{type='label',caption=lua_tile.localised_name},{horizontally_stretchable=true,horizontal_align='left'})
    setStyle(tile_table.add{type='label',caption=lua_tile.localised_name,tooltip={"",lua_tile.localised_name,"\n",lua_tile.name}},{horizontally_stretchable=true,horizontal_align='left'})
    

    local craftable = false
    if lua_tile.items_to_place_this then
      for _,item in pairs(lua_tile.items_to_place_this) do       
        if items[item.name] then
          -- setStyle(tile_table.add{type='label',caption=item.name},{horizontally_stretchable=true,horizontal_align='center'})
          local cratable_button = setStyle(tile_table.add{type='choose-elem-button',elem_type="item",item=item.name,caption=item.name,tags={[pre.."FNEI"]=true}},{horizontally_stretchable=true,horizontal_align='center'})
          cratable_button.locked=true  
          craftable = true
          break
        end
      end
    end
    if not craftable then
      setStyle(tile_table.add{type='label',caption=""},{horizontally_stretchable=true,horizontal_align='center'})
    end

    if lua_tile.mineable_properties.minable then      
      local product = (lua_tile.mineable_properties.products or {})[1] 
      if product then
        local mineable_button = setStyle(tile_table.add{type='choose-elem-button',elem_type="item",item=product.name,caption="",tags={[pre.."FNEI"]=true}},{horizontally_stretchable=true,horizontal_align='center'})
        mineable_button.locked=true
      else        
        local mineable_button = setStyle(tile_table.add{type='choose-elem-button',elem_type="item",tooltip={pre.."tile_without_product"}},{horizontally_stretchable=true,horizontal_align='center'})
        mineable_button.locked=true
      end
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
    --setStyle(tile_table.add{type='label',caption=(lua_tile.emissions_per_second*1000000*60)},{width=100,horizontal_align='center'})
    ----emissions_per_second->absorptions_per_second
    local absorption_caption={""}
    for pollution, absorb in pairs(lua_tile.absorptions_per_second) do
        table.insert(absorption_caption,{"",{"airborne-pollutant-name."..pollution},"/",(absorb*1000000*60),"\n"})
    end
    setStyle(tile_table.add{type='label',caption=(absorption_caption)},{width=100,horizontal_align='center'})
    -- setStyle(tile_table.add{type='label',caption=(lua_tile.map_color.r..","..lua_tile.map_color.g..","..lua_tile.map_color.b)},{width=100,horizontal_align='center'})
    -- setStyle(tile_table.add{type='label',caption={"",'[color='..lua_tile.map_color.r..","..lua_tile.map_color.g..","..lua_tile.map_color.b..']',"■□",'[/color]'}},{horizontally_stretchable=true,horizontal_align='left'})


  end
end

function collection_page(page_name, player_index, element)  

  local collection_flow = element.add{type='flow',name=pre..'collection_flow'}  
  local collection_table = collection_flow.add{type='table',name=pre..'collection_table',column_count=7,draw_vertical_lines=false,draw_horizontal_lines=true,draw_horizontal_line_after_headers=true}  
  collection_table.style.column_alignments[1] = "left"
  collection_table.style.column_alignments[2] = "left"
  collection_table.style.column_alignments[3] = "center"
  collection_table.style.column_alignments[4] = "center"
  collection_table.style.column_alignments[5] = "center"
  collection_table.style.column_alignments[6] = "center"
  collection_table.style.column_alignments[7] = "center"
  -- collection_table.style.column_alignments[8] = "center"
  setStyle(collection_table.add{type='label',caption=""                                                                                },{          horizontal_align='left'    })
  setStyle(collection_table.add{type='label',caption={pre.."title_collection"   }                                                      },{width=120,horizontal_align='left'    })
  setStyle(collection_table.add{type='label',caption={pre.."category"           }                                                      },{width=100,horizontal_align='center'  })
  setStyle(collection_table.add{type='label',caption={"description.mining-time" }                                                      },{width=100,horizontal_align='center'  })
  setStyle(collection_table.add{type='label',caption={"description.health"      }                                                      },{width=100,horizontal_align='center'  })
  -- setStyle(collection_table.add{type='label',caption={pre.."natural"            },tooltip={pre.."natural_description"                 }},{width=100,horizontal_align='center'  })
  setStyle(collection_table.add{type='label',caption={"description.products"    }                                                      },{width=100,horizontal_align='center'  })
  setStyle(collection_table.add{type='label',caption={pre.."emission_absorption"},tooltip={pre.."emission_absorption_description"     }},{width=120,horizontal_align='center'  })

  function add_entity(lua_entity)
    
    setStyle(collection_table.add{type='choose-elem-button',elem_type="entity",entity=lua_entity.name},{}).locked=true
    -- setStyle(collection_table.add{type='sprite-button', sprite='entity/'..lua_entity.name,tooltip=colorText(lua_entity.map_color,lua_entity.localised_name)},{})
    setStyle(collection_table.add{type='label',caption=lua_entity.localised_name,tooltip={"",lua_entity.localised_name,"\n",lua_entity.name}},{horizontally_stretchable=true,horizontal_align='left'})
    
    setStyle(collection_table.add{type='label',caption=lua_entity.type},{horizontally_stretchable=true,horizontal_align='center'})
    setStyle(collection_table.add{type='label',caption=lua_entity.mineable_properties.mining_time},{horizontally_stretchable=true,horizontal_align='center'})
    setStyle(collection_table.add{type='label',caption=lua_entity.get_max_health()},{horizontally_stretchable=true,horizontal_align='center'})
    -- setStyle(collection_table.add{type='label',caption=lua_entity.autoplace_specification and "O" or "X"},{horizontally_stretchable=true,horizontal_align='center'})
    
    
    local products_flow = setStyle(collection_table.add{type='flow'},{horizontally_stretchable=true,horizontal_align='center'})
    for _,product in pairs(lua_entity.mineable_properties.products or {}) do
      local info = makeProductInfo(
        (product.type=="item" and prototypes.item[product.name] or prototypes.fluid[product.name]).localised_name, 
        product.probability, product.amount, product.amount_min, product.amount_max
      )
      local product_button = products_flow.add{type='sprite-button', sprite=product.type..'/'..product.name, number=info.avg, tooltip = info.description,tags={[pre.."FNEI"]={type=product.type,value=product.name}}}
    end

    local absorption_caption={""}
    for pollution, absorb in pairs(lua_entity.emissions_per_second) do
        table.insert(absorption_caption,{"",{"airborne-pollutant-name."..pollution},"/",(absorb~=0) and (absorb*-60) or 0,"\n"})
    end
    --setStyle(collection_table.add{type='label',caption=(lua_entity.emissions_per_second~=0) and lua_entity.emissions_per_second*-60 or ""},{horizontally_stretchable=true,horizontal_align='center'})
    setStyle(collection_table.add{type='label',caption=absorption_caption},{horizontally_stretchable=true,horizontal_align='center'})
  end

  local list   = {
    tree              = {},
    fish              = {},
    ['simple-entity'] = {}
  }
  for _,lua_entity in pairs(prototypes.entity) do
    if (lua_entity.type=="tree" or lua_entity.type=="fish" or lua_entity.type=="simple-entity") and lua_entity.autoplace_specification then
      local target_list = list[lua_entity.type]
      table.insert(target_list,lua_entity)
    end
  end
  for _,target_list in pairs(list) do
    for _,lua_entity in pairs(target_list) do
      add_entity(lua_entity)      
    end
  end
end


function enemy_page(page_name, player_index, element)  

  local enemy_flow = element.add{type='flow',name=pre..'enemy_flow'}  
  local enemy_table = enemy_flow.add{type='table',name=pre..'enemy_table',column_count=6,draw_vertical_lines=false,draw_horizontal_lines=true,draw_horizontal_line_after_headers=true}  
  enemy_table.style.column_alignments[1] = "left"
  enemy_table.style.column_alignments[2] = "left"
  enemy_table.style.column_alignments[3] = "center"
  enemy_table.style.column_alignments[4] = "center"
  enemy_table.style.column_alignments[5] = "center"
  enemy_table.style.column_alignments[6] = "center"
  setStyle(enemy_table.add{type='label',caption=""                         },{          horizontal_align='left'    })
  setStyle(enemy_table.add{type='label',caption={pre.."title_enemy"       }},{width=120,horizontal_align='left'    })
  setStyle(enemy_table.add{type='label',caption={pre.."category"          }},{width=100,horizontal_align='center'  })
  setStyle(enemy_table.add{type='label',caption={"description.health"     }},{width=100,horizontal_align='center'  })
  setStyle(enemy_table.add{type='label',caption={pre.."loot"              }},{width=100,horizontal_align='center'  })
  setStyle(enemy_table.add{type='label',caption={"description.resistances"}},{width=100,horizontal_align='center'  })

  function add_entity(lua_entity)
    -- setStyle(enemy_table.add{type='sprite-button', sprite='entity/'..lua_entity.name,tooltip=colorText(lua_entity.map_color,lua_entity.localised_name)},{})
    setStyle(enemy_table.add{type='choose-elem-button',elem_type="entity",entity=lua_entity.name},{}).locked=true
    
    setStyle(enemy_table.add{type='label',caption=lua_entity.localised_name,tooltip={"",lua_entity.localised_name,"\n",lua_entity.name}},{horizontally_stretchable=true,horizontal_align='left'})
    
    setStyle(enemy_table.add{type='label',caption=lua_entity.type},{horizontally_stretchable=true,horizontal_align='center'})
    setStyle(enemy_table.add{type='label',caption=lua_entity.get_max_health()},{horizontally_stretchable=true,horizontal_align='center'})
        
    local loots_flow = setStyle(enemy_table.add{type='flow'},{horizontally_stretchable=true,horizontal_align='center'})
    for _,loot in pairs(lua_entity.loot or {}) do
      local info = makeProductInfo(prototypes.item[loot.item].localised_name, loot.probability, nil, loot.count_min, loot.count_max)
      local loot_button = loots_flow.add{type='sprite-button', sprite='item/'..loot.item, number=info.avg, tooltip = info.description, tags={[pre.."FNEI"]={type="item",value=loot.item}}}
    end
    local resistances_description = {"","[font=default-bold]",{"description.resistances"},"[/font]"}
    for k,v in pairs(lua_entity.resistances or {}) do
      local sub_description={"","\n[font=default-bold]"}
      table.insert(sub_description,{"damage-type-name."..k})
      table.insert(sub_description," : [/font]"..v.decrease.."/"..math.floor(v.percent*100+0.5).."%")
      table.insert(resistances_description,sub_description)
    end
    setStyle(enemy_table.add{type='sprite-button', sprite='utility/search',tooltip=resistances_description},{})
  end

  local list   = {
    unit              = {},
    turret            = {},
    ['unit-spawner']  = {},
    ['segmented-unit']= {},
    ['spider-unit']   = {}
  }
  for _,lua_entity in pairs(prototypes.entity) do
    --if lua_entity.type=="unit" or lua_entity.type=="segmented-unit" or ((lua_entity.type=="turret" or lua_entity.type=="unit-spawner") and lua_entity.autoplace_specification) then
    if lua_entity.subgroup.name=="enemies" then
      --local target_list = list[lua_entity.type]
      --target_list[lua_entity.name]=lua_entity
      add_entity(lua_entity)      
    end
  end

  ----get spawned unit list
  --local spawn_unit = {}
  --for _,lua_entity in pairs(list["unit-spawner"]) do
  --  for _,unit_spawn_def in pairs(lua_entity.result_units) do
  --    spawn_unit[unit_spawn_def.unit]=true
  --  end
  --end
  ----remove not spawned unit
  --for _,lua_entity in pairs(list["unit"]) do
  --  if not spawn_unit[lua_entity.name]==true then
  --    list["unit"][lua_entity.name] = nil
  --  end
  --end

  --for _,target_list in pairs(list) do
  --  for _,lua_entity in pairs(target_list) do
  --    add_entity(lua_entity)      
  --  end
  --end
end

function spoil_page(page_name, player_index, element)  
  local spoil_flow = element.add{type='flow',name=pre..'spoil_flow',direction='vertical'}

  local spoil_table = spoil_flow.add{type='table',name=pre..'spoil_table',column_count=4,draw_vertical_lines=false,draw_horizontal_lines=true,draw_horizontal_line_after_headers=true}  
  spoil_table.style.column_alignments[1] = "left"
  spoil_table.style.column_alignments[2] = "left"
  spoil_table.style.column_alignments[3] = "center"
  --spoil_table.style.column_alignments[4] = "center"
  spoil_table.style.column_alignments[4] = "center"
  setStyle(spoil_table.add{type='label',caption=""                               },{          horizontal_align='left'    })
  setStyle(spoil_table.add{type='label',caption={"tooltip-category.spoilable"    }},{width=100,horizontal_align='left'    })
  setStyle(spoil_table.add{type='label',caption={"description.spoil-time"        }},{width=100,horizontal_align='center'  })
  --setStyle(spoil_table.add{type='label',caption={pre.."category"                }},{width=100,horizontal_align='center'  })
  setStyle(spoil_table.add{type='label',caption={"description.spoil-result"      }},{width=100,horizontal_align='center'  })



  local items = get_item_proto()
  for _,item in pairs(items) do 
    local lua_item = prototypes.item[item.name]
    local spoil_ticks = lua_item.get_spoil_ticks()
    if spoil_ticks ~= 0 then
    --if lua_item.spoil_result or lua_item.spoil_to_trigger_result  then
      setStyle(spoil_table.add{type='choose-elem-button',elem_type='item',item=lua_item.name,tags={[pre.."FNEI"]=true}},{}).locked=true
    -- setStyle(resource_table.add{type='label',caption=lua_entity.localised_name},{horizontally_stretchable=true,horizontal_align='left'})
      setStyle(spoil_table.add{type='label',caption=lua_item.localised_name,tooltip={"",lua_item.localised_name,"\n",lua_item.name}},{horizontally_stretchable=true,horizontal_align='left'})
      setStyle(spoil_table.add{type='label',caption=(spoil_ticks/60).."s"}                                                                    ,{width=150,horizontal_align='center'})
      if lua_item.spoil_result then  
        setStyle(spoil_table.add{type='choose-elem-button',elem_type='item',item=lua_item.spoil_result.name,tags={[pre.."FNEI"]=true}},{}).locked=true    
      elseif lua_item.spoil_to_trigger_result then
        local trigger = lua_item.spoil_to_trigger_result.trigger[1]
        local valid=false
        if trigger.type=="direct" then
          if trigger.action_delivery[1].type=="instant" then
            if trigger.action_delivery[1].source_effects[1].type=="create-entity" then
              local entity_name = trigger.action_delivery[1].source_effects[1].entity_name
              setStyle(spoil_table.add{type='choose-elem-button',elem_type='entity',entity=entity_name},{}).locked=true    
              valid=true
            end
          end
        end
        if not valid then
            spoil_table.add{type='empty-widget'}
        end
      else
        spoil_table.add{type='empty-widget'}
      end
    end
  end


end
