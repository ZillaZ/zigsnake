const std = @import("std");
const raymath = @cImport(@cInclude("raymath.h"));
const playerLib = @import("player.zig");
const objectsLib = @import("objects.zig");
const raylib = @cImport(@cInclude("raylib.h"));
const Vec3 = @import("mathext.zig").Vec3;

const GRAVITY = 9.8;

pub const RigidBody = struct {
    mass: f32,
    speed: Vec3,
    pub fn apply_gravity(self: *RigidBody) void {
        const fall_speed = self.mass * GRAVITY * raylib.GetFrameTime();
        self.speed = Vec3.sub(self.speed, Vec3.new(0, fall_speed, 0));
    }
    pub fn new(mass: f32, speed: Vec3) RigidBody {
        return RigidBody{ .mass = mass, .speed = speed };
    }
};

pub fn warp(object: *objectsLib.Object3D, target: Vec3) void {
    object.position = target;
}

pub fn translate(object: *objectsLib.Object3D, position: Vec3) void {
    const normalized = Vec3.sub(position, object.position).normalized();
    const speed = raymath.Vector3Scale(normalized, 10 * raylib.GetFrameTime());
    object.position = raymath.Vector3Add(object.position, speed);
}

pub fn player_movement(player: *playerLib.Player) void {
    var movement_vector = raymath.Vector3{ .x = 0, .y = 0, .z = 0 };
    var fwd = player.fwd;
    if (raylib.IsKeyDown(raylib.KEY_SPACE)) {
        movement_vector.y += 1;
    }
    if (raylib.IsKeyDown(raylib.KEY_LEFT_SHIFT)) {
        movement_vector.y -= 1;
    }
    if (raylib.IsKeyDown(raylib.KEY_W)) {
        movement_vector = raymath.Vector3Add(movement_vector, fwd);
    }
    if (raylib.IsKeyDown(raylib.KEY_D)) {
        movement_vector = raymath.Vector3Add(movement_vector, player.right);
    }
    if (raylib.IsKeyDown(raylib.KEY_S)) {
        movement_vector = raymath.Vector3Add(movement_vector, raymath.Vector3Scale(fwd, -1));
    }
    if (raylib.IsKeyDown(raylib.KEY_A)) {
        movement_vector = raymath.Vector3Add(movement_vector, raymath.Vector3Scale(player.right, -1));
    }

    if (raymath.Vector3Length(movement_vector) < 1) {
        player.body.speed = Vec3.zero();
    }
    movement_vector = raymath.Vector3Normalize(movement_vector);
    movement_vector = raymath.Vector3Scale(movement_vector, player.speed * raylib.GetFrameTime());
    player.body.speed.math = raymath.Vector3Add(movement_vector, player.body.speed.math);

    player.body.speed.math = raymath.Vector3Normalize(player.body.speed.math);

    const aux = raymath.Vector3Add(raymath.Vector3{ .x = player.camera.position.x, .y = player.camera.position.y, .z = player.camera.position.z }, player.body.speed.math);
    player.camera.position.x = aux.x;
    player.camera.position.y = aux.y;
    player.camera.position.z = aux.z;
}
