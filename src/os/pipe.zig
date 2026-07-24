const std = @import("std");
const builtin = @import("builtin");
const windows = @import("windows.zig");
const posix = std.posix;
const compat_fd = @import("../lib/compat/fd.zig");

/// pipe() that works on Windows and POSIX. For POSIX systems, this sets
/// CLOEXEC on the file descriptors.
pub fn pipe() ![2]posix.fd_t {
    switch (builtin.os.tag) {
        else => return compat_fd.pipe2(.{ .CLOEXEC = true }),
        .windows => {
            var read: windows.HANDLE = undefined;
            var write: windows.HANDLE = undefined;
            if (windows.exp.kernel32.CreatePipe(&read, &write, null, 0) == windows.FALSE) {
                return windows.unexpectedError(windows.GetLastError());
            }

            return .{ read, write };
        },
    }
}

/// Close one end of a `pipe()` fd. Cross-platform: on Windows the fd is a
/// real HANDLE (CloseHandle); on POSIX it is a descriptor. Zig 0.16 removed
/// the high-level `std.posix.close`, and the raw `posix.system.close`
/// references a libc `close` the MSVC target doesn't export — hence the
/// split.
pub fn close(fd: posix.fd_t) void {
    switch (builtin.os.tag) {
        .windows => windows.CloseHandle(fd),
        else => compat_fd.close(fd),
    }
}

/// Write a wake byte to a `pipe()` write end (the self-pipe trick). Errors
/// are swallowed: a broken/closed reader is exactly the state a wake is
/// racing against. Returns whether the byte was written.
pub fn wake(fd: posix.fd_t, byte: u8) bool {
    switch (builtin.os.tag) {
        .windows => {
            var written: windows.DWORD = 0;
            const buf = [_]u8{byte};
            return windows.exp.kernel32.WriteFile(fd, &buf, 1, &written, null) != windows.FALSE;
        },
        else => {
            const buf = [_]u8{byte};
            return posix.errno(posix.system.write(fd, &buf, 1)) == .SUCCESS;
        },
    }
}
