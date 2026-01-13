import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_appbar.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/features/rules/presentation/widgets/title_with_value.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'قوانين اللعبة'),
      backgroundColor: AppColors.bg,
      bottomNavigationBar: BottomNavigationText(),
      body: _RulesContent(),
    );
  }
}

class _RulesContent extends StatelessWidget {
  const _RulesContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 28.0),
          child: Image.asset(Assets.iconsIcon, height: 0.10.sh),
        ),
        const TitleWithValue(
          title: 'قواعد اللعبة',
          highlight: true,
          value:
              ' كل لاعب بيبدأ معاه 4 كروت, مسموحله يشوف كارتين بس في أول الجيم ومينغعش يغير مكان أي كارت منهم',
        ),
        const TitleWithValue(
          title: 'تتكون اللعبة من',
          isSmaller: true,
          value:
              'تتكون اللعبة من 58 كارت (أرقام عادية و كروت باور)\n '
              'الكارت رقم 7 | 8 : بتبص في كارت واحد فقط من عندك\n'
              'الكارت رقم 9 | 10 : بتبص في كارت واحد فقط من عند احد اللاعبين\n'
              'خد وهات بتخليك تبدل كارت مع حد تاني من غير ما تشوفه\n'
              'كعب داير بتخليك تشوف كارت من كل لاعب او تبص في كارتين من عندك\n'
              'البصره بتخليك تتخلص من كارت من الكروت اللي معاك',
        ),
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 20),
          color: AppColors.mainColor.withOpacity(0.2),
          child: const CustomText(
            text:
                'كروت الباور عشان تتفعل لازم تكون مسحوبة من الورق لكن لو من ضمن ورقك المقلوب حاول تتخلص منها عشان قيمتها 10 نقط',
            fontSize: 16,
            textAlign: TextAlign.center,
          ),
        ),
        CustomText(text: 'الكروت الجديدة (أوسكار)', fontSize: 16.sp),
        const Divider(),
        const TitleWithValue(
          title: 'كارت بوم',
          highlight: true,
          isOscar: true,
          value: 'دا زي لغم اللي هيرميه هيخلي كل اللي بيلعبوا يبصرو ماعدا هو.',
        ),
        const TitleWithValue(
          title: 'كارت الايف جاكيت',
          highlight: true,
          isOscar: true,
          value: 'بياخد قيمة أقل قيمة كارت في الكروت اللي معاك.',
        ),
        const TitleWithValue(
          title: 'كارت صرخة أوسكار',
          highlight: true,
          isOscar: true,
          value:
              'بتجمعوا كل الكروت اللي مع بعض وتفنطوها تاني وتوزعوا الكروت بنفس عدد الكروت اللي كانت مع كل واحد.',
        ),
        CustomText(text: 'الكروت الجديدة (رمضان)', fontSize: 16.sp),
        const Divider(),
        const TitleWithValue(
          title: 'كارت المسحراتي',
          highlight: true,
          isRamadan: true,
          value: 'دا اول ما يتسحب ويترمي على الارض بيكون سكرو اجباري في لحظتها',
        ),
        const TitleWithValue(
          title: 'كارت الخشاف',
          highlight: true,
          isRamadan: true,
          value:
              'بتسحب اربع ورقات من كومة الورق وتختار ورقة منهم وبتنزل الباقي في كومة الورق',
        ),
        const TitleWithValue(
          title: 'كارت المدفع',
          highlight: true,
          isRamadan: true,
          value: 'بتختار واحد يكشف كل ورقة',
        ),
        const Divider(),
        const TitleWithValue(
          title: 'كارت خد بس',
          highlight: true,
          value:
              'دا زي كارت خد وهات ولكن الفرق انك بتدي بس اي حد كارت من كروتك',
        ),
        const TitleWithValue(
          title: 'كارت على كيفك',
          highlight: true,
          value:
              'ليه طرقتين بيبقي علي حسب الاتفاق اما انك تدي اي امر من اللعبة زي مثلا ( خد بس او بصرة ...الخ ) او ان الامر يكون من الكروت اللي اتسحبت من كومة الورق قبل كده ',
        ),
        const TitleWithValue(
          title: 'SEE And SWAP كارت',
          highlight: true,
          value:
              'بيخليك تشوف كارت عند حد لو عجبك بتاخده لو معجبكش تقدر تبدله مع اي حد ويبقي لبست الاتنين مع بعض',
        ),
        const TitleWithValue(
          title: 'كارت الحرامي',
          highlight: true,
          value:
              ' كارت لما بتسحبه مش بترميه ولو كان معاك برضو بتخليه معاك عادي , لان انت بتحتاجه لما حد غيرك يقول اسكرو والكارت معاك وبعد ما الدور يلف وكله يكشف ورقه بيقول فلان الحرام لو طلع كلامه صح يبق كده كارت الحرامي مات لو طلع غلط دا يخلي الشخص اللي معاه كارت الحرامي ياخد اسكور اللي قال سكرو وهو ياخد الاسكور بتاعه , يعني بيبدلوا الاسكور بتاعهم مع بعض,  \n وممكن ترميه عل الارض ويتحرق على الكل ولو كان الحرامي معاك واللي قال سكرو قال انه معاك قبل ما يكشف ورقة بيتحسب عليك بقيمتة اللي هي 10',
        ),
        const Divider(),
        CustomText(
          text: 'دي كروت في مود صاحب صاحبه تيمات ضد بعضه  يعني 2 ضد 2 او اكتر',
          fontSize: 16.sp,
        ),
        const TitleWithValue(
          title: 'كارت البينج',
          highlight: true,
          value:
              'لما بتسحبه لازم ترميه كارت البينج لما بيتلعب لانه بيترمي اجباري اللي في الفريق التاني بي skip الدور صاحبي لو معاه البونج اللي محتفظ بيها يبصر علي البينج وصاحبي لو مش معاه البونج بي skip هو كمان',
        ),
        const TitleWithValue(
          title: 'كارت البونج ',
          highlight: true,
          value: 'لما بتسحبه لازم تحتفظ بيه علي الاقل رواند واحده',
        ),
        const Divider(),
        const TitleWithValue(
          title: 'هدف اللعبة',
          value:
              'مع كل راوند تتخلص من الكروت التقيلة لحد ما يبقى معاك أقل سكور يخليك تقول سكرول\n بدل ما تلعب الراوند بتكمل لحد ما باقي اللاعيبه يلعبوا أخر لعبة ليهم وبنكشف الورق \n وصاحب أقل سكور بيكسب',
        ),
        const TitleWithValue(
          title: 'أهم كروت اللعبة',
          highlight: true,
          value: 'كارت ال -1 و الاسكرول الاخضر (قيمتهم ب 0) حاول تحافظ عليهم',
        ),
        const TitleWithValue(
          title: 'أسوء كروت اللعبة',
          highlight: true,
          value:
              'كارت ال +20 و كارت الاسكرول الاحمر (قيمتهم ب 25 ) لو معاك حاول تتخلص منهم',
        ),
        const TitleWithValue(
          title: 'تنبيه',
          highlight: true,
          value: 'حتى تستطيع استخدام هذه الكروت يجب ان تسحب من الميدان',
        ),
      ],
    );
  }
}
