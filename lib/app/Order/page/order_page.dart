import 'package:flutter/material.dart';
import '../service/order_service.dart';
import 'package:provider/provider.dart';
import '../../../model/user_profile.dart';
import '../model/phone_profile.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _fetchOrderStatus();
  }

  Future<void> _fetchOrderStatus() async {
    try {
      String token = Provider.of<UserProfile>(context, listen: false).token;
      final response = await _orderService.getCyclingStatus(token);
      setState(() {
        if (response['message'] != null) {
          _orderStatus = response['message'];
        } else if (response['data'] != null && response['data']['car_number'] != null) {
          _orderStatus = '正在使用  ${response['data']['car_number']}';
        } else {
          _orderStatus = '未知状态';
        }
      });
    } catch (e) {
      setState(() {
        _orderStatus = '获取状态失败';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单'),
      ),
      body: Padding(
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '请输入乘车码',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
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
      ),
    );
  }
} 