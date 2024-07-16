import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruabbit_flutter/app/WaterFree/model/water_free_profile.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

import '../util/command.dart';

class WaterFreePage extends StatefulWidget {
  const WaterFreePage({super.key});

  @override
  State<WaterFreePage> createState() => _WaterFreePageState();
}

class _WaterFreePageState extends State<WaterFreePage> {
  final machineIDController = TextEditingController();

  @override
  void dispose() {
    machineIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WaterFree'),
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
                    quickStart(machineIDController.text);
                  },
                  child: const Text('放水'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (await Haptics.canVibrate() == true) {
                      await Haptics.vibrate(HapticsType.error);
                    }
                    quickStop(machineIDController.text);
                  },
                  child: const Text('停水'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: Storage.waterDispensers.length,
                itemBuilder: (context, index) {
                  var waterDispenser = Storage.waterDispensers[index];
                  return ListTile(
                    title: Text(waterDispenser.machineID),
                    subtitle: Text(waterDispenser.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () async {
                            if (await Haptics.canVibrate() == true) {
                              await Haptics.vibrate(HapticsType.success);
                            }
                            quickStart(waterDispenser.machineID);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: () async {
                            if (await Haptics.canVibrate() == true) {
                              await Haptics.vibrate(HapticsType.error);
                            }
                            quickStop(waterDispenser.machineID);
                          },
                        ),
                      ],
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
