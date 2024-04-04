const std = @import("std");
const raylib = @cImport(@cInclude("raylib.h"));
const raymath = @cImport(@cInclude("raymath.h"));
const Object3D = @import("objects.zig").Object3D;
const Vec3 = @import("mathext.zig").Vec3;
const physics = @import("physics.zig");

pub const Target = struct {
    object: Object3D,
    goto: Vec3,
    pub fn new(object: Object3D) Target {
        return Target{ .object = object, .goto = Vec3.zero() };
    }
    pub fn warp(self: *Target) void {
        var prng = std.rand.DefaultPrng.init(blk: {
            var seed: u64 = 932921932912;
            std.os.getrandom(std.mem.asBytes(&seed)) catch return;
            break :blk seed;
        });
        const rand = prng.random();

        const new_x = rand.float(f32) * 10;
        const new_y = rand.float(f32) * 10;
        self.goto = Vec3.new(new_x, new_y, 0);

        physics.warp(&self.object, self.goto);
    }
    pub fn hit(self: *Target, ray: *const raylib.Ray) void {
        var box = raylib.GetModelBoundingBox(self.object.model);
        box.min = Vec3.new(box.min.x, box.min.y, box.min.z).add(self.object.position).lib;
        box.max = Vec3.new(box.max.x, box.max.y, box.max.z).add(self.object.position).lib;

        raylib.DrawBoundingBox(box, raylib.RED);
        raylib.DrawRay(ray.*, raylib.RED);
        const collision_box = raylib.GetRayCollisionBox(ray.*, box);

        if (!collision_box.hit) return;
        std.debug.print("POSITION: {}\n", .{collision_box.point});
        self.warp();
    }
};
