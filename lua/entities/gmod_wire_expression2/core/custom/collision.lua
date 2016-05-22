E2Lib.RegisterExtension( "collision", false, "Lets E2 chips to detect prop collisions." )


local collrun = 0
local DEFAULT_COL = {
	HitPos = {0, 0, 0},
	HitEntity = Entity(0),
	OurOldVelocity = {0, 0, 0},
	DeltaTime = 0,
	TheirOldVelocity = {0, 0, 0},
	Speed = 0,
	HitNormal = {0, 0, 0}
}
local DEFAULT_TABLE = {n={},ntypes={},s={},stypes={},size=0}
local targetEntities = {}

---------------------------------------------------
registerType("collision", "xcl", DEFAULT_COL,
	nil,
	nil,
	function(retval)
		if !istable(retval) then error("Return value is not a collision, but a "..type(retval).."!",0) end
	end,
	function(v)
		return !istable(v) or not v.Speed
	end
)

registerOperator("ass", "xcl", "xcl", function(self, args)
	local lhs, op2, scope = args[2], args[3], args[4]
	local      rhs = op2[1](self, op2)

	self.Scopes[scope][lhs] = rhs
	self.Scopes[scope].vclk[lhs] = true
	return rhs
end)

e2function number operator_is(collision col)
	if col then return 1 else return 0 end
end

---------------------------------------------------
__e2setcost(1)

e2function void runOnCollision( entity ent, number activate )
	if not IsValid( ent ) then return end
	if activate == 0 then
		if targetEntities[ent] == nil then return end
		targetEntities[ent] = false
	else
		if targetEntities[ent] == nil then
			ent:AddCallback( "PhysicsCollide", function( entity, data )
				if IsValid(self.entity) and targetEntities[ent] then
					self.CollisionData = data
					collrun = 1
					self.entity:Execute()
					collrun = 0
				end
			end)
		end
		targetEntities[ent] = true
	end
end

e2function number collideClk()
	return collrun
end

e2function collision getCollision()
	return self.CollisionData
end

-- Helper table used for toTable
local ids = {
	["HitPos"] = "v",
	["HitEntity"] = "e",
	["OurOldVelocity"] = "v",
	["DeltaTime"] = "n",
	["TheirOldVelocity"] = "v",
	["Speed"] = "n",
	["HitNormal"] = "v"
}

e2function vector collision:pos()
	return this.HitPos
end

e2function vector collision:entity()
	return this.HitEntity
end

e2function vector collision:ourOldVel()
	return this.OurOldVelocity
end

e2function vector collision:theirOldVel()
	return this.TheirOldVelocity
end

e2function vector collision:delta()
	return this.DeltaTime
end

e2function vector collision:speed()
	return this.Speed
end

e2function vector collision:normal()
	return this.HitNormal
end

__e2setcost(5)

e2function table collision:toTable()
	local ret = table.Copy(DEFAULT_TABLE)
	local size = 0
	for k, v in pairs( this ) do
		if (ids[k]) then
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
	self.CollisionData = table.Copy(DEFAULT_COL)
end)

hook.Add("EntityRemoved", "OnRemove", function( ent )
	if targetEntities[ent] then
		targetEntities[ent] = nil
	end
end)
