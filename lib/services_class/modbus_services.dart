import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class ModbusServices {
  final String ip;
  final int port;
  final int unitId;

  ModbusServices({required this.ip, this.port = 502, this.unitId = 1});

  // Read Holding Registers (Function code 0x03)
  Future<List<int>> readRegisters(int startAddress, int count) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );

      final transactionId = 0x0001;
      final protocolId = 0x0000;
      final length = 6; // unitId + function code + 4 bytes
      final functionCode = 0x03;

      final request = Uint8List.fromList([
        (transactionId >> 8) & 0xFF,
        transactionId & 0xFF,
        (protocolId >> 8) & 0xFF,
        protocolId & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
        unitId,
        functionCode,
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

      final response = await completer.future.timeout(
        const Duration(seconds: 5),
      );
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

  // Write Single Register (Function code 0x06)
  Future<void> writeRegister(int address, int value) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );

      final transactionId = 0x0002;
      final protocolId = 0x0000;
      final length = 6;
      final functionCode = 0x06;

      final request = Uint8List.fromList([
        (transactionId >> 8) & 0xFF,
        transactionId & 0xFF,
        (protocolId >> 8) & 0xFF,
        protocolId & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
        unitId,
        functionCode,
        (address >> 8) & 0xFF,
        address & 0xFF,
        (value >> 8) & 0xFF,
        value & 0xFF,
      ]);

      socket.add(request);
      await socket.flush();

      await Future.delayed(const Duration(milliseconds: 100));
      socket.destroy();
    } catch (e) {
      throw Exception("Modbus write error: $e");
    }
  }
}
