local t = minetest.get_translator("grenade")
dofile(minetest.get_modpath("grenade") .. "/api.lua")

local Grenade = {
	name = "grenade:grenade",
	description = t("Grenade"),
	texture = "grenade.png",
}

function Grenade.on_trigger(position)
	minetest.sound_play("grenade", {pos = position}, true)

	local radius = 5
	local max_damage = 15

	local objects = minetest.get_objects_inside_radius(position, radius)
	for _, object in pairs(objects) do
		local damage = vector.distance(position, object:get_pos())
		damage = radius - damage
		damage = damage / radius
		damage = damage * max_damage

		object:set_hp(
			object:get_hp() - damage,
			t("Grenade")
		)
	end
end

grenade.register(Grenade)

local GrenadePush = {
	name = "grenade:grenade_push",
	description = t("Push Grenade"),
	texture = "grenade_push.png",
}

function GrenadePush.on_trigger(position)
	minetest.sound_play("grenade", {pos = position}, true)

	local radius = 10
	local max_push = 30

	local objects = minetest.get_objects_inside_radius(position, radius)
	for _, object in pairs(objects) do
		local push = vector.distance(position, object:get_pos())
		push = radius - push
		push = push / radius
		push = push * max_push

		object:add_velocity(vector.direction(position, object:get_pos()) * push)
	end
end

grenade.register(GrenadePush)

local GrenadeSuck = {
	name = "grenade:grenade_suck",
	description = t("Suck Grenade"),
	texture = "grenade_suck.png",
}

function GrenadeSuck.on_trigger(position)
	minetest.sound_play("grenade", {pos = position}, true)

	local radius = 20
	local max_suck = 40

	local objects = minetest.get_objects_inside_radius(position, radius)
	for _, object in pairs(objects) do
		local suck = vector.distance(position, object:get_pos())
		suck = suck / radius
		suck = suck * max_suck

		object:add_velocity(
			(vector.new(0, 0, 0) - vector.direction(position, object:get_pos())) * suck
		)
	end
end

grenade.register(GrenadeSuck)

function darkness(pos)
    local pos_min = pos - vector.new(11, 11, 11)
    local pos_max = pos + vector.new(11, 11, 11)

    local vmanip = minetest.get_voxel_manip()

    vmanip:read_from_map(pos_min, pos_max)
    local vmanip_pos_min, vmanip_pos_max = vmanip:get_emerged_area()
    local vmanip_area = VoxelArea:new({MinEdge = vmanip_pos_min, MaxEdge = vmanip_pos_max})

    local light_data = vmanip:get_light_data()

    for ring = 0, 11 do
        for x = pos.x - ring, pos.x + ring do
            for y = pos.y - ring, pos.y + ring do
                for z = pos.z - ring, pos.z + ring do
                    if (
                        x == pos.x - ring or x == pos.x + ring or
                        y == pos.y - ring or y == pos.y + ring or
                        z == pos.z - ring or z == pos.z + ring
                    ) then
                        local index = vmanip_area:index(x, y, z)

                        local light_old = light_data[index] % 16
                        local light_new = (
                            ring <= 7 and 0 or
                            (ring - 7) * 3
                        )
                        if light_new > light_old then
                            light_new = light_old
                        end
                        light_data[index] = light_new
                    end
                end
            end
        end
    end

    vmanip:set_light_data(light_data)
    vmanip:write_to_map(false)
end

local GrenadeDarkness = {
	name = "grenade:grenade_darkness",
	description = t("Darkness Grenade"),
	texture = "grenade_darkness.png",
}

function GrenadeDarkness.on_trigger(pos)
	local pos_rounded = pos:round()
	minetest.sound_play("grenade_darkness_powder", {pos = pos_rounded}, true)
	darkness(pos_rounded)
end

grenade.register(GrenadeDarkness)
