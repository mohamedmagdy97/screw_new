import 'package:screw_calculator/features/rules/domain/rule_entry.dart';

/// محتوى دليل اللعبة بالعربية والإنجليزية.
///
/// أسماء الكروت العربية (خد وهات، كعب داير، البصرة...) مصطلحات اللعبة نفسها،
/// فتُذكر بجانب الترجمة الإنجليزية ليتعرّف عليها اللاعب.
List<RuleEntry> rulesFor(String languageCode) =>
    languageCode == 'ar' ? _ar : _en;

const List<RuleEntry> _ar = [
  RuleEntry(
    category: RuleCategory.basics,
    title: 'قواعد اللعبة',
    body:
        'كل لاعب بيبدأ معاه 4 كروت، مسموحله يشوف كارتين بس في أول الجيم ومينفعش يغير مكان أي كارت منهم.',
  ),
  RuleEntry(
    category: RuleCategory.basics,
    title: 'تتكون اللعبة من',
    body:
        'تتكون اللعبة من 58 كارت (أرقام عادية و كروت باور)\n'
        'الكارت رقم 7 | 8 : بتبص في كارت واحد فقط من عندك\n'
        'الكارت رقم 9 | 10 : بتبص في كارت واحد فقط من عند احد اللاعبين\n'
        'خد وهات بتخليك تبدل كارت مع حد تاني من غير ما تشوفه\n'
        'كعب داير بتخليك تشوف كارت من كل لاعب او تبص في كارتين من عندك\n'
        'البصره بتخليك تتخلص من كارت من الكروت اللي معاك',
  ),
  RuleEntry(
    category: RuleCategory.basics,
    title: 'تنبيه الباور',
    body:
        'كروت الباور عشان تتفعل لازم تكون مسحوبة من الورق، لكن لو من ضمن ورقك المقلوب حاول تتخلص منها عشان قيمتها 10 نقط.',
  ),
  RuleEntry(
    category: RuleCategory.oscar,
    title: 'كارت بوم',
    body: 'دا زي لغم، اللي هيرميه هيخلي كل اللي بيلعبوا يبصروا ماعدا هو.',
  ),
  RuleEntry(
    category: RuleCategory.oscar,
    title: 'كارت الايف جاكيت',
    body: 'بياخد قيمة أقل قيمة كارت في الكروت اللي معاك.',
  ),
  RuleEntry(
    category: RuleCategory.oscar,
    title: 'كارت صرخة أوسكار',
    body:
        'بتجمعوا كل الكروت اللي مع بعض وتفنطوها تاني وتوزعوا الكروت بنفس عدد الكروت اللي كانت مع كل واحد.',
  ),
  RuleEntry(
    category: RuleCategory.ramadan,
    title: 'كارت المسحراتي',
    body: 'دا أول ما يتسحب ويترمي على الأرض بيكون سكرو إجباري في لحظتها.',
  ),
  RuleEntry(
    category: RuleCategory.ramadan,
    title: 'كارت الخشاف',
    body:
        'بتسحب أربع ورقات من كومة الورق وتختار ورقة منهم وبتنزل الباقي في كومة الورق.',
  ),
  RuleEntry(
    category: RuleCategory.ramadan,
    title: 'كارت المدفع',
    body: 'بتختار واحد يكشف كل ورقة.',
  ),
  RuleEntry(
    category: RuleCategory.power,
    title: 'كارت خد بس',
    body: 'دا زي كارت خد وهات ولكن الفرق إنك بتدي بس أي حد كارت من كروتك.',
  ),
  RuleEntry(
    category: RuleCategory.power,
    title: 'كارت على كيفك',
    body:
        'له طريقتين بيبقى على حسب الاتفاق: إما إنك تدي أي أمر من اللعبة زي مثلًا (خد بس أو بصرة ... إلخ) أو إن الأمر يكون من الكروت اللي اتسحبت من كومة الورق قبل كده.',
  ),
  RuleEntry(
    category: RuleCategory.power,
    title: 'كارت SEE And SWAP',
    body:
        'بيخليك تشوف كارت عند حد، لو عجبك بتاخده ولو معجبكش تقدر تبدله مع أي حد.',
  ),
  RuleEntry(
    category: RuleCategory.power,
    title: 'كارت الحرامي',
    body:
        'كارت لما بتسحبه مش بترميه، ولو كان معاك برضو بتخليه معاك عادي، لأنك بتحتاجه لما حد غيرك يقول سكرو والكارت معاك. بعد ما الدور يلف وكله يكشف ورقه بتقول فلان الحرامي. لو طلع كلامك صح يبقى كده كارت الحرامي مات، ولو طلع غلط ده يخلي الشخص اللي معاه كارت الحرامي ياخد سكور اللي قال سكرو وهو ياخد السكور بتاعه، يعني بيبدلوا السكور بتاعهم مع بعض.\n'
        'وممكن ترميه على الأرض ويتحرق على الكل. ولو كان الحرامي معاك واللي قال سكرو قال إنه معاك قبل ما يكشف ورقة بيتحسب عليك بقيمته اللي هي 10.',
  ),
  RuleEntry(
    category: RuleCategory.teams,
    title: 'كروت مود صاحب صاحبه',
    body: 'دي كروت في مود صاحب صاحبه، تيمات ضد بعضها يعني 2 ضد 2 أو أكتر.',
  ),
  RuleEntry(
    category: RuleCategory.teams,
    title: 'كارت البينج',
    body:
        'لما بتسحبه لازم ترميه. كارت البينج لما بيتلعب بيترمي إجباري واللي في الفريق التاني بيعمل skip للدور. صاحبي لو معاه البونج اللي محتفظ بيها يبصر على البينج، ولو مش معاه البونج بيعمل skip هو كمان.',
  ),
  RuleEntry(
    category: RuleCategory.teams,
    title: 'كارت البونج',
    body: 'لما بتسحبه لازم تحتفظ بيه على الأقل راوند واحدة.',
  ),
  RuleEntry(
    category: RuleCategory.goal,
    title: 'هدف اللعبة',
    body:
        'مع كل راوند تتخلص من الكروت التقيلة لحد ما يبقى معاك أقل سكور يخليك تقول سكرو. بدل ما تلعب الراوند بتكمل لحد ما باقي اللاعبين يلعبوا آخر لعبة ليهم وبنكشف الورق، وصاحب أقل سكور بيكسب.',
  ),
  RuleEntry(
    category: RuleCategory.goal,
    title: 'أهم كروت اللعبة',
    body: 'كارت ال -1 والسكرول الأخضر (قيمتهم 0) حاول تحافظ عليهم.',
  ),
  RuleEntry(
    category: RuleCategory.goal,
    title: 'أسوأ كروت اللعبة',
    body:
        'كارت ال +20 وكارت السكرول الأحمر (قيمتهم 25) لو معاك حاول تتخلص منهم.',
  ),
  RuleEntry(
    category: RuleCategory.goal,
    title: 'تنبيه',
    body: 'حتى تستطيع استخدام هذه الكروت يجب أن تسحب من الميدان.',
  ),
];

const List<RuleEntry> _en = [
  RuleEntry(
    category: RuleCategory.basics,
    title: 'Game basics',
    body:
        'Each player starts with 4 cards. You may look at only two of them at the start of the game, and you cannot move any of them.',
  ),
  RuleEntry(
    category: RuleCategory.basics,
    title: 'What the deck contains',
    body:
        'The deck has 58 cards (number cards and power cards)\n'
        '7 | 8 : peek at one of your own cards\n'
        '9 | 10 : peek at one card of another player\n'
        'Take & Give (خد وهات): swap a card with another player without looking at it\n'
        'Round Robin (كعب داير): look at one card from every player, or at two of your own cards\n'
        'Basra (البصرة): get rid of one of your cards',
  ),
  RuleEntry(
    category: RuleCategory.basics,
    title: 'Power cards note',
    body:
        'Power cards only activate when drawn from the deck. If one is among your face-down cards, try to get rid of it — it is worth 10 points.',
  ),
  RuleEntry(
    category: RuleCategory.oscar,
    title: 'Bomb card (بوم)',
    body:
        'Like a mine: when someone throws it, every other player must play Basra (get rid of a card) except the one who threw it.',
  ),
  RuleEntry(
    category: RuleCategory.oscar,
    title: 'Life Jacket card (الايف جاكيت)',
    body: 'Takes the value of the lowest card among your cards.',
  ),
  RuleEntry(
    category: RuleCategory.oscar,
    title: "Oscar's Scream card (صرخة أوسكار)",
    body:
        'Everyone gathers all the cards, reshuffles them and deals them back with the same number of cards each player had before.',
  ),
  RuleEntry(
    category: RuleCategory.ramadan,
    title: 'Musaharati card (المسحراتي)',
    body:
        'As soon as it is drawn and thrown on the table, it forces an immediate "Screw" call.',
  ),
  RuleEntry(
    category: RuleCategory.ramadan,
    title: 'Khoshaf card (الخشاف)',
    body:
        'Draw four cards from the deck, keep one of them and put the rest back on the deck.',
  ),
  RuleEntry(
    category: RuleCategory.ramadan,
    title: 'Cannon card (المدفع)',
    body: 'You choose one player who must reveal every card they hold.',
  ),
  RuleEntry(
    category: RuleCategory.power,
    title: 'Take Only card (خد بس)',
    body:
        'Like Take & Give, but you only give another player one of your cards.',
  ),
  RuleEntry(
    category: RuleCategory.power,
    title: 'Your Way card (على كيفك)',
    body:
        'Works in one of two ways, by agreement: either you give any command from the game (for example Take Only or Basra…) or the command comes from the cards that were previously drawn from the deck.',
  ),
  RuleEntry(
    category: RuleCategory.power,
    title: 'SEE And SWAP card',
    body:
        'Lets you look at a card of another player. If you like it you take it; if not, you may swap it with anyone.',
  ),
  RuleEntry(
    category: RuleCategory.power,
    title: 'Thief card (الحرامي)',
    body:
        'When you draw it you do not throw it — even if it is among your cards you simply keep it, because you need it when someone else calls Screw while you hold it. After the turn goes around and everyone reveals their cards, you say "so-and-so is the thief". If you are right, the Thief card is dead. If you are wrong, the player holding the Thief takes the score of the one who called Screw, and the caller takes the Thief holder\'s score — they swap scores.\n'
        'You can also throw it on the table, which burns it for everyone. If you hold the Thief and the player who called Screw says so before revealing a card, it counts against you at its value of 10.',
  ),
  RuleEntry(
    category: RuleCategory.teams,
    title: 'Team-mode cards',
    body:
        'These cards belong to the teams mode ("Sahib Sahibu"): teams play against each other, for example 2 vs 2 or more.',
  ),
  RuleEntry(
    category: RuleCategory.teams,
    title: 'Ping card (البينج)',
    body:
        'When you draw it you must throw it. When it is played the opposing team skips its turn. If my teammate holds the Pong he kept, he can Basra on the Ping; if he does not hold the Pong, he skips too.',
  ),
  RuleEntry(
    category: RuleCategory.teams,
    title: 'Pong card (البونج)',
    body: 'When you draw it you must keep it for at least one round.',
  ),
  RuleEntry(
    category: RuleCategory.goal,
    title: 'Goal of the game',
    body:
        'Each round you get rid of heavy cards until you have the lowest score, which lets you call "Screw". Instead of playing the round out, play continues until the other players take their last turn, then the cards are revealed. The player with the lowest score wins.',
  ),
  RuleEntry(
    category: RuleCategory.goal,
    title: 'Best cards',
    body: 'The -1 card and the green scroll (both worth 0): try to keep them.',
  ),
  RuleEntry(
    category: RuleCategory.goal,
    title: 'Worst cards',
    body:
        'The +20 card and the red scroll (worth 25): if you have them, try to get rid of them.',
  ),
  RuleEntry(
    category: RuleCategory.goal,
    title: 'Note',
    body: 'To use these cards you must draw them from the deck.',
  ),
];
