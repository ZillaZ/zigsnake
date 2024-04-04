const raylib = @cImport(@cInclude("raylib.h"));
const playerLib = @import("player.zig");
const objectsLib = @import("objects.zig");
const std = @import("std");
const types = @import("types.zig");
const Vec3 = @import("mathext.zig").Vec3;
const lights = @import("lights.zig");

pub fn main() !void {
    //raylib.InitWindow(raylib.GetScreenWidth(), raylib.GetScreenHeight(), "Game muito FODA");
    raylib.InitWindow(800, 600, "Game muito FODA");
    raylib.SetTargetFPS(60);
    raylib.DisableCursor();
    raylib.SetConfigFlags(raylib.FLAG_MSAA_4X_HINT);
    //raylib.ToggleFullscreen();
    defer raylib.CloseWindow();

    var player = playerLib.Player.new();

    const allocator = std.heap.page_allocator;
    var objects = std.ArrayList(types.Object).init(allocator);
    defer objects.deinit();

    const shader = raylib.LoadShader(undefined, "static/shaders/shader.fs");

    var viewEyeLoc = raylib.GetShaderLocation(shader, "viewEye");
    var viewCenterLoc = raylib.GetShaderLocation(shader, "viewCenter");
    var runTimeLoc = raylib.GetShaderLocation(shader, "runTime");
    var resolutionLoc = raylib.GetShaderLocation(shader, "resolution");
    const resolution = [2]c_int{ raylib.GetScreenWidth(), raylib.GetScreenHeight() };

    const aimTex = raylib.LoadTexture("static/textures/aim.png");
    const aim = raylib.LoadModelFromMesh(raylib.GenMeshCube(1, 1, 1));
    aim.materials[0].maps[raylib.MATERIAL_MAP_DIFFUSE].texture = aimTex;
    raylib.SetShaderValue(shader, resolutionLoc, &resolution, raylib.SHADER_UNIFORM_VEC2);

    var sh = raylib.LoadShader("static/shaders/lighting.vs", "static/shaders/lightning.fs");
    sh.locs[raylib.SHADER_LOC_VECTOR_VIEW] = raylib.GetShaderLocation(sh, "viewPos");
    objectsLib.init_objects(&objects, &sh);
    // NOTE: "matModel" location name is automatically assigned on shader loading,
    // no need to get the location again if using that uniform name
    //shader.locs[SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel");

    // Ambient light level (some basic lighting)
    const ambientLoc = raylib.GetShaderLocation(sh, "ambient");
    std.debug.print("aqui ó{}\n", .{ambientLoc});
    raylib.SetShaderValue(sh, ambientLoc, &[4]f32{ 1.0, 0.1, 0.1, 1.0 }, raylib.SHADER_UNIFORM_VEC4);

    const light = lights.CreateLight(1, Vec3.new(0, 1, 0), Vec3.zero(), raylib.WHITE, &sh);

    while (!raylib.WindowShouldClose()) {

        //const ray = raylib.Ray{ .position = player.camera.position, .direction = player.camera.target };
        const cameraPos = [3]f32{ player.camera.position.x, player.camera.position.y, player.camera.position.z };
        const cameraTarget = [3]f32{ player.camera.target.x, player.camera.target.y, player.camera.target.z };
        raylib.SetShaderValue(shader, viewEyeLoc, &cameraPos, raylib.SHADER_UNIFORM_VEC3);
        raylib.SetShaderValue(shader, viewCenterLoc, &cameraTarget, raylib.SHADER_UNIFORM_VEC3);
        raylib.SetShaderValue(shader, runTimeLoc, &raylib.GetTime(), raylib.SHADER_UNIFORM_FLOAT);
        raylib.BeginDrawing();
        raylib.ClearBackground(raylib.WHITE);
        raylib.BeginShaderMode(shader);
        raylib.DrawRectangle(0, 0, raylib.GetScreenWidth(), raylib.GetScreenHeight(), raylib.WHITE);
        raylib.EndShaderMode();

        raylib.BeginMode3D(player.camera);
        player.update(&objects);
        raylib.SetShaderValue(sh, sh.locs[raylib.SHADER_LOC_VECTOR_VIEW], &cameraPos, raylib.SHADER_UNIFORM_VEC3);
        raylib.DrawSphereEx(raylib.Vector3{ .x = light.position.x, .y = light.position.y, .z = light.position.z }, 0.1, 8, 8, raylib.BLUE);

        raylib.DrawModel(aim, player.camera.target, 0.001, raylib.WHITE);

        for (objects.items) |*object| {
            object.update();
            const pos = object.GetPosition();
            const model = object.GetModel();
            raylib.DrawModel(model, pos.lib, object.GetScale(), raylib.Color{
                .a = 255,
                .r = 255,
                .g = 255,
                .b = 255,
            });
        }
        raylib.EndMode3D();
        raylib.EndDrawing();
    }
}
