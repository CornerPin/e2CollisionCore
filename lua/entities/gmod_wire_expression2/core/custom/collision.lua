E2Lib.RegisterExtension("collision", false, "Lets E2 chips to detect entity collisions.")

local collisionRun = 0

local defaultCollision = {
	HitEntity = NULL,
	OurEntity = NULL,
	HitPos = vector_origin,
	OurOldVelocity = vector_origin,
	TheirOldVelocity = vector_origin,
	HitNormal = vector_origin,
	DeltaTime = 0,
	Speed = 0,
	Valid = false
}

local function createDefaultTable()
	return {
		n = {},
		ntypes = {},
		s = {},
		stypes = {
			HitEntity = "e",
			OurEntity = "e",
			HitPos = "v",
			OurOldVelocity = "v",
			TheirOldVelocity = "v",
			HitNormal = "v",
			DeltaTime = "n",
			Speed = "n"
		},
		size = 8
	}
end

---------------------------------------------------

registerType("collision", "xcl", defaultCollision,
	nil,
	nil,
	function(retval)
		if not istable(retval) then error("Return value is not a table, but a " .. type(retval) .. "!", 0) end
	end,
	function(v)
		return not istable(v) or not v.TheirOldVelocity
	end
)

registerOperator("ass", "xcl", "xcl", function(self, args)
	local lhs, op2, scope = args[2], args[3], args[4]
	local rhs = op2[1](self, op2)

	self.Scopes[scope][lhs] = rhs
	self.Scopes[scope].vclk[lhs] = true

	return rhs
end)

e2function number collision:operator_is()
	return this.Valid and 1 or 0
end

e2function number collision:operator==(collision other)
	return this == other and 1 or 0
end

e2function number collision:operator!=(collision other)
	return this ~= other and 1 or 0
end

---------------------------------------------------

__e2setcost(1)

e2function void runOnCollision(entity ent, number activate)
	if not IsValid(ent) then return end

	if ent.RunOnCollision == nil then
		ent.RunOnCollision = {}
	end
	
	if activate == 0 then
		ent.RunOnCollision[self.entity] = nil
		return
	end

	ent.RunOnCollision[self.entity] = true
	
	if ent.RunOnCollisionCallback ~= nil then
		return
	end

	ent.RunOnCollisionCallback = function(entity, data)
		for chip in pairs(ent.RunOnCollision) do
			if IsValid(chip) then
				data.OurEntity = entity
				data.Valid = true

				if chip.context then
					chip.context.CollisionData = data
					
					collisionRun = 1
					chip:Execute()
					collisionRun = 0
				end
			else
				ent.RunOnCollision[chip] = nil
			end
		end
	end
	
	ent:AddCallback("PhysicsCollide", ent.RunOnCollisionCallback)
end

e2function number collideClk()
	return collisionRun
end

e2function collision getCollision()
	return self.CollisionData or defaultCollision
end

e2function vector collision:hitPos()
	return Vector(this.HitPos)
end

e2function entity collision:hitEntity()
	return this.HitEntity
end

e2function entity collision:ourEntity()
	return this.OurEntity
end

e2function vector collision:ourOldVel()
	return Vector(this.OurOldVelocity)
end

e2function vector collision:theirOldVel()
	return Vector(this.TheirOldVelocity)
end

e2function number collision:delta()
	return this.DeltaTime
end

e2function number collision:speed()
	return this.Speed
end

e2function vector collision:hitNormal()
	return Vector(this.HitNormal)
end


-- Deprecated
__e2setcost(30)

e2function vector collision:pos()
	return Vector(this.HitPos)
end

e2function entity collision:entity()
	return this.HitEntity
end

e2function vector collision:normal()
	return Vector(this.HitNormal)
end

__e2setcost(5)

e2function table collision:toTable()
	local ret = createDefaultTable()

	for k, v in pairs(this) do
		local e2type = ret.stypes[k]

		if e2type then
			if e2type == "v" then
				ret.s[k] = Vector(v)
			else
				ret.s[k] = v
			end
		end
	end

	return ret
end

---------------------------------------------------

registerCallback("construct", function(self)
	self.CollisionData = table.Copy(defaultCollision)
end)