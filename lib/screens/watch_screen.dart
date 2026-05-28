import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../widgets/pressable.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  int? _heartRate;
  bool _connecting = false;
  String _status = 'Not connected';

  static const _hrServiceUuid = '0000180d-0000-1000-8000-00805f9b34fb';
  static const _hrMeasUuid    = '00002a37-0000-1000-8000-00805f9b34fb';

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    final s = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return s.values.every((v) => v.isGranted);
  }

  Future<void> _startScan() async {
    if (!await _requestPermissions()) {
      _snack('Bluetooth permissions required');
      return;
    }
    setState(() { _scanResults = []; _isScanning = true; });
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    FlutterBluePlus.scanResults.listen(
        (r) { if (mounted) setState(() => _scanResults = r); });
    FlutterBluePlus.isScanning.listen(
        (v) { if (mounted) setState(() => _isScanning = v); });
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() { _connecting = true; _status = 'Connecting…'; });
    FlutterBluePlus.stopScan();
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      setState(() {
        _connectedDevice = device;
        _status = 'Connected to ${device.platformName}';
        _connecting = false;
      });
      await _subscribeHR(device);
    } catch (e) {
      setState(() { _status = 'Connection failed'; _connecting = false; });
    }
  }

  Future<void> _subscribeHR(BluetoothDevice device) async {
    try {
      for (final svc in await device.discoverServices()) {
        if (svc.uuid.toString().toLowerCase() == _hrServiceUuid) {
          for (final c in svc.characteristics) {
            if (c.uuid.toString().toLowerCase() == _hrMeasUuid) {
              await c.setNotifyValue(true);
              c.onValueReceived.listen((v) {
                if (v.isNotEmpty && mounted) setState(() => _heartRate = v[1]);
              });
              setState(() => _status = 'Heart rate live');
              return;
            }
          }
        }
      }
      setState(() => _status = 'Connected — no HR service');
    } catch (e) {
      setState(() => _status = 'Connected');
    }
  }

  Future<void> _disconnect() async {
    await _connectedDevice?.disconnect();
    setState(() {
      _connectedDevice = null;
      _heartRate = null;
      _status = 'Disconnected';
    });
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final connected = _connectedDevice != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                const Text(
                  'Watch',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
                const Spacer(),
                if (connected)
                  GestureDetector(
                    onTap: _disconnect,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.elevated,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Disconnect',
                          style: TextStyle(
                            color: AppColors.destructive,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Connection / HR card
                _HRCard(
                  connected: connected,
                  deviceName: connected
                      ? (_connectedDevice!.platformName.isEmpty
                          ? 'Unknown Device'
                          : _connectedDevice!.platformName)
                      : null,
                  status: _status,
                  heartRate: _heartRate,
                ),

                const SizedBox(height: 12),

                if (!connected) ...[
                  Pressable(
                    onTap: _isScanning ? null : _startScan,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.elevated,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isScanning)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.text),
                            )
                          else
                            const Icon(Icons.bluetooth_searching_rounded,
                                size: 18, color: AppColors.text),
                          const SizedBox(width: 10),
                          Text(
                            _isScanning ? 'Scanning…' : 'Scan for Devices',
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_scanResults.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'NEARBY DEVICES',
                        style: TextStyle(
                          color: AppColors.textSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._scanResults
                        .where((r) => r.device.platformName.isNotEmpty)
                        .map((r) => _DeviceTile(
                              result: r,
                              connecting: _connecting,
                              onTap: () => _connect(r.device),
                            )),
                    if (_scanResults
                        .where((r) => r.device.platformName.isEmpty)
                        .isNotEmpty)
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        iconColor: AppColors.textSub,
                        collapsedIconColor: AppColors.textSub,
                        title: Text(
                          'Unknown devices (${_scanResults.where((r) => r.device.platformName.isEmpty).length})',
                          style: const TextStyle(
                              color: AppColors.textSub, fontSize: 13),
                        ),
                        children: _scanResults
                            .where((r) => r.device.platformName.isEmpty)
                            .map((r) => _DeviceTile(
                                  result: r,
                                  connecting: _connecting,
                                  onTap: () => _connect(r.device),
                                ))
                            .toList(),
                      ),
                  ],

                  const SizedBox(height: 12),
                ],

                // Help card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.textSub),
                        SizedBox(width: 8),
                        Text('Connecting your Redmi Watch',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            )),
                      ]),
                      SizedBox(height: 12),
                      _HelpStep(n: '1', text: 'On your watch → Settings → About → enable Bluetooth visibility'),
                      SizedBox(height: 6),
                      _HelpStep(n: '2', text: 'Tap "Scan for Devices" above'),
                      SizedBox(height: 6),
                      _HelpStep(n: '3', text: 'Select your watch from the list'),
                      SizedBox(height: 6),
                      _HelpStep(n: '4', text: 'Heart rate syncs automatically during workouts'),
                      SizedBox(height: 12),
                      Text(
                        'Note: Full watch control requires Xiaomi\'s Mi Fitness app. This app reads heart rate via standard BLE.',
                        style: TextStyle(
                            color: AppColors.textTert, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HRCard extends StatelessWidget {
  final bool connected;
  final String? deviceName;
  final String status;
  final int? heartRate;

  const _HRCard({
    required this.connected,
    required this.deviceName,
    required this.status,
    required this.heartRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: connected
                      ? AppColors.elevated
                      : AppColors.elevated,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  connected
                      ? Icons.watch_rounded
                      : Icons.watch_off_rounded,
                  size: 24,
                  color: connected ? AppColors.text : AppColors.textTert,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connected ? (deviceName ?? 'Unknown') : 'No device',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(status,
                        style: const TextStyle(
                          color: AppColors.textSub, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (heartRate != null) ...[
            const SizedBox(height: 20),
            Container(height: 0.5, color: AppColors.separator),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Icon(Icons.favorite_rounded,
                    color: AppColors.destructive, size: 24),
                const SizedBox(width: 10),
                Text(
                  '$heartRate',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'bpm',
                  style: TextStyle(
                    color: AppColors.textSub,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final ScanResult result;
  final bool connecting;
  final VoidCallback onTap;

  const _DeviceTile(
      {required this.result,
      required this.connecting,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = result.device.platformName.isEmpty
        ? result.device.remoteId.str
        : result.device.platformName;

    return Pressable(
      onTap: connecting ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.bluetooth_rounded,
                size: 20, color: AppColors.textSub),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )),
                  Text('${result.rssi} dBm',
                      style: const TextStyle(
                        color: AppColors.textSub, fontSize: 12)),
                ],
              ),
            ),
            connecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.text))
                : const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textTert),
          ],
        ),
      ),
    );
  }
}

class _HelpStep extends StatelessWidget {
  final String n;
  final String text;
  const _HelpStep({required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(n,
                style: const TextStyle(
                  color: AppColors.textSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                color: AppColors.textSub, fontSize: 13)),
        ),
      ],
    );
  }
}
