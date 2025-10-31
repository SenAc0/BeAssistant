import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BeaconData {
  final String name;
  final String id;
  final int rssi;
  final String? uuid; // iBeacon UUID when available
  final int? major; // iBeacon major
  final int? minor; // iBeacon minor
  final int? txPower; // iBeacon measured power
  final String? manufacturerHex; // raw manufacturer data as hex when available
  DateTime lastSeen;

  BeaconData({
    required this.name,
    required this.id,
    required this.rssi,
    this.uuid,
    this.major,
    this.minor,
    this.txPower,
    this.manufacturerHex,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  String pretty() {
    if (uuid != null) {
      return 'iBeacon UUID: $uuid\nMajor: ${major ?? '-'} Minor: ${minor ?? '-'}\nRSSI: $rssi\nLast seen: ${lastSeen.toLocal()}';
    }
    if (manufacturerHex != null) {
      return 'Manufacturer: $manufacturerHex\nRSSI: $rssi\nLast seen: ${lastSeen.toLocal()}';
    }
    return 'Device: $name\nID: $id\nRSSI: $rssi\nLast seen: ${lastSeen.toLocal()}';
  }
}

class BeaconService {
  StreamSubscription? _scanSubscription;
  bool _isScanning = false;

  Future<void> startScanning({required Function(BeaconData) onBeaconFound, String? filterUuid}) async {
    await _checkPermissions();
    // start continuous scan until stopScanning is called
    await FlutterBluePlus.startScan();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final scanResult in results) {
        try {
          final adv = scanResult.advertisementData;

          String? manufacturerHex;
          String? uuid;
          int? major;
          int? minor;
          int? txPower;

          // manufacturerData: Map<int, List<int>> in many flutter_blue variants
          try {
            final md = adv.manufacturerData;
            // debug: print manufacturer map keys and values
            // (useful to check what the platform returns)
            print('manufacturerData keys: ${md.keys}');
            if (md.isNotEmpty) {
              // Try to find an iBeacon pattern 0x02 0x15 inside any manufacturer data entry
              bool parsed = false;
              for (final entry in md.entries) {
                final bytes = entry.value;
                if (bytes.length >= 4) {
                  // search for 0x02 0x15 sequence (iBeacon prefix) at any offset
                  for (int offset = 0; offset < bytes.length - 3; offset++) {
                    if (bytes[offset] == 0x02 && bytes[offset + 1] == 0x15) {
                      final start = offset + 2;
                      final remain = bytes.length - start;
                      if (remain >= 21) {
                        final uuidBytes = bytes.sublist(start, start + 16);
                        final sb = StringBuffer();
                        for (int i = 0; i < uuidBytes.length; i++) {
                          final part = uuidBytes[i].toRadixString(16).padLeft(2, '0');
                          sb.write(part);
                          if (i == 3 || i == 5 || i == 7 || i == 9) sb.write('-');
                        }
                        uuid = sb.toString();

                        final majIndex = start + 16;
                        major = (bytes[majIndex] << 8) + bytes[majIndex + 1];
                        minor = (bytes[majIndex + 2] << 8) + bytes[majIndex + 3];
                        txPower = (bytes[majIndex + 4] & 0xFF);
                        // convert to signed 8-bit
                        if (txPower > 127) txPower = txPower - 256;

                        parsed = true;
                        break;
                      }
                    }
                  }
                }
                if (parsed) break;
              }

              if (!parsed) {
                // fallback: show first entry as hex for debugging
                final entry = md.entries.first;
                manufacturerHex = entry.value.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
                print('No iBeacon pattern found in manufacturerData; first entry hex: $manufacturerHex');
              } else {
                print('Parsed iBeacon UUID: $uuid major:$major minor:$minor tx:$txPower');
              }
            }
          } catch (e) {
            print('Error leyendo manufacturerData: $e');
          }

          // If not iBeacon found, check serviceData for Eddystone (service UUID FEAA)
          if (uuid == null) {
            try {
              final sd = adv.serviceData;
              if (sd.isNotEmpty) {
                for (final e in sd.entries) {
                  final key = e.key.toString().toLowerCase();
                  final value = e.value;
                  if (key.contains('feaa') || key.contains('fe:aa') || key.contains('fe-aa')) {
                    // Eddystone or similar: store raw hex
                    if (value.isNotEmpty) {
                      manufacturerHex = value.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
                    }
                  }
                }
              }
            } catch (e) {
              // ignore
            }
          }

          final beacon = BeaconData(
            name: scanResult.device.name.isEmpty ? "Desconocido" : scanResult.device.name,
            id: scanResult.device.id.id,
            rssi: scanResult.rssi,
            uuid: uuid,
            major: major,
            minor: minor,
            txPower: txPower,
            manufacturerHex: manufacturerHex,
          );

          // Additional debug: if this matches the provided MAC or known name, print full advertisementData
          try {
            final targetMac = 'e6:a9:19:25:e6:ee'; // normalized lowercase
            final deviceId = scanResult.device.id.id.toLowerCase();
            final deviceName = scanResult.device.name;
            if (deviceId == targetMac || deviceName.contains('Holy')) {
              print('--- DEBUG MATCH for device $deviceId / name: $deviceName ---');
              print('RSSI: ${scanResult.rssi}');
              final advFull = scanResult.advertisementData;
              print('localName: ${advFull.localName}');
              print('txPowerLevel: ${advFull.txPowerLevel}');
              print('connectable: ${advFull.connectable}');
              print('serviceUuids: ${advFull.serviceUuids}');
              print('serviceData keys: ${advFull.serviceData.keys}');
              print('serviceData entries:');
              advFull.serviceData.forEach((k, v) {
                print('  key:$k value:${v.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
              });
              print('manufacturerData entries:');
              advFull.manufacturerData.forEach((k, v) {
                print('  key:$k value:${v.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
              });
              print('--- END DEBUG ---');
            }
          } catch (e) {
            print('Error printing debug details: $e');
          }

          // If filterUuid provided, compare normalized UUIDs (remove dashes, lowercase)
          if (filterUuid != null && filterUuid.trim().isNotEmpty) {
            final normFilter = filterUuid.replaceAll('-', '').toLowerCase();
            final beaconUuidNorm = beacon.uuid?.replaceAll('-', '').toLowerCase();
            if (beaconUuidNorm != null && beaconUuidNorm == normFilter) {
              onBeaconFound(beacon);
            }
          } else {
            onBeaconFound(beacon);
          }
        } catch (e) {
          print('Error procesando ScanResult: $e');
        }
      }
    });

    _isScanning = true;
    print("Escaneo iniciado...");
  }

  Future<void> stopScanning() async {
    await _scanSubscription?.cancel();
    // ensure scanner stopped
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    _isScanning = false;
    print("Escaneo detenido");
  }

  Future<void> _checkPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (!statuses.values.every((s) => s.isGranted)) {
      throw Exception("Permisos de Bluetooth o ubicación denegados");
    }

  final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      throw Exception("Bluetooth no está activado");
    }
  }

  bool get isScanning => _isScanning;
}

// Página de prueba
class TemporalDetector extends StatefulWidget {
  const TemporalDetector({Key? key}) : super(key: key);

  @override
  State<TemporalDetector> createState() => _TemporalDetectorState();
}

class _TemporalDetectorState extends State<TemporalDetector> {
  final BeaconService _beaconService = BeaconService();
  String _status = "Esperando detección...";
  List<BeaconData> _beacons = [];
  final TextEditingController _uuidController = TextEditingController();
  bool _isScanningLocal = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startScan() async {
    final target = _uuidController.text.trim();
    setState(() {
      _status = "Iniciando escaneo...";
      _isScanningLocal = true;
      _beacons = [];
    });

    await _beaconService.startScanning(onBeaconFound: (beacon) {
      setState(() {
        // update lastSeen time
        beacon.lastSeen = DateTime.now();

        // identify by UUID when available, otherwise by id
        final identifier = beacon.uuid ?? beacon.id;
        final existingIndex = _beacons.indexWhere((b) => (b.uuid ?? b.id) == identifier);
        if (existingIndex >= 0) {
          _beacons[existingIndex] = beacon;
        } else {
          _beacons.add(beacon);
        }
        _status = "Beacons detectados: ${_beacons.length}";
      });
    }, filterUuid: target.isEmpty ? null : target);
  }

  Future<void> _stopScan() async {
    await _beaconService.stopScanning();
    setState(() {
      _isScanningLocal = false;
      _status = "Escaneo detenido";
    });
  }

  @override
  void dispose() {
    _beaconService.stopScanning();
    _uuidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detector Temporal")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _uuidController,
                    decoration: const InputDecoration(
                      labelText: 'UUID (iBeacon) para filtrar',
                      hintText: 'xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isScanningLocal ? _stopScan : _startScan,
                  child: Text(_isScanningLocal ? 'Stop' : 'Start'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_status),
            const SizedBox(height: 12),
            Expanded(
              child: _beacons.isEmpty
                  ? Center(child: Text('Nada detectado'))
                  : ListView.builder(
                      itemCount: _beacons.length,
                      itemBuilder: (context, index) {
                        final b = _beacons[index];
                        return ListTile(
                          title: Text(b.name),
                          subtitle: Text(b.pretty()),
                          trailing: Text('${b.rssi} dBm', style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
