import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class NetworkMonitorScreen extends StatefulWidget {
  const NetworkMonitorScreen({super.key});

  @override
  State<NetworkMonitorScreen> createState() => _NetworkMonitorScreenState();
}

class _NetworkMonitorScreenState extends State<NetworkMonitorScreen> {
  final List<Map<String, dynamic>> _connections = [];
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();

  final List<String> _dummyIps = [
    '192.168.1.105',
    '10.0.0.2',
    '172.16.254.1',
    '8.8.8.8',
    '1.1.1.1',
    '185.199.108.153',
    '104.244.42.1',
    '142.250.190.46',
  ];

  final List<String> _maliciousIps = [
    '45.33.32.156',
    '185.220.101.14',
    '198.51.100.23',
  ];

  @override
  void initState() {
    super.initState();
    _generateInitialConnections();
    _startMonitoring();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _generateInitialConnections() {
    for (int i = 0; i < 10; i++) {
      _addConnection();
    }
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) return;
      setState(() {
        _addConnection();
        if (_connections.length > 50) {
          _connections.removeAt(0);
        }
      });
      
      // Auto-scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addConnection() {
    final random = Random();
    final isMalicious = random.nextDouble() > 0.85;
    final ip = isMalicious 
        ? _maliciousIps[random.nextInt(_maliciousIps.length)]
        : _dummyIps[random.nextInt(_dummyIps.length)];
    final port = random.nextInt(60000) + 1024;
    final protocol = random.nextBool() ? 'TCP' : 'UDP';
    
    _connections.add({
      'ip': ip,
      'port': port,
      'protocol': protocol,
      'status': isMalicious ? 'BLOCKED' : 'SECURE',
      'time': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NETWORK MONITOR'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('LIVE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNetworkStats(),
          const Divider(height: 1, color: Colors.grey),
          _buildConnectionHeader(),
          Expanded(
            child: Container(
              color: Colors.black,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _connections.length,
                itemBuilder: (context, index) {
                  final conn = _connections[index];
                  final isBlocked = conn['status'] == 'BLOCKED';
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            '\${conn['time'].hour.toString().padLeft(2, '0')}:\${conn['time'].minute.toString().padLeft(2, '0')}:\${conn['time'].second.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.grey, fontFamily: 'monospace', fontSize: 12),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            conn['protocol'],
                            style: const TextStyle(color: Colors.blueGrey, fontFamily: 'monospace', fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '\${conn['ip']}:\${conn['port']}',
                            style: TextStyle(
                              color: isBlocked ? Theme.of(context).colorScheme.secondary : Colors.white70,
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isBlocked 
                                ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isBlocked ? Theme.of(context).colorScheme.secondary : Colors.green,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            conn['status'],
                            style: TextStyle(
                              color: isBlocked ? Theme.of(context).colorScheme.secondary : Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('INBOUND', '4.2 MB/s', Colors.blue),
          _buildStatColumn('OUTBOUND', '1.8 MB/s', Colors.purple),
          _buildStatColumn('BLOCKED', '12', Theme.of(context).colorScheme.secondary),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.2),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildConnectionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: const Row(
        children: [
          SizedBox(width: 80, child: Text('TIME', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          SizedBox(width: 40, child: Text('PROTO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(child: Text('DESTINATION', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          Text('STATUS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
