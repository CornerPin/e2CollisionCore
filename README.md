This Expression 2 extension adds functions for collision detection and a new `collision` data type.

List of functions:

`runOnCollision(entity ent, number activate)`
If set to 1, the chip will run when the specified entity collides with anything.

`number=collideClk()`
Returns 1 if the chip execution was caused by a collision.

`collision=getCollision()`
Returns the collision data from the last collision.

`vector=xcl:hitPos()`
Returns the collision position.

`entity=xcl:hitEntity()`
Returns the other collision entity.

`entity=xcl:ourEntity()`
Returns the collision entity.

`vector=xcl:ourOldVel()`
Returns the entity's velocity before the collision.

`vector=xcl:theirOldVel()`
Returns the other entity's velocity before the collision.

`number=xcl:delta()`
Returns the time since the last collision with the other entity.

`number=xcl:speed()`
Returns the speed of the entity before the collision.

`vector=xcl:hitNormal()`
Returns the normal of the surface that hit the other entity.

`table=xcl:toTable()`
Returns the collision data as a table.