import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class ThreatScannerScreen extends StatefulWidget {
  const ThreatScannerScreen({super.key});

  @override
  State<ThreatScannerScreen> createState() => _ThreatScannerScreenState();
}

class _ThreatScannerScreenState extends State<ThreatScannerScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  bool _scanComplete = false;
  double _scanProgress = 0.0;
  String _currentFile = '';
  List<Map<String, dynamic>> _detectedThreats = [];
  late AnimationController _radarController;

  final List<String> _dummyFiles = [
    '/system/bin/kernel_task',
    '/usr/libexec/syspolicyd',
    '/Library/Preferences/com.apple.security.plist',
    'C:\\Windows\\System32\\svchost.exe',
    '/var/log/auth.log',
    '~/.ssh/authorized_keys',
    '/etc/passwd',
  ];

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _scanComplete = false;
      _scanProgress = 0.0;
      _detectedThreats = [];
    });
    _radarController.repeat();

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _scanProgress += 0.02;
        _currentFile = _dummyFiles[Random().nextInt(_dummyFiles.length)];

        if (_scanProgress >= 0.3 && _detectedThreats.isEmpty) {
          _detectedThreats.add({
            'name': 'Trojan.Win32.Generic',
            'path': 'C:\\Users\\Public\\Downloads\\update.exe',
            'severity': 'High',
            'neutralized': false,
          });
        }
        if (_scanProgress >= 0.7 && _detectedThreats.length == 1) {
          _detectedThreats.add({
            'name': 'Adware.OSX.Pirrit',
            'path': '/Library/Application Support/Helper/helper',
            'severity': 'Medium',
            'neutralized': false,
          });
        }

        if (_scanProgress >= 1.0) {
          _scanProgress = 1.0;
          _isScanning = false;
          _scanComplete = true;
          _radarController.stop();
          timer.cancel();
        }
      });
    });
  }

  void _neutralizeThreat(int index) {
    setState(() {
      _detectedThreats[index]['neutralized'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Threat \${_detectedThreats[index]['name']} neutralized.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('THREAT SCANNER'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildScannerVisual(),
            const SizedBox(height: 32),
            if (!_isScanning && !_scanComplete)
              ElevatedButton(
                onPressed: _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'INITIATE DEEP SCAN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            if (_isScanning) _buildScanningProgress(),
            if (_scanComplete) _buildScanResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerVisual() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isScanning 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.radar,
            size: 100,
            color: _isScanning 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                : Colors.grey[800],
          ),
          if (_isScanning)
            RotationTransition(
              turns: _radarController,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                    stops: const [0.8, 1.0],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanningProgress() {
    return Column(
      children: [
        Text(
          'SCANNING IN PROGRESS...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: _scanProgress,
          backgroundColor: Colors.grey[800],
          color: Theme.of(context).colorScheme.primary,
          minHeight: 8,
        ),
        const SizedBox(height: 16),
        Text(
          'Analyzing: \$_currentFile',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScanResults() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCAN COMPLETE',
            style: TextStyle(
              color: _detectedThreats.isEmpty ? Colors.green : Theme.of(context).colorScheme.secondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _detectedThreats.isEmpty 
                ? 'No threats detected. Your system is secure.' 
                : '\${_detectedThreats.length} threats detected. Immediate action required.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _detectedThreats.length,
              itemBuilder: (context, index) {
                final threat = _detectedThreats[index];
                final isNeutralized = threat['neutralized'] as bool;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isNeutralized ? Colors.green : Theme.of(context).colorScheme.secondary,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      isNeutralized ? Icons.security : Icons.bug_report,
                      color: isNeutralized ? Colors.green : Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(
                      threat['name'],
                      style: TextStyle(
                        decoration: isNeutralized ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      threat['path'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: isNeutralized
                        ? const Text('CLEARED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                        : ElevatedButton(
                            onPressed: () => _neutralizeThreat(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('NEUTRALIZE'),
                          ),
                  ),
                );
              },
            ),
          ),
          if (_scanComplete)
            Center(
              child: TextButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.refresh),
                label: const Text('SCAN AGAIN'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
