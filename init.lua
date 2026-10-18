
-- global

pie = {}

-- mod check and settings

local hmod = core.get_modpath("hunger")
local hbmod = core.global_exists("hbhunger")
local stmod = core.global_exists("stamina")
local defmod = core.get_modpath("default")
local mclhunger = core.get_modpath("mcl_hunger")
local screwdriver_exists = core.get_modpath("screwdriver")
local quarters = core.settings:get_bool("pie.quarters")

-- sound support

local cake_sound = defmod and default.node_sound_dirt_defaults()

if core.get_modpath("mcl_sounds") then
	cake_sound = mcl_sounds.node_sound_dirt_defaults()
end

-- eat pie slice function

local function replace_pie(node, puncher, pos)

	if not puncher or not puncher:is_player() then return end

	local pname = puncher:get_player_name()

	-- is this my pie?
	if core.is_protected(pos, pname) then return end

	-- which size of pie did we hit?
	local pie = node.name:sub(1,-3)
	local num = tonumber(node.name:sub(-1))

	-- are we using crystal shovel to pick up full pie using soft touch?
	local tool = puncher:get_wielded_item():get_name()

	if num == 0 and tool == "ethereal:shovel_crystal" then

		local inv = puncher:get_inventory()

		core.remove_node(pos)

		if inv:room_for_item("main", {name = pie .. "_0"}) then
			inv:add_item("main", pie .. "_0")
		else
			pos.y = pos.y + 0.5
			core.add_item(pos, {name = pie .. "_0"})
		end

		return
	end

	-- eat slice or remove whole pie
	if num == 3 then

		core.remove_node(pos)

		core.check_for_falling(pos)

	elseif num < 3 then

		node.name = pie .. "_" .. (num + 1)

		core.swap_node(pos, node)
	end

	if num == 3 then core.check_for_falling(pos) end

	-- default eat sound
	local sound = "default_dig_crumbly"

	if hmod and hunger then -- Blockmen's hud_hunger mod

		local h = hunger.read(puncher)
		local ok = hunger.update_hunger(puncher, math.min(h + 4, 30))

		sound = "hunger_eat"

	elseif hbmod and hbhunger then -- Wuzzy's hbhunger mod

		local h = tonumber(hbhunger.hunger[pname])

		hbhunger.hunger[pname] = math.min(h + 4, 30)

		sound = "hbhunger_eat_generic"

	elseif stmod and stamina then -- Sofar or TenPlus1's stamina mod

		stamina.change(puncher, 4)

		sound = "stamina_eat"

	elseif mclhunger and mcl_hunger then -- mineclone2 mcl_hunger mod

		local h = mcl_hunger.get_hunger(puncher)

		mcl_hunger.set_hunger(puncher, math.min(h + 4, 20))

		sound = "mcl_hunger_bite"

	else -- none of the above found? add to health instead

		local h = puncher:get_hp()

		puncher:set_hp(math.min(h + 4, 20))
	end

	core.sound_play(sound, {pos = pos, gain = 0.7, max_hear_distance = 5}, true)
end

-- pie registration function

function pie.register_pie(name, desc)

	-- full pie

	local nodebox = {
		type = "fixed", fixed = {-0.45, -0.5, -0.45, 0.45, 0, 0.45}}

	local tiles = {
		name .. "_top.png", name .. "_bottom.png", name .. "_side.png",
		name .. "_side.png", name .. "_side.png", name .. "_side.png"}

	core.register_node(":pie:" .. name .. "_0", {
		description = desc,
		paramtype = "light",
		paramtype2 = "facedir",
		use_texture_alpha = "clip",
		sunlight_propagates = false,
		tiles = tiles,
		inventory_image = name .. "_inv.png",
		wield_image = name .. "_inv.png",
		drawtype = "nodebox",
		node_box = nodebox,
		sounds = cake_sound,

		on_rotate = screwdriver_exists and screwdriver.rotate_simple,

		on_punch = function(pos, node, puncher, pointed_thing)
			replace_pie(node, puncher, pos)
		end
	})

	-- 3/4 pie

	nodebox = {
		type = "fixed", fixed = {-0.45, -0.5, -0.25, 0.45, 0, 0.45}}

	tiles = {
		name .. "_top.png", name .. "_bottom.png", name .. "_side.png",
		name .. "_side.png", name .. "_side.png", name .. "_inside.png"}

	if quarters then

		nodebox.fixed = {
			{-0.45, -0.5, -0.45, 0, 0, 0.45},
			{-0.45, -0.5, 0, 0.45, 0, 0.45}}

		tiles = {
			name .. "_top.png", name .. "_bottom.png", name .. "_side_inside.png^[transformFX",
			name .. "_side.png", name .. "_side.png", name .. "_side_inside.png"}
	end

	core.register_node(":pie:" .. name .. "_1", {
		description = "3/4 " .. desc,
		paramtype = "light",
		paramtype2 = "facedir",
		use_texture_alpha = "clip",
		sunlight_propagates = true,
		tiles = tiles,
		groups = {not_in_creative_inventory = 1},
		drop = {},
		drawtype = "nodebox",
		node_box = nodebox,
		sounds = cake_sound,

		on_rotate = screwdriver_exists and screwdriver.rotate_simple,

		on_punch = function(pos, node, puncher, pointed_thing)
			replace_pie(node, puncher, pos)
		end
	})

	-- 1/2 pie

	nodebox = {
		type = "fixed", fixed = {-0.45, -0.5, 0.0, 0.45, 0, 0.45}}

	tiles = {
		name .. "_top.png", name .. "_bottom.png", name .. "_side.png",
		name .. "_side.png", name .. "_side.png", name .. "_inside.png"}

	if quarters then

		nodebox.fixed = {-0.45, -0.5, -.45, 0, 0, 0.45}

		tiles = {
			name .. "_top.png", name .. "_bottom.png", name .. "_inside.png",
			name .. "_side.png", name .. "_side.png", name .. "_side.png"}
	end

	core.register_node(":pie:" .. name .. "_2", {
		description = "Half " .. desc,
		paramtype = "light",
		paramtype2 = "facedir",
		use_texture_alpha = "clip",
		sunlight_propagates = true,
		tiles = tiles,
		groups = {not_in_creative_inventory = 1},
		drop = {},
		drawtype = "nodebox",
		node_box = nodebox,
		sounds = cake_sound,

		on_rotate = screwdriver_exists and screwdriver.rotate_simple,

		on_punch = function(pos, node, puncher, pointed_thing)
			replace_pie(node, puncher, pos)
		end
	})

	-- 1/4 pie

	tiles = {
		name .. "_top.png", name .. "_bottom.png", name .. "_side.png",
		name .. "_side.png", name .. "_side.png", name .. "_inside.png"}

	nodebox = {
		type = "fixed", fixed = {-0.45, -0.5, 0.25, 0.45, 0, 0.45}}

	if quarters then

		nodebox.fixed = {-0.45, -0.5, 0.0, 0.0, 0, 0.45}

		tiles = {
			name .. "_top.png", name .. "_bottom.png", name .. "_inside.png",
			name .. "_side.png", name .. "_side.png", name .. "_inside.png"}
	end

	core.register_node(":pie:" .. name .. "_3", {
		description = "Piece of " .. desc,
		paramtype = "light",
		paramtype2 = "facedir",
		use_texture_alpha = "clip",
		sunlight_propagates = true,
		tiles = tiles,
		groups = {not_in_creative_inventory = 1},
		drop = {},
		drawtype = "nodebox",
		node_box = nodebox,
		sounds = cake_sound,

		on_rotate = screwdriver_exists and screwdriver.rotate_simple,

		on_punch = function(pos, node, puncher, pointed_thing)
			replace_pie(node, puncher, pos)
		end
	})
end

-- register cakes

pie.register_pie("pie", "Cake")
pie.register_pie("choc", "Chocolate Cake")
pie.register_pie("scsk", "Strawberry Cheesecake")
pie.register_pie("coff", "Coffee Cake")
pie.register_pie("rvel", "Red Velvet Cake")
pie.register_pie("meat", "Meat Cake")
pie.register_pie("bana", "Banana Cake")
pie.register_pie("brpd", "Bread Pudding")
pie.register_pie("orange", "Orange Pie")

-- ingredients

local mcl = core.get_modpath("mcl_dye")
local i_sugar = mcl and "mcl_core:sugar" or "group:food_sugar"
local i_wheat = mcl and "mcl_farming:wheat_item" or "group:food_wheat"
local i_flour = mcl and "mcl_farming:bread" or "group:food_flour"
local i_egg = mcl and "mcl_throwing:egg" or "group:food_egg"
local i_milk = mcl and "mcl_mobitems:milk_bucket" or "group:food_milk_glass"
local i_cocoa = mcl and "mcl_dye:brown" or "group:food_cocoa"
local i_strawberry = mcl and "mcl_dye:red" or "group:food_strawberry"
local i_coffee = mcl and "mcl_dye:black" or "group:food_coffee"
local i_cheese = mcl and "mcl_dye:yellow" or "group:food_cheese"
local i_red = mcl and "mcl_dye:red" or "dye:red"
local i_meat = mcl and "mcl_mobitems:beef" or "group:food_meat_raw"
local i_banana = mcl and "mcl_dye:yellow" or "group:food_banana"
local i_bread = mcl and "mcl_farming:bread" or "group:food_bread"
local i_orange = mcl and "mcl_dye:orange" or "group:food_orange"
local i_bucket = mcl and "mcl_buckets:bucket_empty" or "bucket:bucket_empty"
local i_bottle = mcl and "mcl_potions:glass_bottle" or "vessels:glass_bottle"
local i_glass = mcl and "mcl_potions:glass_bottle" or "vessels:drinking_glass"

-- dye recipe items

if core.settings:get_bool("pie.dye_recipes") then

	i_sugar = mcl and "mcl_core:sugar" or "dye:white"
	i_egg = mcl and "mcl_throwing:egg" or "dye:cyan"
	i_milk = mcl and "mcl_mobitems:milk_bucket" or "dye:green"
	i_cocoa = mcl and "mcl_dye:brown" or "dye:brown"
	i_strawberry = mcl and "mcl_dye:red" or "dye:red"
	i_coffee = mcl and "mcl_dye:black" or "dye:black"
	i_cheese = mcl and "mcl_dye:yellow" or "dye:yellow"
	i_meat = mcl and "mcl_mobitems:beef" or "dye:pink"
	i_banana = mcl and "mcl_dye:yellow" or "dye:yellow"
	i_orange = mcl and "mcl_dye:orange" or "dye:orange"
end

-- replacement items

local replace_these = {
	{"mobs:bucket_milk", i_bucket},
	{"mobs:wooden_bucket_milk", "wooden_bucket:bucket_wood_empty"},
	{"mcl_mobitems:milk_bucket", i_bucket},
	{"petz:bucket_milk", i_bucket},
	{"cucina_vegana:soy_milk", i_bottle},
	{"group:food_milk_glass", i_glass}
}

-- normal cake recipe

core.register_craft({
	output = "pie:pie_0",
	recipe = {
		{i_sugar, i_milk, i_sugar},
		{i_sugar, i_egg, i_sugar},
		{i_wheat, i_flour, i_wheat}
	},
	replacements = replace_these
})

-- chocolate cake recipe

core.register_craft({
	output = "pie:choc_0",
	recipe = {
		{i_cocoa, i_milk, i_cocoa},
		{i_sugar, i_egg, i_sugar},
		{i_wheat, i_flour, i_wheat}
	},
	replacements = replace_these
})

-- strawberry cheesecake recipe

core.register_craft({
	output = "pie:scsk_0",
	recipe = {
		{i_strawberry, i_milk, i_strawberry},
		{i_sugar, i_egg, i_sugar},
		{i_wheat, i_flour, i_wheat}
	},
	replacements = replace_these
})

-- coffee cake recipe

core.register_craft({
	output = "pie:coff_0",
	recipe = {
		{i_coffee, i_milk, i_coffee},
		{i_sugar, i_egg, i_sugar},
		{i_wheat, i_flour, i_wheat}
	},
	replacements = replace_these
})

-- red velvet cake recipe

core.register_craft({
	output = "pie:rvel_0",
	recipe = {
		{i_cocoa, i_milk, i_red},
		{i_sugar, i_egg, i_sugar},
		{i_flour, i_cheese, i_flour}
	},
	replacements = replace_these
})

-- meat cake recipe

core.register_craft({
	output = "pie:meat_0",
	recipe = {
		{i_meat, i_egg, i_meat},
		{i_wheat, i_wheat, i_wheat}
	}
})

-- banana cake recipe

core.register_craft({
	output = "pie:bana_0",
	recipe = {
		{i_banana, i_milk, i_banana},
		{i_sugar, i_egg, i_sugar},
		{i_wheat, i_flour, i_wheat}
	},
	replacements = replace_these
})

-- bread pudding recipe

core.register_craft({
	output = "pie:brpd_0",
	recipe = {
		{i_bread, i_milk, i_bread},
		{i_sugar, i_egg, i_sugar},
		{i_wheat, i_flour, i_wheat}
	},
	replacements = replace_these
})

-- orange pie

core.register_craft({
	output = "pie:orange_0",
	recipe = {
		{i_orange, i_milk, i_orange},
		{i_sugar, i_egg, i_sugar},
		{i_wheat, i_flour, i_wheat}
	},
	replacements = replace_these
})

-- add lucky blocks

if core.get_modpath("lucky_block") then

	lucky_block:add_blocks({
		{"nod", "pie:pie_0", 0},
		{"nod", "pie:choc_0", 0},
		{"nod", "pie:coff_0", 0},
		{"tro", "pie:pie_0"},
		{"nod", "pie:rvel_0", 0},
		{"nod", "pie:scsk_0", 0},
		{"nod", "pie:bana_0", 0},
		{"nod", "pie:orange_0", 0},
		{"tro", "pie:orange_0", "default_place_node_hard", true},
		{"nod", "pie:brpd_0", 0},
		{"nod", "pie:meat_0", 0},
		{"lig"}
	})
end

-- some aliases for older pie mod by Mitroman

core.register_alias("pie:apie_0", "pie:pie_0")
core.register_alias("pie:apie_1", "pie:pie_1")
core.register_alias("pie:apie_2", "pie:pie_2")
core.register_alias("pie:apie_3", "pie:pie_3")
core.register_alias("pie:piebatter", "pie:pie_0")
core.register_alias("pie:apiebatter", "pie:pie_0")
core.register_alias("pie:amuffinbatter", "pie:pie_0")
core.register_alias("pie:applemuffin", "pie:pie_0")
core.register_alias("pie:sugar", "farming:sugar")
core.register_alias("pie:knife", "default:sword_steel")

print("[MOD] Pie loaded")
