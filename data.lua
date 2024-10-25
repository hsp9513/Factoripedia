-- style_name, filename, width, height -- style_name MUST be a completely unique name
-- informatron_make_image("example_image_1", "__example__/example_image.png", 200, 128) 

-- data:extend({{
--     type = "technology",
--     name = "dictionary_void-tech",
--     enabled = false,
--     icon_size = 64,
--     icons = {{
--         icon = "__base__/graphics/icons/lab.png",
--     }},
--     unit = {
--         count = 10,
--         ingredients = {{name="automation-science-pack", amount=1}},
--         time = 600
--     }
-- }})
data.raw['gui-style'].default["filter_group_button_tab_yellow"]=
{
  type = "button_style",
  --parent = "filter_group_button_tab",

  default_graphical_set =
  {
    base = {position = {363, 744}, corner_size = 8},
    shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
  }

}
