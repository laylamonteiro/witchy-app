import '../models/rune_model.dart';

/// The 24 runes of the Elder Futhark — English content.
///
/// Names and symbols are invariant across languages; only keywords and
/// descriptions are translated. Keep the same order as `runes_data_pt.dart`
/// — parity is verified by `test/content_parity_test.dart`.
const List<Rune> runesEn = [
  Rune(
    name: 'Fehu',
    symbol: 'ᚠ',
    keywords: ['Prosperity', 'Wealth', 'Abundance'],
    description: 'Fehu is cattle: wealth that walks, gets counted in heads '
        'and gets spent. In the Norse world, a herd meant livelihood, and '
        'that is the concrete, movable wealth this rune speaks of — not '
        'abstract fortune. In a reading, it points to resources arriving or '
        'already at hand: money, time, energy asking to be used. Ask '
        'yourself where your wealth is circulating and where it is merely '
        'piling up. Fehu\'s warning is ancient: the rune poems say gold '
        'breeds strife among kin — wealth that sits still, or is badly '
        'shared, rots',
  ),
  Rune(
    name: 'Uruz',
    symbol: 'ᚢ',
    keywords: ['Strength', 'Vitality', 'Health'],
    description:
        'Uruz is the aurochs, the giant wild ox that roamed the forests of '
        'Europe until it was hunted to extinction. Hunting it was a rite of '
        'passage: the young proved their strength against a beast that '
        'would not be tamed. In a reading, Uruz says the situation calls '
        'for vigor and that you have more strength than you think — '
        'including the strength to recover, which is why it is also a rune '
        'of health. Face the challenge head-on and care for the body that '
        'carries everything else. The shadow: brute force without direction '
        'wounds the one who carries it — give yours a target before you '
        'use it',
  ),
  Rune(
    name: 'Thurisaz',
    symbol: 'ᚦ',
    keywords: ['Protection', 'Defense', 'Challenge'],
    description:
        'Thurisaz is the thorn and also the giant, the raw force of chaos; '
        'tradition links it to Thor\'s hammer, which kept the giants at '
        'bay. The Anglo-Saxon poem warns: the thorn is cruelly sharp to '
        'anyone who grasps it. In a reading, it points to conflict, threat '
        'or friction — and to your power to answer them. Before acting, '
        'stop: this rune asks for considered defense, like a hedge of '
        'thorns, not an attack. Its shadow is impulsiveness — force used '
        'in anger cuts its own hand',
  ),
  Rune(
    name: 'Ansuz',
    symbol: 'ᚨ',
    keywords: ['Communication', 'Wisdom', 'Inspiration'],
    description:
        'Ansuz is the rune of the god — of Odin, who hung himself on the '
        'world tree to win the runes — and it means mouth, breath, the '
        'spoken word. It is the rune of communication that carries wisdom: '
        'counsel, poetry, the right message. In a reading, it signals that '
        'important information is on its way or that one conversation '
        'could unlock the situation. Listen closely, seek out those who '
        'know more, and say clearly what needs saying. Just check the '
        'source: words also deceive, and not every voice that sounds wise '
        'is',
  ),
  Rune(
    name: 'Raidho',
    symbol: 'ᚱ',
    keywords: ['Journey', 'Movement', 'Progress'],
    description:
        'Raidho is the ride: the long journey on horseback, with route, '
        'rhythm and wear. The Norwegian rune poem reminds us that riding '
        'is easy to say and hard on the horse — every road has a real '
        'cost. In a reading, it points to movement with direction: a '
        'literal trip, a process underway, the moment to get going. Plan '
        'the route, keep a steady pace and skip no stages — it is the '
        'whole road that transforms, not just the arrival. If everything '
        'feels stuck, Raidho suggests what is missing is movement, not '
        'luck',
  ),
  Rune(
    name: 'Kenaz',
    symbol: 'ᚲ',
    keywords: ['Knowledge', 'Creativity', 'Illumination'],
    description:
        'Kenaz is the torch: the pine fire that lit halls and workshops — '
        'working light, not wildfire. It is the rune of craft and of '
        'knowledge mastered with the hands. In a reading, it announces an '
        'insight, a solution coming into view, or a skill ready to be '
        'developed. Study, practice, and light one corner at a time '
        'instead of trying to set everything ablaze. Remember a torch '
        'needs a steady hand: creative fire without care burns — including '
        'as enthusiasm that consumes without building',
  ),
  Rune(
    name: 'Gebo',
    symbol: 'ᚷ',
    keywords: ['Gift', 'Partnership', 'Exchange'],
    description:
        'Gebo is the gift. Among the Germanic peoples, a gift was never '
        'just a gift: it created a bond of honor between giver and '
        'receiver, and one gift called for another. In a reading, it '
        'speaks of exchanges, alliances and the generosity that binds — a '
        'relationship, an agreement, an offer on the table. Watch the '
        'balance: are you giving and receiving in equal measure? Repay '
        'what you were given and ask for reciprocity without guilt. '
        'Gebo\'s shadow is the unequal exchange, which turns a gift into '
        'debt and a bond into dependence',
  ),
  Rune(
    name: 'Wunjo',
    symbol: 'ᚹ',
    keywords: ['Joy', 'Harmony', 'Fulfillment'],
    description:
        'Wunjo is joy — and, for the Anglo-Saxon poem, joy belongs to the '
        'one who knows little hardship and lacks neither sustenance nor '
        'community. It is not euphoria: it is the concrete well-being of '
        'belonging and of having enough. In a reading, it points to a '
        'phase when the pieces fit — harmony at home, in the group, at '
        'work. Celebrate and share: joy hoarded for yourself withers. '
        'Only beware of faking harmony by hiding what needs to be talked '
        'about',
  ),
  Rune(
    name: 'Hagalaz',
    symbol: 'ᚺ',
    keywords: ['Disruption', 'Change', 'Purification'],
    description: 'Hagalaz is hail: the grain of ice that falls from the '
        'sky without warning, destroys the harvest and then melts into '
        'water that feeds the field. The rune poems call it the coldest '
        'of grains. In a reading, it points to disruption beyond your '
        'control — plans undone, a sudden turn. Do not fight the storm: '
        'protect what is essential, wait for the hail to melt, and see '
        'what fragility it exposed. The rune\'s consolation is real: what '
        'it knocks down was not standing firm, and the water left behind '
        'feeds the new beginning',
  ),
  Rune(
    name: 'Nauthiz',
    symbol: 'ᚾ',
    keywords: ['Need', 'Endurance', 'Overcoming'],
    description: 'Nauthiz is need, lack — and also the friction fire, '
        'kindled with effort when every other fire has gone out. The rune '
        'poem says need presses hard on the chest, yet can arrive as '
        'warning and lesson in time. In a reading, it points to scarcity, '
        'delay or thwarted desire: something you want is not yet '
        'possible. Strip down to the essential, practice active patience '
        'and do what you can with what you have — that is how fire is '
        'kindled by friction. Avoid both extremes, denying the hardship '
        'or despairing in it: what is lacking now is showing you what '
        'truly matters',
  ),
  Rune(
    name: 'Isa',
    symbol: 'ᛁ',
    keywords: ['Pause', 'Stillness', 'Introspection'],
    description:
        'Isa is ice: beautiful to look at, bright as a jewel, treacherous '
        'to step on. In the Norse winter, ice stopped rivers and ships — '
        'and sometimes became a bridge. In a reading, it points to a '
        'frozen situation: a cooling, a wait, something that will not '
        'move. Do not force the thaw; use the pause to see with the cold '
        'clarity only distance gives. But stay alert: under the ice the '
        'current keeps running, and a stagnation that lasts too long must '
        'be broken with one small first step',
  ),
  Rune(
    name: 'Jera',
    symbol: 'ᛃ',
    keywords: ['Harvest', 'Cycles', 'Reward'],
    description: 'Jera is the year and the harvest: the full agricultural '
        'cycle, from sowing to a full barn. The rune poems celebrate it '
        'as the good season, when the earth yields its fruit. In a '
        'reading, it points to results arriving in their own time — you '
        'reap what was sown, neither sooner nor later. Keep up the steady '
        'work, respect the seasons of the process, and harvest when it is '
        'ripe, not when anxiety demands. Jera has no shortcut: if the '
        'harvest is thin, the rune points to what was — or was not — '
        'sown',
  ),
  Rune(
    name: 'Eihwaz',
    symbol: 'ᛇ',
    keywords: ['Protection', 'Endurance', 'Transformation'],
    description:
        'Eihwaz is the yew: a tree of immense lifespan, of flexible wood '
        'and potent poison, from which the finest bows were made — and '
        'which was planted beside the dead, linking the worlds. Many '
        'associate it with Yggdrasil itself, the tree that holds up '
        'everything. In a reading, it points to a hard crossing that '
        'transforms: an ending that is a passage, a resistance that rises '
        'from the root. Root yourself in what is essential and hold fast, '
        'bending without breaking. Like the yew bow, the tension you bear '
        'now is what will give the shot its power later',
  ),
  Rune(
    name: 'Perthro',
    symbol: 'ᛈ',
    keywords: ['Mystery', 'Fate', 'Hidden'],
    description:
        'Perthro is the dice cup: the Anglo-Saxon poem describes it as '
        'play and laughter among warriors in the beer hall. It is the '
        'rune of luck, of fate and of what is still hidden. In a reading, '
        'it says there are factors in play you cannot see: a secret, an '
        'outcome not yet decided, chance doing its part. Make your play '
        'well and release your grip on the rest; watch what reveals '
        'itself little by little. The warning is the one every gaming '
        'table knows: do not wager what you cannot afford to lose',
  ),
  Rune(
    name: 'Algiz',
    symbol: 'ᛉ',
    keywords: ['Protection', 'Defense', 'Divine Connection'],
    description: 'Algiz is the elk — and the elk-sedge, the cutting marsh '
        'grass that, says the Anglo-Saxon poem, wounds anyone who tries '
        'to seize it. Its stave looks like an open hand or raised '
        'antlers: protection on alert. In a reading, it signals that you '
        'are protected or that it is time to raise defenses — often it is '
        'your own instinct sounding the alarm. Listen to that inner '
        'warning and set clear boundaries, which protect without needing '
        'to wound. The shadow: permanent defense becomes isolation, and '
        'not everyone is a threat',
  ),
  Rune(
    name: 'Sowilo',
    symbol: 'ᛊ',
    keywords: ['Success', 'Vitality', 'Illumination'],
    description: 'Sowilo is the sun — to the Anglo-Saxon poem, the hope '
        'of seafarers, who steer by it until they reach harbor. In a '
        'north of long winters, sun is no metaphor: it is concrete '
        'victory. In a reading, it points to clarity, success and energy '
        'returning — the right direction becomes visible and the wind '
        'blows in your favor. Act while the sky is clear: a favorable '
        'current is to be used, not stored. Just remember the sun also '
        'exposes what lay in shadow; let that light show the truth '
        'without fear',
  ),
  Rune(
    name: 'Tiwaz',
    symbol: 'ᛏ',
    keywords: ['Justice', 'Honor', 'Leadership'],
    description:
        'Tiwaz is the rune of Tyr, the god who placed his own hand in the '
        'mouth of the wolf Fenrir as a pledge so the gods could bind '
        'him — and lost it, paying the price of the pact. Its stave is an '
        'arrow: firm direction and true aim. In a reading, it speaks of a '
        'just cause that demands courage and exacts a cost — a hard '
        'decision, a word that must be kept. Do what is right even when '
        'it costs you, and stand by what you promised. For Tiwaz, a '
        'victory won without honor is no victory',
  ),
  Rune(
    name: 'Berkano',
    symbol: 'ᛒ',
    keywords: ['Growth', 'Fertility', 'Renewal'],
    description: 'Berkano is the birch, the first tree to bud when the '
        'winter ice retreats — an ancient symbol of spring, motherhood '
        'and renewal. In a reading, it points to a delicate beginning: '
        'something, or someone, in a phase of gestation, healing or slow '
        'growth that asks for care. Protect what is new, feed it with '
        'constancy and accept the natural pace of things that grow. '
        'Berkano\'s shadow is care that smothers: overprotecting also '
        'keeps the sprout from becoming a tree',
  ),
  Rune(
    name: 'Ehwaz',
    symbol: 'ᛖ',
    keywords: ['Partnership', 'Trust', 'Movement'],
    description:
        'Ehwaz is the horse — to the Anglo-Saxon poem, the joy of nobles '
        'and comfort to the restless. But the rune speaks less of the '
        'animal and more of the pair, horse and rider: two beings who '
        'only move forward because they trust each other. In a reading, '
        'it points to partnership that works — marriage, business, '
        'friendship, team — and progress built in tandem. Invest in '
        'trust, match your pace to the other\'s, and check that you both '
        'want to reach the same place. Remember that trust is built '
        'slowly and lost in one jolt',
  ),
  Rune(
    name: 'Mannaz',
    symbol: 'ᛗ',
    keywords: ['Humanity', 'Self-awareness', 'Community'],
    description:
        'Mannaz is the human being. The Anglo-Saxon poem says it plainly: '
        'each person is a joy to the others, and yet all will one day be '
        'gone, for death reaches everyone. It is the rune of knowing '
        'yourself human — mortal, limited and, even so, bound to others. '
        'In a reading, it asks for an honest look at yourself and at your '
        'place in the community. Ask for help when you need it, offer it '
        'when you can, and own your limits without shame. No one is '
        'enough alone — and that is not weakness, it is the human '
        'condition',
  ),
  Rune(
    name: 'Laguz',
    symbol: 'ᛚ',
    keywords: ['Water', 'Intuition', 'Flow'],
    description:
        'Laguz is water: the lake and the sea the poems describe as vast '
        'and unpredictable for those who sail. It is the rune of the '
        'depths — emotions, dreams, intuition, everything that runs '
        'beneath the surface. In a reading, it points to a phase of '
        'feeling more than understanding: the answer will not come by '
        'logic alone. Listen to your dreams, trust your intuition, and '
        'swim with the current instead of fighting it. Only respect the '
        'depth: diving into a feeling is not the same as drowning in it',
  ),
  Rune(
    name: 'Ingwaz',
    symbol: 'ᛜ',
    keywords: ['Fertility', 'Potential', 'Gestation'],
    description:
        'Ingwaz is the rune of Ing, an old name of Freyr, god of '
        'fertility and peace — the Anglo-Saxon poem tells that he was '
        'first seen among the Danes, and that his wagon crossed the lands '
        'blessing the fields. Its closed stave looks like a seed: '
        'complete potential, still held within. In a reading, it points '
        'to gestation — something developing on the inside, nearly ready, '
        'that should not yet be shown. Store your energy, finish in '
        'silence and wait for the right moment to release what has '
        'ripened. Ingwaz is a good omen: it promises completion, as long '
        'as you do not rush it',
  ),
  Rune(
    name: 'Dagaz',
    symbol: 'ᛞ',
    keywords: ['Day', 'Awakening', 'Transformation'],
    description:
        'Dagaz is day — the light the Anglo-Saxon poem calls beloved by '
        'all, rich and poor alike. It is the exact instant when night '
        'turns to morning: the turning point, not high noon. In a '
        'reading, it announces awakening and sudden clarity after a dark '
        'stretch — a true point of inflection. Receive the new beginning '
        'practically: use the fresh light to do differently what the '
        'darkness would not let you see. If you were waiting for a sign '
        'to change, Dagaz is usually that sign',
  ),
  Rune(
    name: 'Othala',
    symbol: 'ᛟ',
    keywords: ['Inheritance', 'Home', 'Ancestry'],
    description: 'Othala is the inherited estate: the family land, the '
        'homestead passed down through generations, which is not bought — '
        'it is received and handed on. It is the rune of roots, of home '
        'and of inheritance both material and invisible: name, values, '
        'customs, patterns. In a reading, it points to matters of family, '
        'home, belonging, or something received from those who came '
        'before. Honor what is good in that inheritance and tend your own '
        'ground. But remember inheritance also carries repeated '
        'patterns — part of the work is choosing what you keep and what '
        'you finally let go',
  ),
];
