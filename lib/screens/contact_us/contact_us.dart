import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:screw_calculator/utility/sochial_links.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUS extends StatefulWidget {
  const ContactUS({super.key});

  @override
  State<ContactUS> createState() => _ContactUSState();
}

class _ContactUSState extends State<ContactUS> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.grayy,
        title: CustomText(text: 'للتواصل وتقديم الاقتراحات', fontSize: 22.sp),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Transform.flip(
              flipX: true,
              child: const Icon(
                Icons.arrow_back_ios_sharp,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNavigationText(),
      body: Column(
        children: [
          Expanded(
            child: Column(
              // padding: const EdgeInsets.all(16),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: CustomText(text: 'آهلا بيك يا صديقي', fontSize: 16),
                ),
                const CustomText(
                  text: 'يمكنك محادثتنا للأسئلة والاستفسارات من خلال',
                  fontSize: 16,
                ),
                const SizedBox(height: 24),
                Row(
                  spacing: 32,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(SocialLinks.linkedin);
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          throw Exception('Could not launch $url');
                        }

                        // if (await canLaunchUrl(
                        //   Uri.parse(SocialLinks.linkedin),
                        // )) {
                        //   await launchUrl(Uri.parse(SocialLinks.linkedin));
                        // }
                      },
                      child: const Image(
                        image: AssetImage(Assets.linkedInIcon),
                        height: 50,
                        width: 50,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(SocialLinks.whatsapp);
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          throw Exception('Could not launch $url');
                        }
                      },
                      child: const Image(
                        image: AssetImage(Assets.whatsappIcon),
                        height: 50,
                        width: 50,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(SocialLinks.github);
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalNonBrowserApplication,
                        )) {
                          throw Exception('Could not launch $url');
                        }
                      },
                      child: const Image(
                        image: AssetImage(Assets.githubIcon),
                        height: 50,
                        width: 50,
                        color: AppColors.white,
                      ),
                    ),

                    // InkWell(
                    //   onTap: () async {
                    //     String url = 'https://wa.me/+201149504892';
                    //
                    //     if (await canLaunchUrl(Uri.parse(url))) {
                    //       await launchUrl(Uri.parse(url));
                    //     }
                    //   },
                    //   child: const CustomText(
                    //     text: 'الواتس اب',
                    //     fontSize: 20,
                    //     color: AppColors.green,
                    //     underline: true,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          const CustomText(
            text:
                'نحن لا نبيع اللعبة ولكن يمكنك الارسال لمساعدتنا بتحسين التطبيق ومعرفة اخر التطبيقات',
            fontSize: 16,
          ),
          const SizedBox(height: 16),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   color: AppColors.mainColor,
          //   child: const CustomText(
          //     text:
          //         "التطبيق لا ينتمي للمهندس يحيى عزام ولكن لمطورية فقط, ورقم الواتس المرفق للاقترحات والشكاوى",
          //     fontSize: 14,
          //   ),
          // ),
        ],
      ),
    );
  }
}
