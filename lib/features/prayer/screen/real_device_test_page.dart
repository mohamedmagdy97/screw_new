// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:screw_calculator/screens/prayer/core/notification_service.dart';
//
// class RealDeviceTestPage extends StatefulWidget {
//   const RealDeviceTestPage({super.key});
//
//   @override
//   State<RealDeviceTestPage> createState() => _RealDeviceTestPageState();
// }
//
// class _RealDeviceTestPageState extends State<RealDeviceTestPage> {
//   Map<String, bool>? _permissionsStatus;
//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   String? _manufacturer;
//   int? _androidVersion;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInfo();
//   }
//
//   Future<void> _loadInfo() async {
//     final androidInfo = await deviceInfo.androidInfo;
//     final permissions = await NotificationService.checkPermissionsStatus();
//
//     setState(() {
//       _manufacturer = androidInfo.manufacturer;
//       _androidVersion = androidInfo.version.sdkInt;
//       _permissionsStatus = permissions;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('اختبار Real Device'),
//         actions: [
//           IconButton(icon: const Icon(Icons.refresh), onPressed: _loadInfo),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // معلومات الجهاز
//           Card(
//             child: ListTile(
//               leading: const Icon(Icons.phone_android),
//               title: const Text('الشركة المصنعة'),
//               subtitle: Text(_manufacturer ?? 'Loading...'),
//             ),
//           ),
//           Card(
//             child: ListTile(
//               leading: const Icon(Icons.android),
//               title: const Text('إصدار Android'),
//               subtitle: Text('API ${_androidVersion ?? '...'}'),
//             ),
//           ),
//
//           const SizedBox(height: 16),
//           const Text(
//             'حالة الأذونات',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//
//           // حالة كل إذن
//           if (_permissionsStatus != null)
//             ..._permissionsStatus!.entries.map((entry) {
//               return Card(
//                 color: entry.value ? Colors.green[50] : Colors.red[50],
//                 child: ListTile(
//                   leading: Icon(
//                     entry.value ? Icons.check_circle : Icons.cancel,
//                     color: entry.value ? Colors.green : Colors.red,
//                   ),
//                   title: Text(entry.key),
//                   subtitle: Text(entry.value ? 'ممنوح' : 'غير ممنوح'),
//                   trailing: entry.value
//                       ? null
//                       : TextButton(
//                           onPressed: NotificationService.openAppSettings,
//                           child: const Text('منح'),
//                         ),
//                 ),
//               );
//             }).toList(),
//
//           const SizedBox(height: 16),
//
//           // أزرار الاختبار
//           ElevatedButton.icon(
//             onPressed: () async {
//               await NotificationService.requestAllPermissions();
//               await _loadInfo();
//             },
//             icon: const Icon(Icons.security),
//             label: const Text('طلب جميع الأذونات'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           ElevatedButton.icon(
//             onPressed: () {
//               // NotificationService.testAdhanSound();
//               NotificationService.showInstantNotification(
//                 title: 'إشعار تجريبي',
//                 body: 'هذا إشعار تجريبي للتأكد من عمل الإشعارات',
//               );
//             },
//             icon: const Icon(Icons.volume_up),
//             label: const Text('اختبار الصوت'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           ElevatedButton.icon(
//             onPressed: () async {
//               final time = DateTime.now().add(const Duration(seconds: 10));
//               await NotificationService.schedulePrayerNotification(
//                 prayerName: 'اختبار',
//                 time: time,
//               );
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('تم جدولة إشعار بعد 10 ثواني')),
//                 );
//               }
//             },
//             icon: const Icon(Icons.schedule),
//             label: const Text('جدولة إشعار تجريبي'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange,
//               foregroundColor: Colors.white,
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           ElevatedButton.icon(
//             onPressed: () {
//               NotificationService.showBrandSpecificInstructions(context);
//             },
//             icon: const Icon(Icons.help),
//             label: const Text('إرشادات خاصة بجهازك'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.purple,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
