// a simple DNS server in Zig
// references:
// https://www.cloudflare.com/learning/dns/what-is-dns/
// https://medium.com/@openmohan/dns-basics-and-building-simple-dns-server-in-go-6cb8e1cfe461
// https://reintech.io/blog/implementing-a-dns-server-in-go
// https://domenicoluciani.com/2024/05/07/create-dns-resolver.html
// https://github.com/EmilHernvall/dnsguide
// https://github.com/google/gopacket/blob/master/layers/dns.go

// echo 'hello udp server' | nc -uv 127.0.0.1 32100

const std = @import("std");
const net = std.net;
const posix = std.posix;
const print = std.debug.print;

pub fn main() !void {
    const server = DnsServer.init("127.0.0.1", 32100);
    try server.start();
    print("dns server is ready\n", .{});
}

pub const DnsServer = struct {
    ip_addr: []const u8,
    port: u16,

    pub fn init(ip_addr: []const u8, port: u16) DnsServer {
        return DnsServer{ .ip_addr = ip_addr, .port = port };
    }

    pub fn start(self: DnsServer) !void {
        const address = try std.net.Address.parseIp(self.ip_addr, self.port);
        const tpe: u32 = posix.SOCK.DGRAM;
        const protocol = posix.IPPROTO.UDP;
        const socket = try posix.socket(address.any.family, tpe, protocol);
        defer posix.close(socket);

        print("server started on: {s}:{d}\n", .{ self.ip_addr, self.port });

        try posix.bind(socket, &address.any, address.getOsSockLen());

        var buf: [1024]u8 = undefined;
        var result: [1024]u8 = undefined;
        const greet: []const u8 = "(dns server): ";

        @memcpy(result[0..greet.len], greet);

        while (true) {
            var client_address: net.Address = undefined;
            var client_address_len: posix.socklen_t = @sizeOf(net.Address);

            const n_recv = posix.recvfrom(socket, buf[0..], 0, &client_address.any, &client_address_len) catch |err| {
                print("error accepting connection: {}\n", .{err});
                continue;
            };

            print("{f} connected, recieved {d} byte(s), {s}\n", .{ client_address, n_recv, buf[0..n_recv] });
            @memcpy(result[greet.len..(greet.len + n_recv)], buf[0..n_recv]);

            write(socket, result[0..(greet.len + n_recv)], client_address, client_address_len) catch |err| {
                print("error writing: {}\n", .{err});
            };
        }
    }

    fn write(socket: posix.socket_t, msg: []const u8, client_address: net.Address, client_address_len: posix.socklen_t) !void {
        var pos: usize = 0;
        while (pos < msg.len) {
            const written = try posix.sendto(socket, msg[pos..], 0, &client_address.any, client_address_len);
            if (written == 0) {
                return error.closed;
            }
            pos += written;
        }
    }
};
