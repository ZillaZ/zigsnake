const std = @import("std");
const raylib = @cImport(@cInclude("raylib.h"));

pub const Object3D = struct {
    model: raylib.Model,
    texture: raylib.Texture,
    shader: raylib.Shader,
    pub fn new(model: raylib.Model, texture: raylib.Texture, shader: raylib.Shader) Object3D {
        return Object3D {
            .model = model,
            .texture = texture,
            .shader = shader
        };
    }
};

pub fn init_objects(objects: *std.ArrayList(Object3D)) void {
    const model = raylib.LoadModel("/home/zillaz/Downloads/watermill.obj");
	const texture = raylib.LoadTexture("/home/zillaz/Downloads/watermill_diffuse.png");
	model.materials[0].maps[raylib.MATERIAL_MAP_DIFFUSE].texture = texture;
	const windmill = Object3D.new(model, texture, undefined);

	const ground_model = raylib.LoadModel("static/models/untitled.obj");
    const ground = Object3D.new(ground_model, undefined, undefined);
    objects.append(windmill) catch return;
    objects.append(ground) catch return;
}
