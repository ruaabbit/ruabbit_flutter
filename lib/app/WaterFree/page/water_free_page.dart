import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruabbit_flutter/app/WaterFree/model/water_free_profile.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

import '../../../util/persist.dart';
import '../util/command.dart';

class WaterFreePage extends StatefulWidget {
  const WaterFreePage({super.key});

  @override
  State<WaterFreePage> createState() => _WaterFreePageState();
}

class _WaterFreePageState extends State<WaterFreePage> {
  final machineIDController = TextEditingController();
  final newMachineIDController = TextEditingController();
  final newDescriptionController = TextEditingController();

  @override
  void dispose() {
    machineIDController.dispose();
    newMachineIDController.dispose();
    newDescriptionController.dispose();
    super.dispose();
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("确认删除"),
          content: const Text("您确定要删除吗？"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("确定"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("取消"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addWaterDispenser(WaterFreeProfile waterFreeProfile) async {
    waterFreeProfile.addWaterDispenser(
      newMachineIDController.text,
      newDescriptionController.text,
    );
    await saveWaterFreeProfileToPrefs(waterFreeProfile);
    newMachineIDController.clear();
    newDescriptionController.clear();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _removeWaterDispenser(
      WaterFreeProfile waterFreeProfile, int index) async {
    final waterDispenser = waterFreeProfile.waterDispenserList[index];
    waterFreeProfile.removeWaterDispenser(index);
    await saveWaterFreeProfileToPrefs(waterFreeProfile);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${waterDispenser.machineID} 已删除'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final waterFreeProfile = Provider.of<WaterFreeProfile>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WaterFree'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('收藏新的饮水机'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: newMachineIDController,
                          decoration: const InputDecoration(
                            labelText: '饮水机号',
                          ),
                        ),
                        TextField(
                          controller: newDescriptionController,
                          decoration: const InputDecoration(
                            labelText: '描述',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => _addWaterDispenser(waterFreeProfile),
                        child: const Text('保存'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: machineIDController,
              decoration: const InputDecoration(
                labelText: '输入饮水机号',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (await Haptics.canVibrate() == true) {
                      await Haptics.vibrate(HapticsType.success);
                    }
                    waterStart(
                        waterFreeProfile.cardId, machineIDController.text);
                  },
                  child: const Text('放水'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (await Haptics.canVibrate() == true) {
                      await Haptics.vibrate(HapticsType.error);
                    }
                    waterStop(
                        waterFreeProfile.cardId, machineIDController.text);
                  },
                  child: const Text('停水'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(),
            Expanded(
              child: waterFreeProfile.waterDispenserList.isEmpty
                  ? const Center(
                      child: Text(
                        '没有已收藏的饮水机，请点击右上角的加号添加。',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: waterFreeProfile.waterDispenserList.length + 1,
                      itemBuilder: (context, index) {
                        if (index ==
                            waterFreeProfile.waterDispenserList.length) {
                          return const ListTile(
                            title: Center(
                              child: Text(
                                '从左向右滑动可以删除收藏的饮水机。',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        final waterDispenser =
                            waterFreeProfile.waterDispenserList[index];
                        return Dismissible(
                          key: Key(waterDispenser.machineID),
                          confirmDismiss: (direction) async {
                            // 显示确认对话框
                            bool confirm =
                                await _showDeleteConfirmationDialog(context);
                            return confirm;
                          },
                          onDismissed: (direction) async {
                            // 删除饮水机
                            await _removeWaterDispenser(
                                waterFreeProfile, index);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.startToEnd,
                          // 限制只能水平滑动
                          // 修改滑动触发阈值
                          dismissThresholds: const {
                            DismissDirection.endToStart: 0.7,
                            DismissDirection.startToEnd: 0.7,
                          },
                          child: ListTile(
                            title: Text(waterDispenser.machineID),
                            subtitle: Text(waterDispenser.description),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  onPressed: () async {
                                    if (await Haptics.canVibrate() == true) {
                                      await Haptics.vibrate(
                                          HapticsType.success);
                                    }
                                    waterStart(waterFreeProfile.cardId,
                                        waterDispenser.machineID);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.stop),
                                  onPressed: () async {
                                    if (await Haptics.canVibrate() == true) {
                                      await Haptics.vibrate(HapticsType.error);
                                    }
                                    waterStop(waterFreeProfile.cardId,
                                        waterDispenser.machineID);
                                  },
                                ),
                              ],
                            ),
                          ),
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
