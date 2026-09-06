const std = @import("std");
const asmb = @import("assembler.zig");
const runner = @import("runner.zig");

pub const operations = enum(u8) { nop = 0x00, push = 0x01, pop = 0x02, add = 0x03, sub = 0x04, mul = 0x05, div = 0x06, dup = 0x07, res = 0x08, jmp = 0x09, jiz = 0x0a, jnz = 0x0b, equ = 0x0c, neq = 0x0d, grt = 0x0e, smt = 0x0f, gre = 0x10, sme = 0x11, lor = 0x12, land = 0x13, lxor = 0x14, lnot = 0x15, bor = 0x16, band = 0x17, inc = 0x18, dec = 0x19, cout = 0x1A, swap = 0x1B, cls = 0x1C, mod = 0x1D, shl = 0x1E, shr = 0x1F, jgt = 0x20, jlt = 0x21, jge = 0x22, jle = 0x23, save = 0x24, load = 0x25, sprint = 0x26 };

pub fn main(init: std.process.Init) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var stack = std.ArrayList(i32).empty;
    defer stack.deinit(allocator);
    defer asmb.bytes.deinit(allocator);
    defer asmb.deinitConstPool(allocator);

    try asmb.assemble(init.io, allocator);

    const result = try runner.run(asmb.bytes.items, &stack, allocator);
    std.debug.print("\nProgram exited with code {}\n", .{result});
}
