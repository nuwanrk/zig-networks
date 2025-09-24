### Network Programming in Zig 

* [dns.zig](dns.zig) - A DNS server implementation.
```
$ hexdump -C query.data
00000000  25 97 01 20 00 01 00 00  00 00 00 00 06 67 6f 6f  |%.. .........goo|
00000010  67 6c 65 03 63 6f 6d 00  00 01 00 01              |gle.com.....|
0000001c
$
$
$ hexdump -C response.data
00000000  25 97 81 80 00 01 00 01  00 00 00 00 06 67 6f 6f  |%............goo|
00000010  67 6c 65 03 63 6f 6d 00  00 01 00 01 c0 0c 00 01  |gle.com.....?...|
00000020  00 01 00 00 00 02 00 04  8e fa be 4e              |.........??N|
0000002c
$
```
* [tcp.zig](tcp.zig) - A TCP/IP implementation.
* [snowcast.zig](snowcast.zig) - A streaming radio.
