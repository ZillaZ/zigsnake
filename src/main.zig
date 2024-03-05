const raylib = @cImport(@cInclude("raylib.h"));
const playerLib = @import("player.zig");
const objectsLib = @import("objects.zig");
const std = @import("std");

pub fn main() !void {
	raylib.InitWindow(960, 540, "Game muito FODA");
	raylib.SetTargetFPS(60);
	raylib.DisableCursor();
	defer raylib.CloseWindow();

	var player = playerLib.Player.new();

	const allocator = std.heap.page_allocator;
	var objects = std.ArrayList(objectsLib.Object3D).init(allocator);
	objectsLib.init_objects(&objects);

	while (!raylib.WindowShouldClose()) {
		player.update();
		raylib.BeginDrawing();
		raylib.ClearBackground(raylib.RAYWHITE);
		raylib.BeginMode3D(player.camera);
		for (objects.items) |object| {
			raylib.DrawModel(object.model, raylib.Vector3 {.x=0,.y=0,.z=10}, 10.0, raylib.Color{.a=255, .r=255,.g=255,.b=255,});
		}
		raylib.EndMode3D();
		raylib.EndDrawing();
	}
}
