const raylib = @cImport(@cInclude("raylib.h"));
const raymath = @cImport(@cInclude("raymath.h"));
const std = @import("std");
const physics = @import("physics.zig");
const Object = @import("types.zig").Object;
const Vec3 = @import("mathext.zig").Vec3;

pub const Player = struct {
    camera: raylib.Camera3D,
    speed: f32,
    pitch: f32,
    yaw: f32,
    fwd: raymath.Vector3,
    right: raymath.Vector3,
    body: physics.RigidBody,
    pub fn camera_movement(self: *Player) void {
        var delta_rotation = raylib.GetMouseDelta();
        self.pitch += delta_rotation.x / 500;
        self.yaw += delta_rotation.y / 500;
        self.yaw = raymath.Clamp(self.yaw, -1.5, 1.5);

        const target = raymath.Vector3Transform(raymath.Vector3{ .x = 0, .y = 0, .z = 1 }, raymath.MatrixRotateZYX(raymath.Vector3{ .x = self.yaw, .y = -self.pitch, .z = 0 }));
        self.fwd = raymath.Vector3Transform(raymath.Vector3{ .x = 0, .y = 0, .z = 1 }, raymath.MatrixRotateZYX(raymath.Vector3{ .x = self.yaw, .y = -self.pitch, .z = 0 }));
        self.right = raymath.Vector3{ .x = -self.fwd.z, .y = 0, .z = self.fwd.x };

        self.camera.target.x = self.camera.position.x + target.x * raylib.GetFrameTime();
        self.camera.target.y = self.camera.position.y + target.y * raylib.GetFrameTime();
        self.camera.target.z = self.camera.position.z + target.z * raylib.GetFrameTime();
    }
    pub fn update(self: *Player, objects: *std.ArrayList(Object)) void {
        physics.player_movement(self);
        //self.body.apply_gravity();
        self.camera_movement();
        self.fire(objects);
    }
    pub fn new() Player {
        return Player{ .camera = raylib.Camera3D{ .projection = raylib.CAMERA_PERSPECTIVE, .position = Vec3.zero().lib, .fovy = 90, .up = raylib.Vector3{ .x = 0, .y = 1, .z = 0 }, .target = Vec3.zero().lib }, .speed = 1.0, .pitch = 0, .yaw = 0, .fwd = raymath.Vector3{ .x = 0, .y = 0, .z = 1 }, .right = raymath.Vector3{ .x = 1, .y = 0, .z = 0 }, .body = physics.RigidBody.new(10, Vec3.zero()) };
    }
    pub fn fire(self: *Player, objects: *std.ArrayList(Object)) void {
        for (objects.items) |*object| {
            const ray = raylib.Ray{ .direction = Vec3.new(self.fwd.x, self.fwd.y, self.fwd.z).lib, .position = self.camera.position };
            object.hit(&ray);
        }
    }
};
