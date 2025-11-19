import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BeaconData {
  final String name;
  final String id;
  int rssi;
  final String? uuid; // iBeacon UUID when available
  final int? major; // iBeacon major
  final int? minor; // iBeacon minor
  final int? txPower; // iBeacon measured power
  final String? manufacturerHex; // raw manufacturer data as hex when available
  DateTime lastSeen;
  final List<int> _rssiHistory = [];

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

  void addRssi(int r) {
    _rssiHistory.add(r);
    if (_rssiHistory.length > 8) _rssiHistory.removeAt(0);
  }

  String pretty() {
    if (uuid != null) {
      return 'iBeacon UUID: $uuid\nMajor: ${major ?? '-'} Minor: ${minor ?? '-'}\nRSSI: ${rssi} dBm\nLast seen: ${lastSeen.toLocal()}';
    }
    if (manufacturerHex != null) {
      return 'Manufacturer: $manufacturerHex\nRSSI: ${rssi} dBm\nLast seen: ${lastSeen.toLocal()}';
    }
    return 'Device: $name\nID: $id\nRSSI: ${rssi} dBm\nLast seen: ${lastSeen.toLocal()}';
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

          try {
            final md = adv.manufacturerData;
            if (md.isNotEmpty) {
              bool parsed = false;
              for (final entry in md.entries) {
                final bytes = entry.value;
                if (bytes.length >= 4) {
                  for (int offset = 0; offset < bytes.length - 3; offset++) {
                    if (bytes[offset] == 0x02 && bytes[offset + 1] == 0x15) {
                      final start = offset + 2;
                      if (bytes.length - start >= 21) {
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
                        txPower = bytes[majIndex + 4];
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
                manufacturerHex = md.entries.first.value.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
              }
            }
          } catch (_) {}

          if (uuid == null) {
            try {
              final sd = adv.serviceData;
              for (final e in sd.entries) {
                final key = e.key.toString().toLowerCase();
                if (key.contains('feaa') && e.value.isNotEmpty) {
                  manufacturerHex = e.value.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
                }
              }
            } catch (_) {}
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



          if (filterUuid != null && filterUuid.trim().isNotEmpty) {
            final normFilter = filterUuid.replaceAll('-', '').toLowerCase();
            final beaconUuidNorm = beacon.uuid?.replaceAll('-', '').toLowerCase();
            if (beaconUuidNorm != null && beaconUuidNorm == normFilter) {
              onBeaconFound(beacon);
            }
          } else {
            onBeaconFound(beacon);
          }
        } catch (_) {}
      }
    });

    _isScanning = true;
  }

  Future<void> stopScanning() async {
    await _scanSubscription?.cancel();
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    _isScanning = false;
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

  Future<BeaconData?> performTripleAttempt(String rawUuid, {Function(String)? onStatusUpdate}) async {
    final norm = rawUuid.replaceAll('-', '').toLowerCase();
    final uuid32 = norm.length >= 32 ? norm.substring(0, 32) : norm;
    
    onStatusUpdate?.call('Iniciando intentos...');

    bool found = false;
    BeaconData? foundBeacon;

    for (int attempt = 1; attempt <= 3; attempt++) {
      onStatusUpdate?.call('Intento $attempt de 3 — escaneando 3s...');

      final completer = Completer<bool>();

      void onFound(BeaconData b) {
        final bnorm = b.uuid?.replaceAll('-', '').toLowerCase();
        if (bnorm != null && bnorm == uuid32) {
          if (!completer.isCompleted) completer.complete(true);
          foundBeacon = b;
        }
      }

      try {
        await startScanning(onBeaconFound: onFound, filterUuid: uuid32);
      } catch (e) {
        onStatusUpdate?.call('Error iniciando escaneo: $e');
        break;
      }

      final detected = await Future.any([completer.future, Future.delayed(const Duration(seconds: 3), () => false)]);

      try {
        await stopScanning();
      } catch (_) {}

      if (detected == true) {
        found = true;
        onStatusUpdate?.call('Beacon detectado en intento $attempt');
        break;
      } else {
        onStatusUpdate?.call('No detectado en intento $attempt');
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    if (found && foundBeacon != null) {
      onStatusUpdate?.call('Beacon detectado: ${foundBeacon!.name} (${foundBeacon!.rssi} dBm)');
      return foundBeacon;
    } else {
      onStatusUpdate?.call('Beacon no detectado después de 3 intentos');
      return null;
    }
  }

  Future<bool> detectBeacon(String rawUuid) async {
    final norm = rawUuid.replaceAll('-', '').toLowerCase();
    final uuid32 = norm.length >= 32 ? norm.substring(0, 32) : norm;

    for (int attempt = 1; attempt <= 3; attempt++) {
      final completer = Completer<bool>();

      void onFound(BeaconData b) {
        final bnorm = b.uuid?.replaceAll('-', '').toLowerCase();
        if (bnorm != null && bnorm == uuid32) {
          if (!completer.isCompleted) completer.complete(true);
        }
      }

      try {
        await startScanning(onBeaconFound: onFound, filterUuid: uuid32);
        final detected = await Future.any([completer.future, Future.delayed(const Duration(seconds: 3), () => false)]);
        await stopScanning();
        
        if (detected == true) {
          return true;
        }
        
        if (attempt < 3) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      } catch (_) {
        await stopScanning();
      }
    }

    return false;
  }
}

class BeaconDetector extends StatefulWidget {
  const BeaconDetector({Key? key}) : super(key: key);

  @override
  State<BeaconDetector> createState() => _BeaconDetectorState();
}

class _BeaconDetectorState extends State<BeaconDetector> {
  final BeaconService _beaconService = BeaconService();
  final TextEditingController _uuidController = TextEditingController();
  bool _isAttempting = false;
  String _attemptStatus = '';
  BeaconData? _detectedBeacon;

  @override
  void dispose() {
    _beaconService.stopScanning();
    _uuidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8C3CE6),
                Color(0xFFA159FF),
              ],
            ),
          ),
        ),
        title: const Text("Detector de Beacon")
      ),
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
                      labelText: 'UUID (iBeacon) para detectar',
                      hintText: 'xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isAttempting
                      ? null
                      : () async {
                          final uuidText = _uuidController.text.trim();
                          if (uuidText.isEmpty) {
                            setState(() => _attemptStatus = 'Introduce una UUID antes');
                            return;
                          }
                          await _performTripleAttempt(uuidText);
                        },
                  child: Text(_isAttempting ? 'Detectando...' : 'Detectar x3'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_attemptStatus.isNotEmpty) ...[
              Text(_attemptStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
            ],
            if (_detectedBeacon != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Beacon Detectado:', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(_detectedBeacon!.pretty()),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _performTripleAttempt(String rawUuid) async {
    setState(() => _isAttempting = true);

    final foundBeacon = await _beaconService.performTripleAttempt(
      rawUuid,
      onStatusUpdate: (status) {
        if (mounted) {
          setState(() => _attemptStatus = status);
        }
      },
    );

    if (mounted) {
      setState(() {
        _detectedBeacon = foundBeacon;
        _isAttempting = false;
      });
    }
  }
}
