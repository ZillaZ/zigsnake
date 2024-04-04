const raymath = @cImport(@cInclude("raymath.h"));
const raylib = @cImport(@cInclude("raylib.h"));
const std = @import("std");
const Vec3 = @import("mathext.zig").Vec3;

const MAX_LIGHTS = 4; // Max dynamic lights supported by shader

pub const Light = struct {
    lightType: i32,
    enabled: bool,
    position: raymath.Vector3,
    target: raymath.Vector3,
    color: raylib.Color,

    // Shader locations
    enabledLoc: i32,
    typeLoc: i32,
    positionLoc: i32,
    targetLoc: i32,
    colorLoc: i32,
};

// Light type
pub const LightType = enum(u2) { LIGHT_DIRECTIONAL = 0, LIGHT_POINT = 1 };

// Global Variables Definition
//----------------------------------------------------------------------------------
var lightsCount: u8 = 0; // Current amount of created lights

//----------------------------------------------------------------------------------
// Module specific Functions Declaration
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------

// Create a light and get shader locations
pub fn CreateLight(lightType: i32, position: Vec3, target: Vec3, color: raylib.Color, shader: *raylib.Shader) Light {
    var light = Light{
        .enabled = true,
        .lightType = lightType,
        .position = position.math,
        .target = target.math,
        .color = color,

        .enabledLoc = raylib.GetShaderLocation(shader.*, "lights[0].enabled"),
        .typeLoc = raylib.GetShaderLocation(shader.*, "lights[0].type"),
        .positionLoc = raylib.GetShaderLocation(shader.*, "lights[0].position"),
        .targetLoc = raylib.GetShaderLocation(shader.*, "lights[0].target"),
        .colorLoc = raylib.GetShaderLocation(shader.*, "lights[0].color"),
    };

    UpdateLightValues(shader, &light);

    lightsCount += 1;

    return light;
}

// Send light properties to shader
// NOTE: Light shader locations should be available
pub fn UpdateLightValues(shader: *raylib.Shader, light: *Light) void {
    // Send to shader light enabled state and type
    raylib.SetShaderValue(shader.*, light.enabledLoc, &light.enabled, raylib.SHADER_UNIFORM_INT);
    raylib.SetShaderValue(shader.*, light.typeLoc, &light.lightType, raylib.SHADER_UNIFORM_INT);

    // Send to shader light position values
    const position = [3]f32{ light.position.x, light.position.y, light.position.z };
    raylib.SetShaderValue(shader.*, light.positionLoc, &position, raylib.SHADER_UNIFORM_VEC3);

    // Send to shader light target position values
    const target = [3]f32{ light.target.x, light.target.y, light.target.z };
    raylib.SetShaderValue(shader.*, light.targetLoc, &target, raylib.SHADER_UNIFORM_VEC3);

    // Send to shader light color values
    const r: f32 = @floatFromInt(light.color.r);
    const g: f32 = @floatFromInt(light.color.g);
    const b: f32 = @floatFromInt(light.color.b);
    const a: f32 = @floatFromInt(light.color.a);

    const color = [4]f32{ r / 255.0, g / 255.0, b / 255.0, a / 255.0 };
    std.debug.print("COLOR: {}\n", .{light.color});
    raylib.SetShaderValue(shader.*, light.colorLoc, &color, raylib.SHADER_UNIFORM_VEC4);
}
