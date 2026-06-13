// import 'dart:async';
// import 'dart:math';
//
// import 'package:confetti/confetti.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
// import 'package:screw_calculator/models/player_model.dart';
//
// class RandomWidgetToSelectPlayer extends StatelessWidget {
//   final List<PlayerModel> players;
//   final StreamController<int> selected;
//   final ConfettiController confettiController;
//
//   final Function() spinWheel;
//
//   final int? selectedIndex;
//
//   const RandomWidgetToSelectPlayer({
//     super.key,
//     required this.players,
//     required this.selected,
//     required this.confettiController,
//     required this.spinWheel,
//     this.selectedIndex,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // عجلة الحظ
//             SizedBox(
//               height: 350,
//               child: FortuneWheel(
//                 selected: selected.stream,
//                 animateFirst: false,
//                 indicators: const <FortuneIndicator>[
//                   FortuneIndicator(
//                     alignment: Alignment.topCenter,
//                     child: TriangleIndicator(color: Colors.deepPurple),
//                   ),
//                 ],
//                 items: [
//                   for (var player in players)
//                     FortuneItem(
//                       child: Text(
//                         player.name.toString(),
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       style: FortuneItemStyle(
//                         color:
//                             Colors.primaries[players.indexOf(player) %
//                                 Colors.primaries.length],
//                         borderColor: Colors.white,
//                         borderWidth: 2,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 40),
//
//             // زرار التوزيع العشوائي
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 30,
//                   vertical: 15,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               onPressed: spinWheel,
//               icon: const Icon(Icons.casino, color: Colors.white),
//               label: const Text(
//                 "اختيار لاعب",
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             // عرض اسم اللاعب الفائز
//             if (selectedIndex != null)
//               Column(
//                 children: [
//                   const Text(
//                     "🎉 اللاعب المختار هو:",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     players[selectedIndex!].name.toString(),
//                     style: const TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.deepPurple,
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//
//         // Confetti Animation
//         ConfettiWidget(
//           confettiController: confettiController,
//           blastDirection: -pi / 2,
//           emissionFrequency: 0.05,
//           numberOfParticles: 30,
//           maxBlastForce: 20,
//           minBlastForce: 8,
//           gravity: 0.3,
//         ),
//       ],
//     );
//   }
// }
