import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// 'bruxaria_tradicional' trail — English content.
/// Parity with _pt/_es checked in test/trails_parity_test.dart.
const LearningTrail bruxariaTradicionalTrailEn = LearningTrail(
    id: 'bruxaria_tradicional',
    emoji: '🧹',
    title: 'Traditional Witchcraft',
    subtitle: 'The crooked path and the old knowledge',
    description:
        'The witchcraft of folklore, folk healers and the crooked path: spirits of place, ancestors and everyday tools — no dogma, deep roots.',
    lessons: [
      TrailLesson(
        id: 'bt_01',
        recordKind: LessonRecordKind.note,
        title: 'The spirits of place',
        teaching:
            'Traditional witchcraft is rooted in place: rivers, crossroads, backyards, street corners. Before any tool or grimoire, the first step is to know the ground you walk on, because the magic of this path does not come from distant books — it is born of a living relationship with the land. Every territory has its spirits, and the witch who knows them practices with roots, not on loan.\n\nNearly every people has recognized spirits of place: European folklore speaks of guardians of springs, groves and hills, and Brazil is immensely rich in enchanted beings — the mother of the river, the saci, the curupira, the souls of the old gateways. You befriend them as you befriend people: regular presence, small respectful offerings, patient listening. That is why local folklore is the most honest spiritual map there is: it tells you who has been living there for a very long time.\n\nIn everyday life, this becomes attentive walking: noticing the oldest tree on the street, the corner where the air changes, the plot of land that asks for silence. Start small — clean water, a flower, a greeting in thought — and demand nothing in return. The beginner\'s common mistake is importing fashionable spirits and ignoring her own backyard; another is taking leaves and stones without asking permission. Respect opens more doors than any elaborate ritual.\n\nTake this idea with you: you do not practice on the land, you practice with it. Friendship with the spirits of place is built like every friendship — with constant presence and true respect. Get to know your ground, and your ground will come to know you. That is the foundation of the entire crooked path.',
        practice:
            'Walk 15 minutes through your neighborhood as a witch: go out unhurried and without headphones, noticing where the energy shifts, which place calls to you and what stories the elders tell about the area. When you return, note on your page the spots that stood out and think about the first respectful offering you would like to leave. The goal is to begin the spiritual map of your territory and to open, with presence and listening, the relationship with the spirits of place.',
        pageTitle: 'The Spirits of My Place',
        pagePurpose: 'Map the spiritual territory where I live',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Places of power near me:',
          'Stories and folklore of the area:',
          'My first respectful offering (what, where):',
          'What I felt:',
        ],
      ),
      TrailLesson(
        id: 'bt_02',
        recordKind: LessonRecordKind.note,
        title: 'Ancestors: the living lineage',
        teaching:
            'In traditional witchcraft, the dead are not far away: the ancestors are first-hour allies, present in the daily life of those who honor them. They form three streams — those of blood, from your family; those of affection, whom you loved without kinship; and those of the craft, the witches and folk healers who came before. Honoring them matters because no one walks alone: every practice rests on those who opened the trail first.\n\nAncestor veneration crosses nearly every culture: tables set for the dead in European folklore, the day of the departed, the Brazilian benzedeiras who ask the old ones for leave before praying. The traditional altar is simple: a clean surface, a glass of water, a candle, a photo or object of someone who has passed. The water is renewed, the candle is lit, and the conversation happens as with a loved one who has merely moved to another room.\n\nIn practice, choose a quiet corner of the house and tend it with constancy: renew the water on a fixed day, speak naturally, give thanks before asking. A common mistake is treating the altar as a request counter; another is thinking only those you knew in life count — the lineage of affection and of craft counts too. And remember: you choose whom you honor. Only invite to your altar those who bring peace to your heart.\n\nKeep this key: to remember is to keep alive. You are the continuation of many hands, many prayers and many names, and the glass of water renewed every week is worth more than the grand ritual performed only once. Ancestral devotion is made of small constancy, sincere presence and true affection.',
        practice:
            'Light a candle for your ancestors in a calm moment. Before the flame, say in a low voice that you remember them, that you give thanks for what you have received and that you invite them to walk the path with you. Then set up or renew the corner with the glass of water and an object or photo of those you honor. The goal is to begin the living bond with your lineage and turn remembrance into daily, affectionate devotion.',
        pageTitle: 'My Ancestor Altar',
        pagePurpose: 'Begin devotion to those who came before',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Glass of water', 'Candle', 'Object or photo'],
        pagePrompts: [
          'Where I set it up (the corner):',
          'Whom I honor:',
          'My greeting to them:',
          'The day I renew the water:',
        ],
      ),
      TrailLesson(
        id: 'bt_03',
        title: 'The tools of everyday life',
        teaching:
            'The traditional witch does not wait for the esoteric shop: the broom sweeps energy, the scissors cut ties, the needle stitches fates, the wooden spoon stirs intentions. Power lies not in the price or the shine of the object, but in the conscious use you make of it. This is one of the oldest marks of folk witchcraft — working with what the house already offers, turning the ordinary into the sacred.\n\nFolklore confirms this heritage: the iron horseshoe over the door, the open scissors behind it, the knife that cuts heavy air, the sieve and the key used in old divinations. Ordinary objects become guardians because they carry a history of use and closeness to life. Consecrating follows a simple logic: cleanse the object, declare aloud its new role and use it only for that — exclusivity is what carries the power.\n\nIn everyday life, this means looking at your own home with a witch\'s eyes before buying anything. The beginner\'s common mistake is consecrating ten objects at once and using none, or mixing the ritual tool with its ordinary function — the consecrated broom never touches physical dirt. Start with a single object, cleanse it with salt or smoke, give it a clear role and keep it with respect, apart from the rest.\n\nThe idea to memorize: magic lives in the relationship, not in the object. A spoon consecrated with truth is worth more than an expensive dagger with no history at all. Your home is already a small magical arsenal awaiting your gaze — awaken one tool at a time, calmly, with constant use and clear intention.',
        practice:
            'Walk through your home calmly and choose ONE object to consecrate as your first tool. Hold the candidates in your hands and notice which one seems to accept the work — there is usually one that stands out. Then cleanse the chosen one with salt or smoke, declare aloud its new function and keep it apart, for that use alone. The goal is to begin your set of consecrated tools and train your listening to objects.',
        pageTitle: 'My Witch Tools',
        pagePurpose: 'Consecrate everyday objects',
        pageCategory: SpellCategory.other,
        pageIngredients: ['The object', 'Salt or smoke'],
        pagePrompts: [
          'Chosen object and its magical function:',
          'How I cleansed and consecrated it:',
          'Words of the consecration:',
          'Next objects I intend to consecrate:',
        ],
      ),
      TrailLesson(
        id: 'bt_04',
        title: 'The crossroads: where the roads speak',
        teaching:
            'In almost every tradition, the crossroads is a place of power: where the roads cross, the worlds touch as well. There the common road becomes a portal — a point of decisions, passages and open possibilities. For traditional witchcraft, knowing the crossroads matters because it teaches the essence of the crooked path: every choice opens one direction and closes another, and there are forces that guard these passages.\n\nFolklore is unanimous: in ancient Greece, Hekate received offerings at the crossings; in Europe, the crossways were points of meetings, oaths and hauntings; in Brazil, the African-rooted traditions honor at the crossroads the guardians of the roads, with deep foundations of their own. There, traditionally, workings are left, requests for opening are made and thanks are given to those who guard the passages — always with leave and reverence.\n\nFor the beginner, the golden rule is respect: a crossroads is not a ritual dumping ground. If you leave an offering, let it be biodegradable, discreet and in a safe spot; never pick up what others have left, and do not copy rituals from traditions you do not know from within. In everyday life, crossing with awareness is enough: a silent greeting, given from the heart, is already recognition of the one who guards the point.\n\nTake this image with you: all of life is made of crossroads, and the witch does not fear the crossings — she salutes them. Ask for open roads, give thanks for the passages and keep walking with confidence. Whoever respects the point where the worlds touch learns, little by little, to cross through their own choices.',
        practice:
            'Pass through a crossroads on your usual route with full awareness: pause a moment in a safe spot, breathe deeply, silently greet those who guard the passages and make a quiet request for open roads in your life. Then move on without anxiety, watching what the day answers. The goal is to recognize points of power along the ordinary route and to train the simple reverence of the crooked path.',
        pageTitle: 'My Crossroads Rite',
        pagePurpose: 'Work on opening roads',
        pageCategory: SpellCategory.luck,
        pagePrompts: [
          'The crossroads that calls me (what it is like):',
          'My request for open roads:',
          'My respectful offering (if any):',
          'Signs I noticed afterwards:',
        ],
      ),
      TrailLesson(
        id: 'bt_05',
        recordKind: LessonRecordKind.affirmation,
        title: 'Blessing: the word that heals',
        teaching:
            'The benzedeiras are Brazil\'s living traditional witchcraft: women and men who heal with word, green branch and faith, door open, charging nothing. Folk blessing matters because it is the magical lineage closest to you — it may exist in your own family — and it proves that the word spoken with intention is one of the oldest and most powerful healing tools in the world.\n\nThe structure of a blessing is functional poetry: first it names the ill — the evil eye, envy sickness, fallen chest —, then it invokes the greater force, sends the ill far away, to the waves of the sea or to the ends of the earth, and finally seals the work. The green branch, of rue or guinea hen weed, takes part: when it wilts, tradition says, it is because it carried away what it drew out. This heritage blends Iberian prayers with Indigenous and African knowledge into a medicine made of word.\n\nIn your daily life, start with research: grandmothers, neighbors and local records keep precious versions. Use what you learn for self-care — blessing your own water, your own sleep — and avoid two common mistakes: treating the prayer as an empty formula, without faith or presence, and presenting yourself as a benzedeira without having received the office. The traditional gift is received and cultivated; respect for those who keep it is part of the practice.\n\nStay with this key: the word spoken with faith is ancient medicine. Honor the source of every prayer you learn, speak it with your heart present, and you will be keeping alive one of the most beautiful currents of Brazilian tradition — the one that heals for free, on the doorstep, with a green branch in hand.',
        practice:
            'Research ONE traditional blessing from your region: ask grandmothers and neighbors or search local folklore records. Copy the prayer onto your page as a relic, noting who taught it or where you found it. Then create a simple version for self-care and try it with a green branch, such as rue or guinea hen weed. The goal is to honor the lineage of the benzedeiras and keep your first word of healing.',
        pageTitle: 'My First Blessing',
        pagePurpose: 'Honor and practice the word that heals',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Green branch (rue, guinea hen weed...)'],
        pagePrompts: [
          'Traditional blessing I found (and the source):',
          'My version for self-care:',
          'The gesture that goes with it:',
          'When I used it and what I felt:',
        ],
      ),
      TrailLesson(
        id: 'bt_06',
        title: 'The broom: sweeping is rite',
        teaching:
            'The witch\'s broom does not fly — it sweeps worlds. In traditional witchcraft, sweeping was never mere cleaning: it is a rite of protection and renewal hidden in the most ordinary gesture of the home. Direction matters: sweeping from the door inward draws luck into the home; sweeping outward expels what is dense and heavy. The most mundane instrument of the house is also one of the oldest in folk magic.\n\nFolklore holds many layers: the broom behind the door drives away unwanted visitors, says Brazilian popular belief; in Europe, jumping the broom sealed unions and sweeping the threshold protected the boundary of the house. The ritual broom is the one that never touches physical dirt — it lives lying behind the door or hanging on the wall, guarding the entrance. And the yard swept in the morning was the daily protection of the old ones: the rite disguised as routine.\n\nIn practice, you can keep a broom just for the rite or ritualize the ordinary sweeping: what changes is the intention. As you sweep outward, name what leaves along with the dust — tiredness, quarrels, heaviness; when you finish, call in what should enter the clean space. Common mistakes: sweeping in anger, scattering the dense instead of guiding it out, and letting the ritual broom become an ordinary cleaning object. Sweep slowly, as one prays.\n\nTake this with you: the rite lives hidden in the common gesture. Your house swept with intention is your first circle of protection, remade every day without anyone noticing. Where the broom passes with awareness, the dense does not settle. That is the magic of the old ones: simple, daily and powerful.',
        practice:
            'Sweep one room today as a complete rite: begin by sweeping toward the door and outward, naming in a low voice what leaves with the dust — tiredness, arguments, accumulated heaviness. Then, from the door inward, call in what you wish for the clean space: luck, calm, protection. Finish by thanking the house. The goal is to turn ordinary cleaning into a rite of protection and feel in practice the power of the simple gesture.',
        pageTitle: 'My Witch Broom',
        pagePurpose: 'Ritualize the cleaning of the house',
        pageCategory: SpellCategory.cleansing,
        pagePrompts: [
          'My ritual broom (which one it is, where it lives):',
          'What I say while sweeping outward:',
          'What I call in while sweeping inward:',
          'How the house felt after the rite:',
        ],
      ),
      TrailLesson(
        id: 'bt_07',
        title: 'Bottles and home protections',
        teaching:
            'The witch bottle is a traditional protection with centuries of history: a glass container filled with symbolic sharp items, protective elements and something of yours, sealed and hidden in the house. It works as a silent guardian — it absorbs and traps the harm directed at you before it reaches you. It is the classic defense of folk witchcraft: discreet, long-lasting and homemade.\n\nBottles like these have been found by archaeologists beneath English hearths and thresholds since the seventeenth century, full of nails, pins and personal items of those they protected. The traditional logic is decoy: containing something of yours, the bottle passes for you; the harm finds it first, gets caught in the sharp elements and is neutralized by the protective ones. The modern version uses a small jar, salt, rosemary or rue, a strand of hair and candle wax to seal.\n\nIn practice, assemble yours in a calm moment, with clear intention, and hide it in a discreet spot: the back of a wardrobe, a high corner, the garden. Once sealed, it is not opened — if one day you feel it has done its work, give thanks and discard it with respect, assembling another. The common mistake is displaying the bottle or telling where it is: hidden protection works better. Another is using dangerous items without care; the symbol is enough.\n\nKeep this idea: not every defense needs to be visible. The bottle teaches the magic of discretion — protection that works in silence, day and night, asking for no attention and no constant upkeep. Assemble yours calmly and let the guardian handle what should never reach you. A protected home is a home that sleeps in peace.',
        practice:
            'Calmly gather the materials for your protection bottle: a small jar with a lid, salt, protective herbs such as rue or rosemary, a strand of your hair and a candle to seal with wax. Keep everything together and assemble it when you feel ready, in a quiet moment, placing each item with intention and sealing with your own words. The goal is to create the silent guardian of the home and hide it in a discreet spot.',
        pageTitle: 'My Protection Bottle',
        pagePurpose: 'Assemble the silent guardian of the home',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Small jar', 'Salt', 'Protective herbs', 'Wax'],
        pagePrompts: [
          'What I put inside and the reason for each item:',
          'My words while sealing:',
          'Where it is hidden:',
          'When I intend to renew it:',
        ],
      ),
      TrailLesson(
        id: 'bt_08',
        recordKind: LessonRecordKind.dream,
        title: 'Dreams and signs: the crooked listening',
        teaching:
            'The crooked path listens to the world: dreams that insist, animals crossing the road, objects falling on their own, names heard three times in the same day. This is not paranoia — it is poetic attention, an ancient way of perceiving that life speaks through patterns and images. For traditional witchcraft, the world is always in conversation; the witch is the one who decides to listen carefully.\n\nOmens run through folklore: the owl on the roof, the butterfly entering the house, the dream of teeth, the visit announced by the fallen spoon. The traditional method is to record without interpreting on the spot — meaning ripens with time, and the patterns only appear to those who accumulate records. Dreams are the richest part of this listening: the app\'s Dream Journal and Dream Meanings are your allies in this work.\n\nIn practice, keep a notebook of signs: note the date, the context and what happened, without judging whether it matters. Reread it once a week looking for repetitions. The beginner\'s common mistakes are two opposites: turning everything into an omen and living anxiously, or deciding your whole life on a single isolated sign. The balance is to record a lot, conclude slowly and let the pattern reveal itself.\n\nThe key to take with you: the world speaks softly, and those who write it down learn the language. One sign is a curiosity; three repeated signs are a conversation. Record without hurry, reread with attention, and the crooked listening will become your second nature — the witch\'s silent radar in the middle of ordinary life.',
        practice:
            'Today, note three coincidences or signs of the day — an animal that crossed your path, a phrase heard at the exact moment, an object that fell out of nowhere. Record only the fact, the date and the context, interpreting nothing for now. Keep the notes and reread everything a week from now, looking for repetitions and connections. The goal is to train the listening of omens and discover how patterns speak over time.',
        pageTitle: 'My Notebook of Signs',
        pagePurpose: 'Train the listening of omens',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'The signs I noticed this week:',
          'Patterns that already repeat in my life:',
          'My recording agreement (where, when):',
          '(In 7 days) What the signs formed together:',
        ],
      ),
      TrailLesson(
        id: 'bt_09',
        recordKind: LessonRecordKind.desire,
        title: 'The crooked path: a pact with yourself',
        teaching:
            'Traditional witchcraft does not ask for conversion — it asks for coherence. The true pact of the crooked path is not with any entity: it is with yourself. It means practicing what works, honoring what sustains you and abandoning without guilt what is mere ornament. This honesty matters because a path without dogma is only sustained by the real, daily commitment of the one who walks it.\n\nThe devil\'s pact of the witch trials was a caricature created by the accusers — in living folklore, the commitment was always to the craft. The benzedeira keeps her gift through use: if she stops blessing, the prayer grows cold. Traditional knowledge is sustained by constant practice, not by solemn oaths. That is why the crooked path values what is truly done: three lived practices are worth more than thirty beautiful ideas kept in a drawer.\n\nIn your routine, this calls for an honest review from time to time: what from the trails became a real habit? What did you only admire and never do? The common mistake is accumulating shelf rituals — practices that exist only in the notebook — and carrying guilt for not keeping up with everything. The traditional witch simplifies: she chooses her non-negotiable practices, does them well and lets the rest go without drama.\n\nTake this synthesis: no dogma, deep roots. Your path is worth what you actually live, not what you accumulate in theory. Seal the pact with yourself — few practices, true and sustained — and the crooked path becomes unshakable, because it will be planted in real ground, watered every day.',
        practice:
            'Calmly reread the pages you created in this trail, one by one. Mentally sort them into two groups: what has become real practice in your routine and what remained merely pretty on paper. Then record your non-negotiable practices, what you abandon without guilt and what you commit to in this cycle. The goal is to seal your practitioner\'s pact: an honest agreement with yourself, without dogma and with roots.',
        pageTitle: 'My Practitioner\'s Pact',
        pagePurpose: 'Seal my agreement with the path',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'My non-negotiable practices (the ones I truly do):',
          'What I abandon without guilt:',
          'What I commit to in this cycle:',
          'The phrase that sums up my crooked path:',
        ],
      ),
      TrailLesson(
        id: 'bt_10',
        recordKind: LessonRecordKind.note,
        title: 'Transmission: keeping and passing on',
        teaching:
            'All traditional knowledge survives through transmission: the grandmother who blesses and teaches the prayer, the neighbor who passes on the right tea, the hand that guides another hand. Without this chain, entire crafts die with those who kept them. By arriving here, you have become a link in that chain — keeper of what you have learned and, one day, a bridge for someone who does not yet know they will need you.\n\nTraditional transmission has its ways: it is oral, close and chosen. The benzedeira does not teach just anyone — she observes, waits for maturity and, in some regions, only passes on the prayer on special dates, such as Good Friday. The gesture is learned by watching, the recipe goes from hand to hand, and the family notebook crosses generations. That is how knowledge outlasts time: one person trusting another, one link at a time.\n\nIn your daily life, transmitting begins with keeping well: write your pages as one leaves an inheritance, with clarity, naming from whom you learned each thing. When someone asks with respect, teach the simple first. The common mistakes are the extremes: hoarding everything out of avarice until the knowledge dies with you, or carelessly spreading what was entrusted with a request for discretion and reserve.\n\nStay with this image: you are a bridge between those who came before and those still to come. Every page written with truth is a seed of the chain. Keep with care, pass on with generosity — and your crooked path will remain alive far beyond you, like all knowledge that was loved and well tended.',
        practice:
            'Think of a person, real or future, to whom you would entrust your knowledge — it can be a family member, a friend or someone yet to arrive. List what you would teach first and why, and record on the page the three teachings you would pass on, along with the advice you would give to someone starting out. The goal is to turn what you have learned into legacy and take your place in the chain of transmission.',
        pageTitle: 'What I Leave to the Chain',
        pagePurpose: 'Record what deserves to be passed on',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'The 3 teachings I would pass on:',
          'To whom (real or symbolic):',
          'The story of my lineage so far:',
          'The advice I would give to someone starting out:',
        ],
      ),
    ],
  );
