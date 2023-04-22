module bodies

import math.vec
import extmath as em

const (
	rotate_amount = 0.0001
)

pub struct RigidBody {
pub mut:
	position         vec.Vec2[f32]
	velocity         vec.Vec2[f32]
	rotation         f32
	angular_velocity f32
	mass             f32
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
