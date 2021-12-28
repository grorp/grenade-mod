grenade = {}

function grenade.register(definition)
	local Grenade = {
		initial_properties = {
			physical = true,
			collisionbox = {
				-1/11 / 2,
				-1/11 / 2,
				-1/11 / 2,

				1/11 / 2,
				1/11 / 2,
				1/11 / 2
			},
			pointable = false,

			visual = "wielditem",
			visual_size = vector.new(1/2, 1/2, 1/2), -- This gives the entity the same size as a node.
			wield_item = definition.name .. "_visual",
		},
	}

	function Grenade:on_step(time_delta, movement)
		self.object:add_velocity(vector.new(0, -10 * time_delta, 0))

		local collision = movement.collisions[1]
		if collision then
			local collision_pos
			if collision.type == "node" then
				collision_pos = collision.node_pos
			end
			if collision.type == "object" then
				collision_pos = collision.object:get_pos()
			end

			self.object:remove()
			definition.on_trigger(collision_pos)
		end
	end

	minetest.register_entity(definition.name, Grenade)

	local GrenadeVisual = {
		wield_image = definition.texture,

		inventory_image = definition.texture,
		groups = {not_in_creative_inventory = 1},
	}

	minetest.register_craftitem(definition.name .. "_visual", GrenadeVisual)

	local GrenadeSpawner = {
		description = definition.description,
		inventory_image = definition.texture,
	}

	function GrenadeSpawner:on_use(player)
		local Grenade = minetest.add_entity(
			player:get_pos() + vector.new(0, player:get_properties().eye_height, 0),
			definition.name
		)
		local rotation = player:get_look_dir()
		rotation.y = 0
		rotation = vector.dir_to_rotation(rotation)
		rotation.y = rotation.y - math.pi / 2
		Grenade:set_rotation(rotation)
		Grenade:set_velocity(player:get_look_dir() * 30)

		if not minetest.is_creative_enabled(player:get_player_name()) then
			self:take_item()
		end
		return self
	end

	minetest.register_craftitem(definition.name .. "_spawner", GrenadeSpawner)
end
