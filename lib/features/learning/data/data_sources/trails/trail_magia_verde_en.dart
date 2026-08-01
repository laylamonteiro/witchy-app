import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trail 'magia_verde' — English content.
/// Parity with _pt/_es verified in test/trails_parity_test.dart.
const LearningTrail magiaVerdeTrailEn = LearningTrail(
    id: 'magia_verde',
    emoji: '🌿',
    title: 'Green Magic',
    subtitle: 'The path of herbs and earth',
    description:
        'The witchcraft of garden, kitchen, and forest: learning from plants, their cycles and powers — while writing your own magical herbal',
    lessons: [
      TrailLesson(
        id: 'mv_01',
        tool: LessonTool.addHerb,
        recordKind: LessonRecordKind.note,
        title: 'Truly knowing a plant',
        teaching:
            'Green magic does not begin by memorizing correspondence tables — it begins with ONE plant truly known: its name, its scent, its texture, how it responds to water and sun. Knowing a single ally up close is worth more than memorizing a hundred names, because green magic is born of relationship, not of catalogues. That is why this is the first step of the path\n\nTraditional green witches held deep relationships with only a few dozen plants: they knew when to harvest, gave thanks, and used every part, from root to flower. The rosemary on the windowsill, the rue by the gate, and the mint in the yard were familiar neighbors, not items on a list. That intimacy — watching a plant across days and seasons — is what turns information into wisdom\n\nIn everyday terms, this means choosing an accessible plant — a pot in your home, a tree along your route — and visiting it with genuine attention. Observe its leaves, its fragrance, its texture, how it greets the morning. The beginner\'s common mistake is wanting to work with ten herbs at once and truly knowing none. Go slowly: one well-known ally can sustain a great deal of magic\n\nYour first page of green magic is the portrait of an ally, written with your own senses. Keep this idea the way you would keep a seed: before using a plant, know the plant. Relationship comes before spellwork — and it is what gives root, strength, and truth to everything that blooms later along your path',
        practice:
            'Spend 5 minutes with an accessible plant, using your five senses safely. First observe its colors and shapes, then touch it gently, smell its leaves, and listen to the surroundings — tasting nothing, for you never bring to your lips what you do not know with certainty. Finally, jot down 3 observations no book could give you. The goal is to begin a real relationship with your first green ally. To seal the meeting, photograph your ally through the shortcut below and create her entry in your Herb encyclopedia',
        pageTitle: 'My First Plant Ally',
        pagePurpose: 'Record a relationship with a plant',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['The chosen plant'],
        pagePrompts: [
          'Name of the plant and where it lives:',
          'My 3 direct observations:',
          'Traditional magical uses (I researched in the Encyclopedia):',
          'What I feel when I am near it:',
        ],
      ),
      TrailLesson(
        id: 'mv_02',
        title: 'Tea as ritual',
        teaching:
            'Water, fire, plant, and intention: tea is the most accessible green ritual there is. It gathers magic\'s essential elements into one cup and fits any routine, in any kitchen. The difference between drinking a tea and ritualizing a tea lies not in rare ingredients, but in the presence with which you prepare and drink each sip\n\nRitualizing means choosing the herb by intention — chamomile to calm, mint to clear, lemongrass to soothe —, stirring in circles toward your goal, clockwise to attract and counterclockwise to banish, and drinking in silence, letting the warmth carry the intention inward. Healers and grandmothers have always known: a tea made with care carries far more than active compounds\n\nIn a beginner witch\'s daily life, ritual tea can be the most magical moment of the day: five minutes of stove, steam, and silence. Safety first: use only known edible plants, respect contraindications, and when in doubt, do not drink. The most common mistake is brewing in a hurry while scrolling on the phone — presence is the main ingredient, and without it the rite becomes routine\n\nKeep this idea: the cup is a small cauldron that fits in your hands. Whenever you need a simple, immediate ritual, remember that hot water, a safe herb, and your intention already make a complete spell. Repeated with constancy — seven days, every moon —, this small gesture becomes one of green magic\'s deepest practices',
        practice:
            'Prepare a simple tea with total presence, from start to finish. First choose a known edible herb and name your intention; then heat the water watching the steam, stir in circles toward your goal, and strain calmly; finally, drink in silence, no phone, feeling the warmth carry the intention inward. The goal is to experience how presence transforms an ordinary gesture into ritual',
        pageTitle: 'My Ritual Tea',
        pagePurpose: 'Create a ritual tea recipe',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Edible herb', 'Water', 'Honey (optional)'],
        pagePrompts: [
          'Herb and intention of my tea:',
          'My ritual way of preparing it:',
          'What I think/say while drinking:',
          'How I intend to repeat it (7 days? every moon?):',
        ],
      ),
      TrailLesson(
        id: 'mv_03',
        title: 'Herbal sachets and charms',
        teaching:
            'The sachet is green magic made portable: dried herbs gathered in a small cloth bag, closed with a knot and a word of power. It carries the strength of plants wherever you go — under the pillow for good dreams, in your bag for protection, in the wardrobe for harmony. It is one of witchcraft\'s oldest and simplest charms, and for that very reason one of the most beloved\n\nThe classic assembly follows a three-part logic: the main herb, which carries the intention; a supporting herb, which amplifies and balances; and a fixative — bark, root, or a small stone — that anchors the working in time. The color of the cloth converses with the goal: red for courage, green for prosperity, white for peace. Folk traditions all over the world use variations of this very design\n\nFor the beginner, the kitchen itself is already a magical cabinet: bay leaf, rosemary, cinnamon, clove, and chamomile yield powerful combinations. The common mistake is accumulating sachets with no clear purpose — each one should be born of a defined intention and receive a proper place to live. When you feel it has fulfilled its role, undo or renew it with gratitude, returning the herbs to the earth if you can\n\nCarry this image with you: a sachet is an intention wrapped in cloth and sealed with a knot. A few herbs, a clear purpose, and a word spoken firmly are worth more than dozens of ingredients mixed without listening. Wherever your little bag lives — pillow, purse, or wardrobe —, it will keep whispering the intention you tied into it',
        practice:
            'Set out dried herbs you already have in the kitchen, such as bay leaf, rosemary, and cinnamon, and sense which combination is asking to exist. First define the intention; then choose the main herb, the supporting one, and a fixative, touching and smelling each one calmly; finally, note down the chosen combination and the cloth color that converses with your goal. The aim is to train your listening to plants before assembling your first sachet',
        pageTitle: 'My First Sachet',
        pagePurpose: 'Assemble an herbal charm',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['3 dried herbs', 'Cloth', 'Ribbon or thread'],
        pagePrompts: [
          'Intention and the 3 chosen herbs (why?):',
          'Cloth color and reason:',
          'Words spoken while tying the knot:',
          'Where it lives now:',
        ],
      ),
      TrailLesson(
        id: 'mv_04',
        title: 'The kitchen as altar',
        teaching:
            'The kitchen witch knows: the pot is a cauldron, the wooden spoon a wand, the seasoning a spell. The kitchen is humanity\'s oldest altar — the place where fire, water, earth, and air meet every single day. Cooking with intention turns food into magic and makes the most ordinary routine a sacred space, needing nothing beyond what you already have\n\nThe tradition of kitchen magic crosses cultures and generations: stir clockwise to attract, season while naming the wish under your breath, serve as one who blesses. Each ingredient carries correspondences — cinnamon for prosperity, garlic for protection, basil for harmony — and the heat of the fire is what seals the intention into the food, the way an oven seals bread\n\nDay to day, you need no special recipes: everyday rice can be enchanted. Begin by naming an intention before lighting the stove, and declare something over each key ingredient that enters the pot. The common mistake is cooking in anger or haste — food absorbs the state of the one who prepares it, so breathe deeply before starting and cook as one who prays\n\nKeep this simple truth: the most powerful enchanted meal is the one made for someone you love, including yourself. Do not wait for special occasions — the kitchen altar is lit every day. Whenever you cook, remember that your hands are already magical instruments and that every pot on the stove can be a spell in progress',
        practice:
            'Cook something simple today, turning the preparation into a spell. First choose the recipe and set a clear intention; then, with each ingredient added, declare quietly what it brings — protection, sweetness, strength; stir clockwise to attract and finish by serving as one who blesses. The goal is to feel in practice how intention changes your relationship with food and with those who receive it',
        pageTitle: 'My Enchanted Recipe',
        pagePurpose: 'Turn a recipe into a spell',
        pageCategory: SpellCategory.home,
        pagePrompts: [
          'The recipe and its intention:',
          'What I declare over each key ingredient:',
          'My gesture when serving:',
          'Whom I cooked for and what happened:',
        ],
      ),
      TrailLesson(
        id: 'mv_05',
        title: 'Planting: the slowest spell',
        teaching:
            'Planting a seed with intention is green magic\'s long-term spell: the plant\'s growth mirrors the growth of the wish. While many spells seek quick results, planting teaches the magic of time — what you sow with care today becomes rooted strength tomorrow, in the pot and in your life\n\nThe structure is simple and ancient: pot, soil, seed, word. Peasant women and healers have always planted while naming wishes — a rosemary for the household\'s health, a basil for abundance at the table. After the initial gesture comes the true work: tending every day, watering, giving sun, observing. The spell is not only in the planting; it is in the constancy that sustains it\n\nFor the beginner, even a bean in damp cotton makes a fine start. The common mistake is planting with enthusiasm and forgetting within the first week — and here lies the lesson: if the plant wilts, the message is magical too. Ask yourself what care is missing, there in the pot and in the intention it carries. Adjust the watering, adjust your life, and begin again without guilt\n\nCarry this idea: every intention is a seed, and every daily act of care is the spell continuing in silence. Plant slowly, tend with constancy, and trust the earth\'s timing — it is rarely ours, and almost always right. When the first sprout appears, you will understand why the most enduring magic is the kind that grows slowly',
        practice:
            'Plant a seed or seedling — even a bean will do — dedicating the planting to an intention of growth. First prepare pot and soil calmly; then plant while saying aloud what you wish to see grow along with it; finally, commit to a simple act of daily care, such as watering and observing. The goal is to live a slow spell, in which tending the plant is tending your own intention',
        pageTitle: 'My Magical Planting',
        pagePurpose: 'Consecrate a planting to an intention',
        pageCategory: SpellCategory.prosperity,
        pageIngredients: ['Seed or seedling', 'Pot and soil'],
        pagePrompts: [
          'What I planted and the intention dedicated:',
          'My words at planting:',
          'My commitment to daily care:',
          'Growth journal (update here):',
        ],
      ),
      TrailLesson(
        id: 'mv_06',
        title: 'Smoke cleansing: air that clears',
        teaching:
            'Herbal smoke is green magic\'s energetic broom: where heaviness gathers, it sweeps through, loosens, and renews. Smoke cleansing is one of humanity\'s oldest purification practices, present in countless traditions around the world, and it remains one of the most direct rites for changing how a space feels — and how those who live in it feel\n\nEach herb has its office in the smoke: rosemary to renew, bay leaf to prosper, rue to cut what weighs. The traditional rite moves through the home from the back toward the front door, passing through corners and behind doors, always with windows open — the dense leaves, the new enters. The direction of the route matters as much as the chosen herb: you are guiding the cleansing outward\n\nDay to day, start small: one room, one herb, one fireproof vessel. Respect allergies, animals, and neighbors, and never leave embers unattended. Mind also where your herbs come from: green magic is ecological responsibility, so favor what you grow yourself or buy from conscious sources. The common mistake is cleansing with the house closed up — with no way out, the heaviness does not leave\n\nKeep the image: smoke is visible prayer and invisible broom at once. When the atmosphere grows heavy — after an argument, a hard week, a visit that left its trace —, remember that a dried herb, a safe ember, and open windows are enough to renew the air. The air outside and, with a little presence, the air within as well',
        practice:
            'Cleanse a single room with smoke today, using an herb you already have at home. First open the windows and light the herb in a fireproof vessel; then move through the space calmly, from the back toward the exit, carrying the smoke into corners and behind the door; finally, put everything out safely and sit for a moment. The goal is to observe the change in how the space feels before and after the rite',
        pageTitle: 'My Smoke Cleansing',
        pagePurpose: 'Create my rite of cleansing by air',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Dried herbs', 'Fireproof vessel'],
        pagePrompts: [
          'My cleansing blend and the purpose of each herb:',
          'My route through the house:',
          'Words that accompany the smoke:',
          'Difference I felt in the space:',
        ],
      ),
      TrailLesson(
        id: 'mv_07',
        title: 'Oils and salves',
        teaching:
            'The infused oil is the green witch\'s potion for ongoing use: olive or vegetable oil, herbs, and time. Unlike tea, which is made and drunk on the spot, oil matures slowly and then accompanies you for weeks — anointing candles, charms, wrists, and doorways with the intention it has carried since the very first day\n\nThe traditional preparation is patient: herbs inside a dark glass jar covered with oil, resting for about three weeks, shaken daily while you renew the intention under your breath or in thought. At the end, strain it and store it away from light. Rosemary in olive oil for vitality and garlic for protection are classic examples from kitchens and apothecaries through the ages\n\nIn daily life, the oil becomes a discreet tool: a drop on the candle before lighting it, a touch on the wrists before a difficult conversation, a line along the doorframe. Always label with name, date, and purpose — an organized witch is a powerful witch. The common mistake is forgetting the jar at the back of the cupboard: without the daily shaking, the spell loses its thread. And on skin, use only safe herbs and oils\n\nCarry this summary: magical oil is intention maturing in the dark, drop by drop, day after day. Time, constancy, and a well-made label turn a simple jar into a potion that works for you for weeks. Start your first jar today, and let the three weeks of waiting be, in themselves, part of the spell',
        practice:
            'Start a simple oil today, such as rosemary in olive oil, dedicated to an intention. First sanitize a dark glass jar and place the herb inside, covered with oil; then shake the jar every day while repeating the intention, for about three weeks; finally, strain it, label it with name, date, and purpose, and record the first use. Use only safe herbs and do not ingest the preparation. The goal is to practice patient magic, the kind that matures with time',
        pageTitle: 'My Magical Oil',
        pagePurpose: 'Prepare a ritual infused oil',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Vegetable oil', 'Herbs', 'Dark glass jar'],
        pagePrompts: [
          'Recipe (oil, herbs, proportions):',
          'Intention and planned uses:',
          'Start date and straining date:',
          'How the first use went:',
        ],
      ),
      TrailLesson(
        id: 'mv_08',
        recordKind: LessonRecordKind.note,
        title: 'The moon garden',
        teaching:
            'The moon is the great ruler of green magic\'s rhythms. Tradition plants what grows upward under the waxing moon and roots under the waning; harvests leaves of power at the full; rests the soil at the new. Aligning your green work with the lunar phases is stepping into the rhythm gardeners and witches have followed for generations — the rhythm of the sky keeping the earth\'s time\n\nThis knowledge comes from farmers\' almanacs and patient watching of the sky: the waxing moon favors beginnings and expansion, the full moon is the peak of power — time to harvest leaves and celebrate —, the waning moon calls for pruning and letting go, and the new moon invites rest and planning. More than agriculture, it is training in magical patience: not everything is for now, and each thing has its right moon\n\nDay to day, you need no vegetable garden to practice: watering, trimming dry leaves, moving a pot, or simply planning are already green actions that can follow the moon. The app\'s Lunar Calendar is your pocket almanac — check the phase before acting. The common mistake is forcing beginnings during the waning moon and growing frustrated: honoring rest is magic too\n\nKeep the rhythm: waxing begins, full harvests, waning releases, new rests. Whenever you are unsure of the right moment to act, look at the sky — or at your pocket almanac — and ask which moon you are in. In time, this rhythm stops being something you look up and becomes instinct: your garden and your life begin to turn together with the moon',
        practice:
            'Find TODAY\'s moon phase in the app\'s Lunar Calendar and perform a green action aligned with it: plant or begin something at the waxing, harvest or celebrate at the full, prune or release at the waning, rest and plan at the new. First check the phase, then choose the gesture that matches it and carry it out with presence; finally, note down what you did. The goal is to begin living the cycles instead of merely knowing them',
        pageTitle: 'My Green Calendar',
        pagePurpose: 'Align plantings and intentions with the moon',
        pageCategory: SpellCategory.prosperity,
        pagePrompts: [
          'At the next NEW moon I will (rest/plan):',
          'At the WAXING I will (plant/begin):',
          'At the FULL I will (harvest/celebrate):',
          'At the WANING I will (prune/release):',
        ],
      ),
      TrailLesson(
        id: 'mv_09',
        tool: LessonTool.addHerb,
        recordKind: LessonRecordKind.gratitude,
        title: 'Harvest and thanksgiving',
        teaching:
            'Harvesting is the forgotten half of planting. Many people learn to sow and to tend, but few learn to receive with reverence what the earth delivers. In green magic, the harvest is a complete rite in itself — and the way you harvest says as much about your practice as the way you plant\n\nThe traditional ritual harvest asks for four gestures: the right hour — by tradition, morning, after the dew has dried —, asking the plant\'s permission before touching it, a clean cut that wounds no more than necessary, and sincere thanks. And one golden rule: whole use, nothing harvested idly. This is how healers gathered their herbs of power, with the respect of one visiting a teacher\n\nDay to day, this applies even to a leaf from your pot or a fruit chosen at the market with presence: pause, ask permission in thought, harvest gently, give thanks. The common mistake is harvesting on autopilot, as if grabbing any ordinary object — haste breaks the bond. And remember: the same rite serves life\'s symbolic harvests — acknowledging what has arrived, giving thanks, and using it well\n\nCarry with you the green witch\'s golden rule: nothing harvested idly. Permission, clean cut, gratitude, and whole use — four simple gestures that turn the act of receiving into ceremony. Practice them on the plant and then on life: whoever learns to harvest with reverence discovers that gratitude is, in itself, a kind of fertilizer for the harvests to come',
        practice:
            'Harvest something today with the complete rite — it can be a leaf from your pot or a fruit from the market chosen with presence. First pause before the plant and ask permission in silence; then make the cut or the choice gently; next, give thanks in your own words; finally, use everything you harvested, with no waste. The goal is to learn to receive with the same reverence with which one plants. If you harvested a plant that has no entry of yours yet, photograph it through the shortcut below and add it to your Herb encyclopedia',
        pageTitle: 'My Harvest Rite',
        pagePurpose: 'Ritualize the act of harvesting',
        pageCategory: SpellCategory.prosperity,
        pagePrompts: [
          'What I harvested and how I asked permission:',
          'My thanks to the plant/to life:',
          'How I used everything I harvested:',
          'What symbolic harvest am I living right now?',
        ],
      ),
      TrailLesson(
        id: 'mv_10',
        tool: LessonTool.addHerb,
        recordKind: LessonRecordKind.note,
        title: 'Your magical herbal',
        teaching:
            'The last page of this trail is, in truth, a cover: the opening of your magical herbal, the living list of your plant allies with the uses tested by YOU. More than a notebook of jottings, the herbal is the portrait of your relationship with the green world — unique, personal, and untransferable, like all magic born of experience\n\nThe green witches of old kept their knowledge in recipe books, pressed leaves, and memory passed down through generations. The value of those records never lay in quantity, but in truth: every herb noted down had been harvested, prepared, and observed up close. Your herbal follows that same tradition — it is never finished, growing with each season, like the garden\n\nFrom here on, every new plant deserves its own page in your grimoire: name, direct observations, uses you yourself have tested, recipes that worked. Reread your green pages from time to time, and visit the Herb Encyclopedia whenever you wish to choose your next ally. The common mistake is copying ready-made tables without lived experience — record only what has passed through your hands\n\nCarry this certainty: you began the trail knowing a single plant, and you finish with a whole path ahead. The herbal grows at the garden\'s pace — one ally at a time, one season at a time, one page at a time. The earth has time, and now so do you: keep writing, and your green grimoire will bloom along with you',
        practice:
            'Close the trail by organizing your living index. First reread the green pages you wrote throughout the lessons, noting each plant and the use you truly tested; then visit the Herb Encyclopedia and choose the next ally you wish to know; finally, record why it called to you. The goal is to consolidate what was lived and make room for the herbal to keep growing season after season. And open the next page right now: photograph one of your plants through the shortcut below and create its entry in your Herb encyclopedia',
        pageTitle: 'My Herbal: Living Index',
        pagePurpose: 'Consolidate my plant allies',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'My allies so far (plant → tested use):',
          'The next plant I want to know and why:',
          'My favorite green ritual from this trail:',
          'What the earth taught me about time:',
        ],
      ),
    ],
  );
