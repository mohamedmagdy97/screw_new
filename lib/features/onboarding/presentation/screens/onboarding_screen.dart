import 'package:flutter/material.dart';
import 'package:screw_calculator/core/constants/local_storage_keys.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/local_store.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';

class _Page {
  const _Page(this.emoji, this.title, this.body);

  final String emoji;
  final String title;
  final String body;
}

const List<_Page> _pages = [
  _Page(
    '🃏',
    'احسب نقاط سكرو بسهولة',
    'اختر وضع اللعب: فردي كلاسيك أو فرق (زوجي)، واكتب أسماء اللاعبين وابدأ.',
  ),
  _Page(
    '🧮',
    'سجّل كل جولة بلمسة',
    'أدخل نتيجة كل لاعب، واضرب في 2 أو 4 عند الحاجة، وتراجع عن أي خطأ بزر "تراجع". الأقل نقاطًا يفوز.',
  ),
  _Page(
    '📊',
    'لعبتك محفوظة وإحصائياتك جاهزة',
    'تُحفظ اللعبة الجارية تلقائيًا لتكمّلها لاحقًا، وتتابع نسب الفوز، وتشارك النتيجة كصورة أنيقة.',
  ),
];

/// شاشة تعريفية قصيرة تُعرض مرة واحدة عند أول فتح للتطبيق.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  /// يُستدعى بعد إنهاء/تخطي الشاشة التعريفية.
  final VoidCallback onDone;

  /// هل رأى المستخدم الشاشة التعريفية من قبل؟
  static Future<bool> wasSeen() async =>
      (await AppLocalStore.getBool(LocalStoreNames.onboardingSeen)) ?? false;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppLocalStore.setBool(LocalStoreNames.onboardingSeen, true);
    widget.onDone();
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(onPressed: _finish, child: const Text('تخطي')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: palette.brandGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: palette.brand.withValues(alpha: 0.35),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Text(
                            page.emoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                        const SizedBox(height: 40),
                        CustomText(
                          text: page.title,
                          fontSize: 24,
                          fontFamily: AppFonts.bold,
                        ),
                        const SizedBox(height: 16),
                        CustomText(
                          text: page.body,
                          fontSize: 16,
                          color: palette.textSecondary,
                          height: 1.7,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? palette.brand : palette.border,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: _isLast ? 'ابدأ اللعب' : 'التالي',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
