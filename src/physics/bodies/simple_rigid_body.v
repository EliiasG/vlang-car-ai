module bodies

import math.vec
import extmath as em
import math

const (
	rotate_amount = 0.001
)

pub struct RigidBody {
pub mut:
	position         vec.Vec2[f32]
	velocity         vec.Vec2[f32]
	rotation         f32
	angular_velocity f32
	mass             f32
}

pub fn (b &RigidBody) velocity_at(loc_pos vec.Vec2[f32]) vec.Vec2[f32] {
	r := vec.vec2[f32](loc_pos.y, -loc_pos.x).mul_scalar(math.tau * b.angular_velocity)
	return b.velocity + if b.to_global_force(vec.vec2[f32](1, 0)).x > 0 {
		r.mul_scalar(-1)
	} else {
		r
	}
}

pub fn (b &RigidBody) to_global(v vec.Vec2[f32]) vec.Vec2[f32] {
	return b.position + em.rotated(v, b.rotation)
}

pub fn (b &RigidBody) to_local(v vec.Vec2[f32]) vec.Vec2[f32] {
	diff := b.position - v
	return em.rotated(diff, b.rotation)
}

pub fn (mut b RigidBody) move() {
	b.position += b.velocity
	b.rotation += b.angular_velocity
	b.rotation = f32(math.mod(b.rotation, math.tau))
}

pub fn (b &RigidBody) to_global_force(force vec.Vec2[f32]) vec.Vec2[f32] {
	return em.rotated(force, b.rotation)
}

pub fn (b &RigidBody) to_local_force(force vec.Vec2[f32]) vec.Vec2[f32] {
	return em.rotated(force, -b.rotation)
}

pub fn (mut b RigidBody) apply_local_force(force vec.Vec2[f32], pos vec.Vec2[f32]) {
	b.apply_force(b.to_global_force(force), b.to_global(pos))
}

pub fn (mut b RigidBody) apply_force(force vec.Vec2[f32], pos vec.Vec2[f32]) {
	// return if no force
	if force.is_approx_zero(0.001) {
		return
	}
	// linear velocity
	b.velocity += force.div_scalar(b.mass)
	// angular velocity
	p := em.closest_point_on_line(b.position, pos, pos + force)
	// if force is pulling away from or towards center
	if p.eq_approx[f32, f32](b.position, 0.0001) {
		return
	}
	// calculate rotation speed
	ls := em.len_squared(p - b.position)
	v := ls / b.mass * bodies.rotate_amount * force.magnitude()
	// body position to force position
	bf := pos - b.position
	if bf.cross(force) > 0 {
		b.angular_velocity += v
	} else {
		b.angular_velocity -= v
	}
}
