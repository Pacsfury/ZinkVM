const std = @import("std");
const operations = @import("main.zig").operations;
const asmb = @import("assembler.zig");

pub fn run(program: []const u8, stack: *std.ArrayList(i32), allocator: std.mem.Allocator) !i32 {
    var pc: usize = 0;
    var memory = [_]i32{0} ** 256;
    var calls = std.ArrayList(i32).empty;
    defer calls.deinit(allocator);

    while (pc < program.len) {
        const op: operations = @enumFromInt(program[pc]);
        pc += 1;
        switch (op) {
            .nop => {},
            .push => {
                const val = program[pc];
                pc += 1;
                try stack.append(allocator, @as(i32, val));
            },
            .pop => {
                _ = stack.pop();
            },
            .add => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                try stack.append(allocator, a + b);
            },
            .sub => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                try stack.append(allocator, a - b);
            },
            .mul => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                try stack.append(allocator, a * b);
            },
            .div => {
                var b = stack.pop() orelse 1;
                const a = stack.pop() orelse 0;
                if (b == 0) {
                    b = 1;
                }
                try stack.append(allocator, @divTrunc(a, b));
            },
            .dup => {
                try stack.append(allocator, @as(i32, stack.items[stack.items.len - 1]));
            },
            .res => {
                std.debug.print("{}\n", .{if (stack.items.len > 0) stack.items[stack.items.len - 1] else 0});
            },
            .jmp => {
                const target = program[pc];
                pc = @as(usize, target);
            },
            .jiz => {
                if (stack.items[stack.items.len - 1] == 0) {
                    const target = program[pc];
                    pc = @as(usize, target);
                } else {
                    pc += 1;
                }
            },
            .jnz => {
                if (stack.items[stack.items.len - 1] != 0) {
                    const target = program[pc];
                    pc = @as(usize, target);
                } else {
                    pc += 1;
                }
            },
            .equ => {
                const a = stack.pop() orelse 0;
                const b = stack.pop() orelse 1;
                if (a == b) {
                    try stack.append(allocator, 1);
                } else {
                    try stack.append(allocator, 0);
                }
            },
            .neq => {
                const a = stack.pop() orelse 0;
                const b = stack.pop() orelse 1;
                if (a != b) {
                    try stack.append(allocator, 1);
                } else {
                    try stack.append(allocator, 0);
                }
            },
            .grt => {
                const a = stack.pop() orelse 0;
                const b = stack.pop() orelse 1;
                if (a > b) {
                    try stack.append(allocator, 1);
                } else {
                    try stack.append(allocator, 0);
                }
            },
            .smt => {
                const a = stack.pop() orelse 0;
                const b = stack.pop() orelse 1;
                if (a < b) {
                    try stack.append(allocator, 1);
                } else {
                    try stack.append(allocator, 0);
                }
            },
            .gre => {
                const a = stack.pop() orelse 0;
                const b = stack.pop() orelse 1;
                if (a >= b) {
                    try stack.append(allocator, 1);
                } else {
                    try stack.append(allocator, 0);
                }
            },
            .sme => {
                const a = stack.pop() orelse 0;
                const b = stack.pop() orelse 1;
                if (a <= b) {
                    try stack.append(allocator, 1);
                } else {
                    try stack.append(allocator, 0);
                }
            },
            .lor => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                try stack.append(allocator, a | b);
            },
            .land => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                try stack.append(allocator, a & b);
            },
            .lxor => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                try stack.append(allocator, a ^ b);
            },
            .lnot => {
                const x = stack.pop() orelse 0;
                try stack.append(allocator, ~x);
            },
            .bor => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                try stack.append(allocator, @intFromBool((a != 0) or (b != 0)));
            },
            .band => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                try stack.append(allocator, @intFromBool((a != 0) and (b != 0)));
            },
            .inc => {
                stack.items[stack.items.len - 1] = stack.items[stack.items.len - 1] + 1;
            },
            .dec => {
                stack.items[stack.items.len - 1] = stack.items[stack.items.len - 1] - 1;
            },
            .cout => {
                std.debug.print("{c}", .{@as(u8, @intCast(stack.items[stack.items.len - 1]))});
            },
            .swap => {
                const a = stack.pop() orelse 0;
                const b = stack.pop() orelse 0;
                try stack.append(allocator, @as(i32, b));
                try stack.append(allocator, @as(i32, a));
            },
            .cls => {
                stack.clearRetainingCapacity();
            },
            .mod => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                try stack.append(allocator, @mod(a, b));
            },
            .shl => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                try stack.append(allocator, a << @intCast(b));
            },
            .shr => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                try stack.append(allocator, a >> @intCast(b));
            },
            .jgt => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                if (a > b) {
                    pc = @as(usize, program[pc]);
                } else {
                    pc += 1;
                }
            },
            .jlt => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                if (a < b) {
                    pc = @as(usize, program[pc]);
                } else {
                    pc += 1;
                }
            },
            .jge => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                if (a >= b) {
                    pc = @as(usize, program[pc]);
                } else {
                    pc += 1;
                }
            },
            .jle => {
                const b = stack.pop() orelse 0;
                const a = stack.pop() orelse 0;
                if (a <= b) {
                    pc = @as(usize, program[pc]);
                } else {
                    pc += 1;
                }
            },
            .save => {
                const address = stack.pop() orelse 0;
                const value = stack.pop() orelse 0;
                if (@as(usize, @intCast(address)) < memory.len) {
                    memory[@as(usize, @intCast(address))] = value;
                }
            },
            .load => {
                const address = stack.pop() orelse 0;
                const u_address = @as(usize, @intCast(address));

                var value: i32 = 0;
                if (u_address < memory.len) {
                    value = memory[u_address];
                }

                try stack.append(allocator, value);
            },
            .sprint => {
                if (stack.items.len == 0) {
                    return error.EmptyStack;
                }
                const index = stack.items[stack.items.len - 1];
                const pool_index: usize = @intCast(index);
                if (pool_index >= asmb.constpool.items.len) {
                    return error.InvalidConstantIndex;
                }

                switch (asmb.constpool.items[pool_index]) {
                    .string => |value| std.debug.print("{s}\n", .{value}),
                    .float => |value| std.debug.print("{}\n", .{value}),
                }
            },
            .call => {
                try calls.append(allocator, @intCast(pc + 1));
                const target = program[pc];
                pc = @as(usize, target);
            },
            .ret => {
                if (calls.items.len == 0) {
                    return error.EmptyCallStack;
                }
                const return_address = calls.pop() orelse 0;
                pc = @intCast(return_address);
            },
        }
    }
    return if (stack.items.len > 0) stack.items[stack.items.len - 1] else 1;
}
