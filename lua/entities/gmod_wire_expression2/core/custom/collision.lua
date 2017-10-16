E2Lib.RegisterExtension( "collision", false, "Lets E2 chips to detect entity collisions." )


local collrun = 0
local DEFAULT_COLLISION = {
	HitPos = {0, 0, 0},
	HitEntity = Entity(0),
	OurEntity = Entity(0),
	OurOldVelocity = {0, 0, 0},
	DeltaTime = 0,
	TheirOldVelocity = {0, 0, 0},
	Speed = 0,
	HitNormal = {0, 0, 0},
	Valid = false
}
local DEFAULT_TABLE = {n={}, ntypes={}, s={}, stypes={}, size=0}

---------------------------------------------------
registerType("collision", "xcl", DEFAULT_COLLISION,
	nil,
	nil,
	function(retval)
		if !istable(retval) then error("Return value is not a collision, but a " .. type(retval) .. "!", 0) end
	end,
	function(v)
		return !istable(v) or not v.TheirOldVelocity
	end
)

registerOperator("ass", "xcl", "xcl", function(self, args)
	local lhs, op2, scope = args[2], args[3], args[4]
	local      rhs = op2[1](self, op2)

	self.Scopes[scope][lhs] = rhs
	self.Scopes[scope].vclk[lhs] = true
	return rhs
end)

e2function number collision:operator_is()
	return this.Valid and 1 or 0
end

e2function number collision:operator==( collision other )
	return this == other and 1 or 0
end

e2function number collision:operator!=( collision other )
	return this ~= other and 1 or 0
end

---------------------------------------------------
__e2setcost(1)

e2function void runOnCollision( entity ent, number activate )
	if not IsValid( ent ) then return end
	if ent.RunOnCollision == nil then ent.RunOnCollision = {} end
	
	if activate == 0 then
		ent.RunOnCollision[ self.entity ] = nil
	else
		ent.RunOnCollision[ self.entity ] = true
		
		if ent.RunOnCollisionCallback == nil then
			
			ent.RunOnCollisionCallback = function( entity, data )
				for chip in pairs( ent.RunOnCollision ) do
					if IsValid( chip ) then
					
						data.OurEntity = entity
						data.Valid = true
						chip.CollisionData = data
						
						collrun = 1
						chip:Execute()
						collrun = 0
						
					else
						ent.RunOnCollision[ chip ] = nil
					end
				end
			end
			
			ent:AddCallback( "PhysicsCollide", ent.RunOnCollisionCallback )
			
		end
	end
end

e2function number collideClk()
	return collrun
end

e2function collision getCollision()
	return self.entity.CollisionData or DEFAULT_COLLISION
end

e2function vector collision:hitPos()
	return this.HitPos
end

e2function entity collision:hitEntity()
	return this.HitEntity
end

e2function entity collision:ourEntity()
	return this.OurEntity
end

e2function vector collision:ourOldVel()
	return this.OurOldVelocity
end

e2function vector collision:theirOldVel()
	return this.TheirOldVelocity
end

e2function number collision:delta()
	return this.DeltaTime
end

e2function number collision:speed()
	return this.Speed
end

e2function vector collision:hitNormal()
	return this.HitNormal
end


-- Deprecated
__e2setcost(30)
e2function vector collision:pos()
	return this.HitPos
end

e2function entity collision:entity()
	return this.HitEntity
end

e2function vector collision:normal()
	return this.HitNormal
end

__e2setcost(5)

-- Lookup table for toTable
local ids = {
	["HitPos"] = "v",
	["HitEntity"] = "e",
	["OurEntity"] = "e",
	["OurOldVelocity"] = "v",
	["DeltaTime"] = "n",
	["TheirOldVelocity"] = "v",
	["Speed"] = "n",
	["HitNormal"] = "v"
}

e2function table collision:toTable()
	local ret = table.Copy(DEFAULT_TABLE)
	local size = 0

	for k, v in pairs( this ) do
		if ids[k] then
			ret.s[k] = v
			ret.stypes[k] = ids[k]
			size = size + 1
		end
	end

	ret.size = size

	return ret
end
---------------------------------------------------

registerCallback("construct", function(self)
	self.CollisionData = table.Copy(DEFAULT_COLLISION)
end)
