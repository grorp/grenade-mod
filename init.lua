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
