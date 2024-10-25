local special_type = {tree=true,fish=true,resource=true,["simple-entity"]=true,["rocket-launch"]=true}

function reset_proto()
  dbg("reset_proto",true)
  storage.proto={
    techs=nil,
    recipes=nil,
    items=nil,
    fluids=nil,
    entities=nil,
    recipe_categories=nil,
  }
  storage.item_special_type={}
  for type,_ in pairs(special_type) do
    storage.item_special_type[type]={}
  end
  storage.craftring_machines = {}
  storage.modules = nil
  storage.module_effects = nil
  storage.groups = nil
  storage.recipe_groups = nil
end

function enable_item_by_products(products,source)
  dbg("enable_item_by_products"..source.name..source.type,false)
  products = products or {}
  source = source or {name="nil",type="nil"}
  for _,product in pairs(products) do
    local target=(product.type=="item") and storage.proto.items[product.name] 
                                          or storage.proto.fluids[product.name]
    target.enabled = true
    target.source[source.type] = true
    if special_type[source.type] then
      storage.item_special_type[source.type][source.name]=true
    end
  end
end

function get_tech_proto()
  dbg("get_tech_proto",true)
  if not storage.proto.techs then
    storage.proto.techs={}
    local techs = storage.proto.techs

    for _,tech in pairs(game.forces[1].technologies) do
      if tech.enabled then
        techs[tech.name] = {
          name=tech.name,
        }
      end
    end
  end
  return storage.proto.techs
end

function get_recipe_proto()
  dbg("get_recipe_proto",true)
  if not storage.proto.recipes then
    storage.proto.recipes={}
    local recipes=storage.proto.recipes
    local techs = get_tech_proto()  
    
    for _,recipe in pairs(prototypes.recipe) do
      recipes[recipe.name] = {
        name=recipe.name,
        enabled=recipe.enabled,
        module_info={},
      }      
    end
    for _,tech in pairs(techs) do
      for _,effect in pairs(prototypes.technology[tech.name].effects) do
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
  return storage.proto.recipes
end

function get_item_proto()
  dbg("get_item_proto",true)
  if not storage.proto.items then
    storage.proto.items={}
    storage.proto.fluids={}
    local items=storage.proto.items
    local fluids=storage.proto.fluids
    local recipes = get_recipe_proto()  
    
    dbg("init_item_proto",true)
    for _,item in pairs(prototypes.item) do
      items[item.name] = {
        name=item.name,
        enabled=false,
        source={},
      }      
    end    
    for _,fluid in pairs(prototypes.fluid) do
      fluids[fluid.name] = {
        name=fluid.name,
        enabled=false,
        source={},
      }      
    end
    dbg("raw_item_proto",true)
    for _,entity in pairs(prototypes.entity) do
      if special_type[entity.type] then
        enable_item_by_products(entity.mineable_properties.products,{name=entity.name,type=entity.type})
      end
    end
    dbg("recipe_item_proto",true)
    for _,recipe in pairs(recipes) do
      enable_item_by_products(prototypes.recipe[recipe.name].products,{name=recipe.name,type="recipe"})  
    end    
    dbg("rocket_item_proto",true)
    for _,item in pairs(prototypes.item) do
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
  return storage.proto.items
end

function get_fluid_proto()
  dbg("get_fluid_proto",true)
  if not storage.proto.fluids then
    get_item_proto()
  end
  return storage.proto.fluids
end

function get_entity_proto()
  dbg("get_entity_proto",true)
  if not storage.proto.entities then
    storage.proto.entities={}
    local entities=storage.proto.entities
    local items = get_item_proto()  

    for _,entity in pairs(prototypes.entity) do
      entities[entity.name] = {
        name=entity.name,
        enabled=false,        
      }      
    end
    for _,item in pairs(items) do
      local place_result = prototypes.item[item.name].place_result
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
  return storage.proto.entities
end

function get_recipe_category_proto()
  dbg("get_recipe_category_proto",true)
  if not storage.proto.recipe_categories then    
    storage.proto.recipe_categories={}
    local recipe_categories=storage.proto.recipe_categories
    local entities = get_entity_proto()  
    
    for _,recipe_category in pairs(prototypes.recipe_category) do      
      recipe_categories[recipe_category.name] = {
        name=recipe_category.name,
        enabled=false,        
      }      
    end
    for _,entity in pairs(entities) do
      local lua_entity = prototypes.entity[entity.name]
      if lua_entity.crafting_speed then
        storage.craftring_machines[entity.name]=true
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
  return storage.proto.recipe_categories
end

function get_modules()
  dbg("get_modules",true)
  if not storage.modules then
    storage.modules={}
    local modules=storage.modules
    local items = get_item_proto()

    function add_module_tooltip(tooltip,lua_item)
      local effects = lua_item.module_effects
      local effects_tooltip = {"","  "}
      for k,v in pairs(effects) do
        table.insert(effects_tooltip, {""," ",{"description."..k.."-bonus"}," "..sign(round(v*100)).."%"})
      end
      table.insert(tooltip,{"","\n","[img=item/"..lua_item.name.."]",lua_item.localised_name,effects_tooltip})
    end

    for _,item in pairs(items) do
      local lua_item = prototypes.item[item.name]
      if lua_item.type=='module' then
        local module_key=lua_item.subgroup.name..'.'..lua_item.category
        if not modules[module_key] then
          modules[module_key]={
            key=module_key,
            localised_name=lua_item.localised_name,
            icon=lua_item.name,
            tooltip = {"","Module list"},--TODO
            enabled=false
          }
          add_module_tooltip(modules[module_key].tooltip, lua_item)
          ----LuaItemPrototypes.limitations is deleted!!
          --local limitations=lua_item.limitations
          --if #limitations>0 then
          --  modules[module_key].enabled=true
          --  for _,recipe_name in pairs(limitations) do
          --    local recipe=get_recipe_proto()[recipe_name]
          --    if recipe then                
          --      recipe.module_info[module_key]=true
          --    end
          --  end
          --end
        else
          -- modules[module_key].localised_name=lua_item.localised_name
          modules[module_key].icon=item.name    
          add_module_tooltip(modules[module_key].tooltip, lua_item)
        end

      end
    end

  end
  return storage.modules
end

function get_module_effects()
  dbg("get_module_effects",true)
  if not storage.module_effects then
    storage.module_effects={}
    local effects=storage.module_effects
    local items = get_item_proto()

    function add_module_tooltip(tooltip,lua_item)
      local effects = lua_item.module_effects
      local effects_tooltip = {"","  "}
      for k,v in pairs(effects) do
        table.insert(effects_tooltip, {""," ",{"description."..k.."-bonus"}," "..sign(round(v*100)).."%"})
      end
      table.insert(tooltip,{"","\n","[img=item/"..lua_item.name.."]",lua_item.localised_name,effects_tooltip})
    end

    local effect_names = {"speed","consumption","productivity","pollution","quality"}
    for _,effect_name in pairs(effect_names) do
      --local lua_item = prototypes.item[item.name]
      --local module_key=lua_item.subgroup.name..'.'..lua_item.category
      local enabled = false
      for _,recipe in pairs(get_recipe_proto()) do
        local lua_recipe=prototypes.recipe[recipe.name]
        if not lua_recipe.allowed_effects[effect_name] then                
          enabled = true
          break
        end
      end
      effects[effect_name] = {
          key=effect_name,
          localised_name={"description."..effect_name.."-bonus"},
          icon="", --TODO
          tooltip = {"","Module list"},--TODO
          enabled=enabled --TODO
      }

    end

  end
  return storage.module_effects
end

function get_groups()
  dbg("get_groups",true)
  if not storage.groups then
    storage.groups={}
    for _,group in pairs(prototypes.item_group) do
      storage.groups[group.name]={}
      for _,subgroup in pairs(group.subgroups) do
        storage.groups[group.name][subgroup.name]={recipes={},items={},fluids={},entities={}}  
      end
    end

    for _,recipe in pairs(get_recipe_proto()) do
      local lua_recipe=prototypes.recipe[recipe.name]
      storage.groups[lua_recipe.group.name][lua_recipe.subgroup.name].recipes[recipe.name]=true
    end

    for _,item in pairs(get_item_proto()) do
      local lua_item=prototypes.item[item.name]
      storage.groups[lua_item.group.name][lua_item.subgroup.name].items[item.name]=true
    end
  end
  return storage.groups
end

function get_recipe_groups()
  if not storage.recipe_groups then
    -- Make gorup table
    storage.recipe_groups={}
    local recipe_groups = storage.recipe_groups
    for _,group in pairs(prototypes.item_group) do
      storage.recipe_groups[group.name]=true
      -- game.print(group.name)
    end

    local valid_group = {}
    for _,recipe in pairs(get_recipe_proto()) do
      local lua_recipe = prototypes.recipe[recipe.name]
      valid_group[lua_recipe.group.name] = true
      -- game.print(lua_recipe.group.name)
    end

    for group,_ in pairs(recipe_groups) do
      if valid_group[group] ==nil then
        recipe_groups[group]=nil
      end
    end   
  end
  return storage.recipe_groups
end
