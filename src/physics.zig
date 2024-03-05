const std = @import("std");
const raymath = @cImport(@cInclude("raymath.h"));
const playerLib = @import("player.zig");
const objectsLib = @import("objects.zig");
const raylib = @cImport(@cInclude("raylib.h"));

const GRAVITY = 9.8;

pub const RigidBody = struct {
    mass: f32,
    speed: raymath.Vector3,
    pub fn apply_gravity(self: *RigidBody) void {
        const fall_speed = self.mass * GRAVITY * raylib.GetFrameTime();
        self.speed = raymath.Vector3Subtract(self.speed, raymath.Vector3 {.x = 0, .y = fall_speed, .z = 0});
    }
    pub fn new(mass: f32, speed: raymath.Vector3) RigidBody {
        return RigidBody {
            .mass = mass,
            .speed = speed
        };
    }
};

pub fn player_movement(player: *playerLib.Player) void {
    var movement_vector = raymath.Vector3 {.x = 0, .y = 0, .z = 0};

    if (raylib.IsKeyDown(raylib.KEY_SPACE)) {
        movement_vector.y += 1;
    }
    if (raylib.IsKeyDown(raylib.KEY_W)) {
        movement_vector = raymath.Vector3Add(movement_vector, player.fwd);
    }
    if (raylib.IsKeyDown(raylib.KEY_D)) {
        movement_vector = raymath.Vector3Add(movement_vector, player.right);
    }
    if (raylib.IsKeyDown(raylib.KEY_S)) {
        movement_vector = raymath.Vector3Add(movement_vector, raymath.Vector3Scale(player.fwd, -1));
    }
    if (raylib.IsKeyDown(raylib.KEY_A)) {
        movement_vector = raymath.Vector3Add(movement_vector, raymath.Vector3Scale(player.right, -1));
    }
    //player.body.apply_gravity();
    if (raymath.Vector3Length(movement_vector) < 1) {
        player.body.speed.x -= player.body.speed.x * 0.1;
        player.body.speed.z -= player.body.speed.z * 0.1;
    }
    movement_vector = raymath.Vector3Normalize(movement_vector);
    movement_vector = raymath.Vector3Scale(movement_vector, player.speed * raylib.GetFrameTime());
    player.body.speed = raymath.Vector3Add(movement_vector, player.body.speed);

    player.body.speed.x = raymath.Clamp(player.body.speed.x, -1, 1);
    player.body.speed.y = raymath.Clamp(player.body.speed.y, -1, 1);
    player.body.speed.z = raymath.Clamp(player.body.speed.z, -1, 1);

    const aux = raymath.Vector3Add(raymath.Vector3 {.x = player.camera.position.x, .y = player.camera.position.y, .z = player.camera.position.z }, player.body.speed);
    player.camera.position.x = aux.x;
    player.camera.position.y = 0;
    player.camera.position.z = aux.z;
}
