const std = @import("std");
const raylib = @cImport(@cInclude("raylib.h"));
const raymath = @cImport(@cInclude("raymath.h"));
const physics = @import("physics.zig");
const Vec3 = @import("mathext.zig").Vec3;
const Object = @import("types.zig").Object;
const Target = @import("target.zig").Target;

pub const Object3D = struct {
    model: raylib.Model,
    texture: raylib.Texture,
    shader: raylib.Shader,
    position: Vec3,
    body: physics.RigidBody,
    scale: f32,
    pub fn new_with_model(model: raylib.Model, texture: raylib.Texture, shader: *raylib.Shader, scale: f32) Object3D {
        model.materials[0].shader = shader.*;
        model.materials[0].maps[raylib.MATERIAL_MAP_DIFFUSE].texture = texture;
        return Object3D{ .scale = scale, .model = model, .texture = texture, .position = Vec3.zero(), .body = physics.RigidBody.new(10, Vec3.zero()), .shader = shader.* };
    }
    pub fn new(texture: raylib.Texture, shader: *raylib.Shader, scale: f32) Object3D {
        const model = raylib.LoadModelFromMesh(raylib.GenMeshPlane(1, 1, 3, 3));
        model.materials[0].shader = shader.*;
        model.materials[0].maps[raylib.MATERIAL_MAP_DIFFUSE].texture = texture;
        return Object3D{ .scale = scale, .model = model, .texture = texture, .position = Vec3.zero(), .body = physics.RigidBody.new(10, Vec3.zero()), .shader = shader.* };
    }
};

pub fn init_objects(objects: *std.ArrayList(Object), global_shader: *raylib.Shader) void {
    const space_model = raylib.LoadModel("static/models/space.obj");
    const ground_model = raylib.LoadModel("static/models/untitled.obj");
    const texture = raylib.LoadTexture("static/textures/ground.png");

    var space = Object3D.new_with_model(space_model, texture, global_shader, 5);
    space.position = Vec3.new(0, -50, 0);
    var ground = Object3D.new_with_model(ground_model, texture, global_shader, 1);
    var target = Target.new(ground);

    objects.append(Object{ .target = target }) catch return;
    objects.append(Object{ .object = space }) catch return;
}
