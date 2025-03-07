import 'package:flutter/material.dart';
import '../service/order_service.dart';
import 'package:provider/provider.dart';
import '../../../model/user_profile.dart';
import '../model/phone_profile.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _codeController = TextEditingController();
  String _orderStatus = '加载中...';
  bool _isDriving = false;
  final OrderService _orderService = OrderService();
  bool _showScanner = false;
  DateTime? _startTime;
  Timer? _timer;
  String _ridingTime = '00:00';

  @override
  void initState() {
    super.initState();
    _fetchOrderStatus();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final now = DateTime.now();
        final difference = now.difference(_startTime!);
        final minutes = difference.inMinutes.toString().padLeft(2, '0');
        final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
        setState(() {
          _ridingTime = '$minutes:$seconds';
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _ridingTime = '00:00';
    });
  }

  Future<void> _fetchOrderStatus() async {
    try {
      String token = Provider.of<UserProfile>(context, listen: false).token;
      final response = await _orderService.getCyclingStatus(token);
      setState(() {
        if (response['message'] != null) {
          _orderStatus = response['message'];
          _stopTimer();
        } else if (response['data'] != null && response['data']['car_number'] != null) {
          _orderStatus = '正在使用  ${response['data']['car_number']}';
          if (response['data']['car_start_time'] != null) {
            _startTime = DateTime.parse(response['data']['car_start_time']);
            _startTimer();
          }
        } else {
          _orderStatus = '未知状态';
          _stopTimer();
        }
      });
    } catch (e) {
      setState(() {
        _orderStatus = '获取状态失败';
        _stopTimer();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('错误: $e')),
      );
    }
  }

  void _pollOrderStatus(bool isDriving) {
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        String token = Provider.of<UserProfile>(context, listen: false).token;
        final response = await _orderService.getCyclingStatus(token);
        
        if (mounted) {
          if (isDriving) {
            // 开车状态：等待出现 car_number
            if (response['data'] != null && response['data']['car_number'] != null) {
              setState(() {
                _orderStatus = '正在使用  ${response['data']['car_number']}';
              });
            } else {
              _pollOrderStatus(true);
            }
          } else {
            // 还车状态：等待出现 message
            if (response['message'] != null) {
              setState(() {
                _orderStatus = response['message'];
              });
            } else {
              _pollOrderStatus(false);
            }
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _orderStatus = '获取状态失败';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startDriving() async {
    if (_codeController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('提示'),
          content: const Text('请输入乘车码'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      String token = Provider.of<UserProfile>(context, listen: false).token;
      final phoneProfile = Provider.of<PhoneProfile>(context, listen: false);
      final response = await _orderService.startDriving(token, _codeController.text, phoneProfile);
      
      if (response['status_code'] == 200) {
        // 下单成功后，发送开锁请求
        try {
          final unlockResponse = await _orderService.unlockCar(token, phoneProfile);
          if (unlockResponse['status_code'] != 200) {
            throw Exception('开锁失败: ${unlockResponse['message']}');
          } else {
            setState(() {
              _startTime = DateTime.now();
            });
            _startTimer();
          }
        } catch (e) {
          // 如果开锁失败，显示错误信息并返回
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('开锁失败'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
          return;
        }
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(response['status_code'] == 200 ? '成功' : '提示'),
          content: Text(
            response['message'] ?? 
            (response['status_code'] == 200 ? '操作成功' : json.encode(response)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (response['status_code'] == 200) {
                  setState(() {
                    _isDriving = true;
                    _orderStatus = '下单成功';
                  });
                  _pollOrderStatus(true);
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('错误'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  void _returnCar() async {
    try {
      String token = Provider.of<UserProfile>(context, listen: false).token;
      final phoneProfile = Provider.of<PhoneProfile>(context, listen: false);
      final response = await _orderService.returnCar(token, phoneProfile);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(response['status_code'] == 200 ? '成功' : '提示'),
          content: Text(
            response['message'] ?? 
            (response['status_code'] == 200 ? '操作成功' : json.encode(response)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (response['status_code'] == 200) {
                  setState(() {
                    _isDriving = false;
                    _orderStatus = '当前无行程';
                    _codeController.clear();
                  });
                  _pollOrderStatus(false);
                  _stopTimer();
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('错误'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  void _startScanning() {
    setState(() {
      _showScanner = true;
    });
  }

  void _onScan(String? code) {
    if (code != null) {
      // 从URL中提取数字部分
      final RegExp regExp = RegExp(r'randnum=(\d+)');
      final match = regExp.firstMatch(code);
      if (match != null) {
        setState(() {
          _codeController.text = match.group(1) ?? '';
          _showScanner = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('7MA骑行'),
      ),
      body: _showScanner ? _buildScanner() : _buildMainContent(),
    );
  }

  Widget _buildScanner() {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.unrestricted,
              formats: const [BarcodeFormat.qrCode],
              facing: CameraFacing.back,
              useNewCameraSelector: true,
              cameraResolution: const Size(1920, 1080),
            ),
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                _onScan(barcodes.first.rawValue);
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    '订单状态',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _orderStatus,
                    style: TextStyle(
                      fontSize: 24,
                      color: _orderStatus.startsWith('正在使用') ? Colors.green : Colors.blue,
                    ),
                  ),
                  if (_orderStatus.startsWith('正在使用')) ...[
                    const SizedBox(height: 8),
                    Text(
                      '骑行时间：$_ridingTime',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '请输入乘车码',
              border: const OutlineInputBorder(),
              prefixIcon: IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: _startScanning,
              ),
            ),
            enabled: !_isDriving,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _orderStatus.startsWith('正在使用') ? null : _startDriving,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '开车',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _orderStatus.startsWith('正在使用') ? _returnCar : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '还车',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 