const raymath = @cImport(@cInclude("raymath.h"));
const raylib = @cImport(@cInclude("raylib.h"));

pub const Vec3 = struct {
    math: raymath.Vector3,
    lib: raylib.Vector3,
    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{
            .math = raymath.Vector3{ .x = x, .y = y, .z = z },
            .lib = raylib.Vector3{ .x = x, .y = y, .z = z },
        };
    }
    pub fn zero() Vec3 {
        return Vec3{
            .math = raymath.Vector3{ .x = 0, .y = 0, .z = 0 },
            .lib = raylib.Vector3{ .x = 0, .y = 0, .z = 0 },
        };
    }
    pub fn eq(vec1: Vec3, vec2: Vec3) bool {
        return vec1.x == vec2.x and vec1.y == vec2.y and vec1.z == vec2.z;
    }
    pub fn sub(vec1: Vec3, vec2: Vec3) Vec3 {
        return new(vec1.lib.x - vec2.lib.x, vec1.lib.y - vec2.lib.y, vec1.lib.z - vec2.lib.z);
    }
    pub fn math(self: *Vec3) raymath.Vector3 {
        return self.math;
    }
    pub fn lib(self: *Vec3) raylib.Vector3 {
        return self.lib;
    }
    pub fn normalized(self: *Vec3) void {
        const lenght = self.math.x + self.math.y + self.math.z;
        self.math.x /= lenght;
        self.math.y /= lenght;
        self.math.z /= lenght;
    }
    pub fn add(vec1: Vec3, vec2: Vec3) Vec3 {
        return Vec3{ .lib = raylib.Vector3{ .x = vec1.lib.x + vec2.lib.x, .y = vec1.lib.y + vec2.lib.y, .z = vec1.lib.z + vec2.lib.z }, .math = raymath.Vector3{ .x = vec1.lib.x + vec2.lib.x, .y = vec1.lib.y + vec2.lib.y, .z = vec1.lib.z + vec2.lib.z } };
    }
    pub fn scale(vec1: Vec3, scalar: f32) Vec3 {
        return new(vec1.lib.x * scalar, vec1.lib.y * scalar, vec1.lib.z * scalar);
    }
};
