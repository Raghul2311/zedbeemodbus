import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class ModbusServices {
  final String ip;
  final int port;
  final int unitId;

  ModbusServices({required this.ip, this.port = 502, this.unitId = 0});

  Future<List<int>> readRegisters(int startAddress, int count) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );

      final request = Uint8List.fromList([
        0x00, 0x01, 0x00, 0x00, 0x00, 0x06, unitId,
        0x03, // Function code (Read Holding Registers)
        (startAddress >> 8) & 0xFF,
        startAddress & 0xFF,
        (count >> 8) & 0xFF,
        count & 0xFF,
      ]);

      socket.add(request);
      await socket.flush();

      final completer = Completer<List<int>>();
      final buffer = <int>[];

      socket.listen((data) {
        buffer.addAll(data);
        if (!completer.isCompleted && buffer.length >= 9 + count * 2) {
          completer.complete(buffer);
        }
      });

      final response = await completer.future;
      socket.destroy();

      if (response.length >= 9 + count * 2) {
        List<int> values = [];
        for (int i = 0; i < count; i++) {
          int high = response[9 + i * 2];
          int low = response[9 + i * 2 + 1];
          values.add((high << 8) | low);
        }
        return values;
      } else {
        throw Exception("Invalid Modbus response");
      }
    } catch (e) {
      throw Exception("Modbus read error: $e");
    }
  }

  Future<void> writeRegister(int address, int value) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );

      final request = Uint8List.fromList([
        0x00, 0x02, 0x00, 0x00, 0x00, 0x06, unitId,
        0x06, // Function code (Write Single Register)
        (address >> 8) & 0xFF,
        address & 0xFF,
        (value >> 8) & 0xFF,
        value & 0xFF,
      ]);

      socket.add(request);
      await socket.flush();

      await Future.delayed(const Duration(milliseconds: 200));
      socket.destroy();
    } catch (e) {
      throw Exception("Modbus write error: $e");
    }
  }
}
