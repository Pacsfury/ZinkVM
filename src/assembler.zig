const std = @import("std");
const expect = std.testing.expect;

pub const Object = union(enum) {
    float: f64,
    string: []const u8,
};

pub var constpool = std.ArrayList(Object).empty;

pub var bytes = std.ArrayList(u8).empty;

pub fn deinitConstPool(allocator: std.mem.Allocator) void {
    for (constpool.items) |object| {
        switch (object) {
            .string => |value| allocator.free(value),
            .float => {},
        }
    }
    constpool.deinit(allocator);
    constpool = .empty;
}

pub fn assemble(io: std.Io, allocator: std.mem.Allocator) !void {
    bytes.clearRetainingCapacity();
    deinitConstPool(allocator);

    var file = try std.Io.Dir.cwd().openFile(io, "src/text.zmb", .{});
    defer file.close(io);

    var buf: [1024]u8 = undefined;
    const bytes_read = try file.readPositionalAll(io, &buf, 0);
    const content = buf[0..bytes_read];

    var iter = std.mem.splitScalar(u8, content, '\n');

    while (iter.next()) |line| {
        const token = std.mem.trim(u8, line, " \t\r");
        if (token.len == 0) continue;

        if (std.mem.startsWith(u8, token, "%SCONST")) {
            const literal = std.mem.trim(u8, token[7..], " \t");
            if (literal.len < 2 or literal[0] != '"' or literal[literal.len - 1] != '"') {
                return error.MissingStringConstant;
            }

            const value = try allocator.dupe(u8, literal[1 .. literal.len - 1]);
            try constpool.append(allocator, .{ .string = value });

            const idx: u8 = @intCast(constpool.items.len - 1);

            try bytes.append(allocator, 0x01); // Push
            try bytes.append(allocator, idx); // Pool constant ixd
            try bytes.append(allocator, 0x01); // Push
            try bytes.append(allocator, idx); // Saved at same pos
            try bytes.append(allocator, 0x24); // Save
        } else if (std.mem.startsWith(u8, token, "%FCONST")) {
            const literal = std.mem.trim(u8, token[6..], " \t");
            if (literal.len == 0) return error.MissingFloatConstant;
            const value = try std.fmt.parseFloat(f64, literal);

            try constpool.append(allocator, .{ .float = value });

            const idx: u8 = @intCast(constpool.items.len - 1);

            try bytes.append(allocator, 0x01); // Push
            try bytes.append(allocator, idx); // Pool constant ixd
            try bytes.append(allocator, 0x01); // Push
            try bytes.append(allocator, idx); // Saved at same pos
            try bytes.append(allocator, 0x24); // Save
        } else {
            const byte = std.fmt.parseInt(u8, token, 0) catch return error.InvalidOperation;
            try bytes.append(allocator, byte);
        }
    }
}
