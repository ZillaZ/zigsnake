const raymath = @cImport(@cInclude("raymath.h"));
const raylib = @cImport(@cInclude("raylib.h"));
const std = @import("std");
const targetLib = @import("target.zig");
const objectsLib = @import("objects.zig");
const Object3D = objectsLib.Object3D;
const Target = targetLib.Target;
const Vec3 = @import("mathext.zig").Vec3;

pub const Object = union(enum) {
    object: Object3D,
    target: Target,
    pub fn update(self: *Object) void {
        switch (self.*) {
            .object => return,
            .target => return,
        }
    }
    pub fn GetPosition(self: *Object) Vec3 {
        switch (self.*) {
            .object => |object| return object.position,
            .target => |target| return target.object.position,
        }
    }
    pub fn GetModel(self: *Object) raylib.Model {
        switch (self.*) {
            .object => |object| return object.model,
            .target => |target| return target.object.model,
        }
    }
    pub fn GetScale(self: *Object) f32 {
        switch (self.*) {
            .object => |object| return object.scale,
            .target => |target| return target.object.scale,
        }
    }
    pub fn hit(self: *Object, ray: *const raylib.Ray) void {
        switch (self.*) {
            .object => return,
            .target => |*target| target.hit(ray),
        }
    }
};
