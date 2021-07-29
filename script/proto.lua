local special_type = {tree=true,fish=true,resource=true,["simple-entity"]=true,["rocket-launch"]=true}

function reset_proto()
  dbg("reset_proto",true)
  global.proto={
    techs=nil,
    recipes=nil,
    items=nil,
    fluids=nil,
    entities=nil,
    recipe_categories=nil,
  }
  global.item_special_type={}
  for type,_ in pairs(special_type) do
    global.item_special_type[type]={}
  end
  global.craftring_machines = {}
  global.modules = nil
  global.groups = nil
end

function enable_item_by_products(products,source)
  dbg("enable_item_by_products"..source.name..source.type,false)
  products = products or {}
  source = source or {name="nil",type="nil"}
  for _,product in pairs(products) do
    local target=(product.type=="item") and global.proto.items[product.name] 
                                          or global.proto.fluids[product.name]
    target.enabled = true
    target.source[source.type] = true
    if special_type[source.type] then
      global.item_special_type[source.type][source.name]=true
    end
  end
end

function get_tech_proto()
  dbg("get_tech_proto",true)
  if not global.proto.techs then
    global.proto.techs={}
    local techs = global.proto.techs

    for _,tech in pairs(game.forces[1].technologies) do
      if tech.enabled then
        techs[tech.name] = {
          name=tech.name,
        }
      end
    end
  end
  return global.proto.techs
end

function get_recipe_proto()
  dbg("get_recipe_proto",true)
  if not global.proto.recipes then
    global.proto.recipes={}
    local recipes=global.proto.recipes
    local techs = get_tech_proto()  
    
    for _,recipe in pairs(game.recipe_prototypes) do
      recipes[recipe.name] = {
        name=recipe.name,
        enabled=recipe.enabled,
        module_info={},
      }      
    end
    for _,tech in pairs(techs) do
      for _,effect in pairs(game.technology_prototypes[tech.name].effects) do
        if effect.type=="unlock-recipe" then
          recipes[effect.recipe].enabled = true
        end
      end
    end
    for _,recipe in pairs(recipes) do
      if recipe.enabled==false then
        recipes[recipe.name]=nil
      end    
    end

  end
  return global.proto.recipes
end

function get_item_proto()
  dbg("get_item_proto",true)
  if not global.proto.items then
    global.proto.items={}
    global.proto.fluids={}
    local items=global.proto.items
    local fluids=global.proto.fluids
    local recipes = get_recipe_proto()  
    
    dbg("init_item_proto",true)
    for _,item in pairs(game.item_prototypes) do
      items[item.name] = {
        name=item.name,
        enabled=false,
        source={},
      }      
    end    
    for _,fluid in pairs(game.fluid_prototypes) do
      fluids[fluid.name] = {
        name=fluid.name,
        enabled=false,
        source={},
      }      
    end
    dbg("raw_item_proto",true)
    for _,entity in pairs(game.entity_prototypes) do
      if special_type[entity.type] then
        enable_item_by_products(entity.mineable_properties.products,{name=entity.name,type=entity.type})
      end
    end
    dbg("recipe_item_proto",true)
    for _,recipe in pairs(recipes) do
      enable_item_by_products(game.recipe_prototypes[recipe.name].products,{name=recipe.name,type="recipe"})  
    end    
    dbg("rocket_item_proto",true)
    for _,item in pairs(game.item_prototypes) do
      if items[item.name].enabled then
        enable_item_by_products(item.rocket_launch_products,{name=item.name,type="rocket-launch"})
      end
    end   
    dbg("remove_item_proto",true)
    for _,item in pairs(items) do
      if item.enabled==false then
        items[item.name]=nil
      end    
    end
    for _,fluid in pairs(fluids) do
      if fluid.enabled==false then
        fluids[fluid.name]=nil
      end    
    end

  end
  return global.proto.items
end

function get_fluid_proto()
  dbg("get_fluid_proto",true)
  if not global.proto.fluids then
    get_item_proto()
  end
  return global.proto.fluids
end

function get_entity_proto()
  dbg("get_entity_proto",true)
  if not global.proto.entities then
    global.proto.entities={}
    local entities=global.proto.entities
    local items = get_item_proto()  

    for _,entity in pairs(game.entity_prototypes) do
      entities[entity.name] = {
        name=entity.name,
        enabled=false,        
      }      
    end
    for _,item in pairs(items) do
      local place_result = game.item_prototypes[item.name].place_result
      if place_result then
        entities[place_result.name].enabled = true
      end      
    end
    for _,entity in pairs(entities) do
      if entity.enabled==false then
        entities[entity.name]=nil
      end    
    end

  end
  return global.proto.entities
end

function get_recipe_category_proto()
  dbg("get_recipe_category_proto",true)
  if not global.proto.recipe_categories then    
    global.proto.recipe_categories={}
    local recipe_categories=global.proto.recipe_categories
    local entities = get_entity_proto()  
    
    for _,recipe_category in pairs(game.recipe_category_prototypes) do      
      recipe_categories[recipe_category.name] = {
        name=recipe_category.name,
        enabled=false,        
      }      
    end
    for _,entity in pairs(entities) do
      local lua_entity = game.entity_prototypes[entity.name]
      if lua_entity.crafting_speed then
        global.craftring_machines[entity.name]=true
        for recipe_category,_ in pairs(lua_entity.crafting_categories ) do
          recipe_categories[recipe_category].enabled=true
        end
      end
    end
    for _,recipe_category in pairs(recipe_categories) do
      if recipe_category.enabled==false then
        recipe_categories[recipe_category.name]=nil
      end    
    end
  end
  return global.proto.recipe_categories
end

function get_modules()
  dbg("get_modules",true)
  if not global.modules then
    global.modules={}
    local modules=global.modules
    local items = get_item_proto()

    for _,item in pairs(items) do
      local lua_item = game.item_prototypes[item.name]
      if lua_item.type=='module' then
        local module_key=lua_item.subgroup.name..'.'..lua_item.category
        if not modules[module_key] then
          modules[module_key]={
            key=module_key,
            localised_name=lua_item.localised_name,
            icon=lua_item.name,
            enabled=false
          }
          local limitations=lua_item.limitations
          if #limitations>0 then
            modules[module_key].enabled=true
            for _,recipe_name in pairs(limitations) do
              local recipe=get_recipe_proto()[recipe_name]
              if recipe then                
                recipe.module_info[module_key]=true
              end
            end
          end
        else
          -- modules[module_key].localised_name=lua_item.localised_name
          modules[module_key].icon=item.name    
        end

      end
    end

  end
  return global.modules
end

function get_groups()
  dbg("get_groups",true)
  if not global.groups then
    global.groups={}
    for _,group in pairs(game.item_group_prototypes) do
      global.groups[group.name]={}
      for _,subgroup in pairs(group.subgroups) do
        global.groups[group.name][subgroup.name]={recipes={},items={},fluids={},entities={}}  
      end
    end

    for _,recipe in pairs(get_recipe_proto()) do
      local lua_recipe=game.recipe_prototypes[recipe.name]
      global.groups[lua_recipe.group.name][lua_recipe.subgroup.name].recipes[recipe.name]=true
    end

    for _,item in pairs(get_item_proto()) do
      local lua_item=game.item_prototypes[item.name]
      global.groups[lua_item.group.name][lua_item.subgroup.name].items[item.name]=true
    end
  end
  return global.groups
end