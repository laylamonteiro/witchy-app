import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trail 'aguas_magicas' — English content.
/// Parity with _pt/_es checked in test/trails_parity_test.dart.
const LearningTrail aguasMagicasTrailEn = LearningTrail(
    id: 'aguas_magicas',
    emoji: '💧',
    title: 'Magical Waters',
    subtitle: 'Moon, Sun, rain, sea and river in your cauldron',
    description:
        'Every water carries a different memory and power: learn to gather, prepare and use the waters of nature — writing your own book of waters.',
    lessons: [
      TrailLesson(
        id: 'am_01',
        recordKind: LessonRecordKind.note,
        title: 'Water in witchcraft',
        teaching:
            'Water is the great conductor of magic: it dissolves, holds, carries and returns. In almost every witchcraft tradition it plays the three essential roles — cleansing what weighs, carrying intention and sealing the work. Before meeting the waters one by one, it helps to understand why this element is so central: water touches everything, crosses everything and changes shape without losing its essence.\n\nThe traditions say water has memory: it absorbs the energy of the place it came from and of the moment it was gathered. That is why rainwater does not serve the same work as sea water, and water gathered under the full moon is not the same as water gathered at noon. To gather water is to gather a moment — and that is the art this trail teaches.\n\nIn everyday life, the witch of the waters works with what she has: tap water is water too, and it can be blessed. But the special waters — moon, sun, rain, storm, sea, river — are reserves of concentrated energy for the works that ask for more strength. The golden rule from the start: always label your jars with the type of water and the date it was gathered.\n\nKeep this image: every jar of water on your shelf is a bottled moment. In this trail you will learn to gather each one, what they are for and how to release them with respect. Your first page is the inventory of what you already have — and of what you want to gather.',
        practice:
            'Make your inventory of waters today. First, observe: which waters pass through your life — rain on the window, a river on your way, the sea near or far? Then set apart 2 or 3 clean glass jars, wash them well and let them dry. Finally, write labels with the names of the first waters you want to gather. The goal is to prepare the ground: the witch of the waters begins by organizing her jars.',
        pageTitle: 'My Book of Waters',
        pagePurpose: 'Open the inventory of my magical waters',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Glass jars', 'Labels'],
        pagePrompts: [
          'Waters that exist near me:',
          'Jars I prepared:',
          'The first water I want to gather and why:',
          'Where I will keep my stock:',
        ],
      ),
      TrailLesson(
        id: 'am_02',
        recordKind: LessonRecordKind.note,
        title: 'Moon water',
        teaching:
            'Moon water is the most classic of the magical waters: clean water left under the light of the full moon to absorb the height of lunar power. It carries the qualities of the Moon — intuition, emotion, mystery, gentle cleansing — which makes it the favorite water for consecrating tools, blessing objects and preparing delicate purification baths.\n\nThe traditional gathering is simple: a glass container with drinking water, exposed to the moonlight of the full moon night (window or open sky), collected before sunrise. The morning sun "burns" the lunar energy — that is why timing matters. On the Moon page of the Encyclopedia there is a step-by-step guided ritual for Moon Water: use it on the next full moon as the practice of this lesson.\n\nTime-honored uses: cleansing crystals and decks (the ones that accept water), anointing candles before intuition and dream spells, adding a little to the bath to dissolve emotional weight, lightly watering plants of lunar workings and blessing mirrors and scrying glasses. A few drops are enough — moon water is concentrated by nature.\n\nKeep it in the dark, in a jar labeled with the date and, if you like, the name of the moon (Wolf Moon, Flower Moon...). Its validity is the next cycle: when the new full moon arrives, return the old water to the earth with gratitude and gather fresh. Moon water is not hoarded — it is renewed.',
        practice:
            'Schedule your gathering: check in Your Day when the next full moon is and leave the jar ready in advance. If the full moon is today or tomorrow, follow the guided Moon Water ritual on the Moon page of the Encyclopedia. If there is still time to wait, practice the second part: decide now WHAT the first use of your moon water will be — a bath, a crystal cleansing, a candle anointing — and write the steps on your page.',
        pageTitle: 'My Moon Water',
        pagePurpose: 'Record the gathering and uses of my moon water',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Glass jar', 'Drinking water', 'Full moon light'],
        pagePrompts: [
          'Date and moon of my gathering:',
          'How the night was (sky, feelings):',
          'The first use I will give it:',
          'What I felt when using it:',
        ],
      ),
      TrailLesson(
        id: 'am_03',
        recordKind: LessonRecordKind.note,
        title: 'Sun water',
        teaching:
            'If moon water calms and deepens, sun water awakens and strengthens. It is water charged under direct sunlight — preferably on a Sunday morning, the solar day, or on a sun sabbat like Litha — and it concentrates vitality, courage, joy and the power to accomplish. It is the water of energetic new beginnings.\n\nThe gathering mirrors the lunar one: a glass container with drinking water exposed to the morning sun for 2 to 4 hours. The midday sun is too harsh for some delicate works; the morning sun is pure vitality. On the Sun page of the Encyclopedia there is a complete guided ritual for Sun Water — it is the ideal practice for this lesson.\n\nTime-honored uses: spraying the corners of the house to chase away stagnation, anointing candles for courage and prosperity work, adding some to the floor-washing bucket to renew the energy of the home, and a symbolic sip (of clean, fresh water) before a day that asks for strength. Careful with crystals: some fade in the sun — charge in sun water only the ones that accept light, like citrine and carnelian.\n\nSun water asks for quick use: gather it, use it. Tradition says it keeps its warmth for only a few days — after that, water a plant with it and gather again. Label it with the date and the weekday: a Sunday sun water is the most solar of all.',
        practice:
            'Gather your first sun water this week: an open-sky morning, a glass jar, 2 to 4 hours of direct sunlight. If possible, follow the guided Sun Water ritual on the Sun page of the Encyclopedia. Then use it the same day: spray the corners of the room where you live the most, asking in a low voice for vitality to circulate. Note on your page what changed in the space and in you.',
        pageTitle: 'My Sun Water',
        pagePurpose: 'Record the gathering and uses of my sun water',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Glass jar', 'Drinking water', 'Morning sun'],
        pagePrompts: [
          'Day and time of my gathering:',
          'How I used the water the same day:',
          'What felt different in the space:',
          'What I want the next gathering for:',
        ],
      ),
      TrailLesson(
        id: 'am_04',
        recordKind: LessonRecordKind.note,
        title: 'Rainwater',
        teaching:
            'Rainwater is the blessing that falls from the sky for free: water of growth, renewal and fertility for your workings. It comes "from above", and the traditions link it to natural purification — rain washes the world — and to growth, because rain is what makes things sprout. It is one of the most versatile waters in the witch\'s book.\n\nGathering: a clean glass or ceramic container in an open spot — never under a roof or gutter, which contaminate the water and the intention. The rain at the start of a downpour is considered the most potent; the gentle rain of a whole day carries steadiness and patience. Let nature fill the jar at her own pace.\n\nTime-honored uses: watering spell plants and the plants of your personal encyclopedia (they love it), washing your hands before a growth working, adding it to renewal baths after hard cycles and moistening seeds — literal or symbolic — planted on the new moon. Rainwater is the natural partner of prosperity workings that need to GROW slowly and steadily.\n\nAs it is not drinkable, rainwater is never drunk — external and ritual use only. Keep it labeled ("gentle rain", "March rain") and renew it when the smell changes. Return the old water to your plants: what came from the sky goes back to the earth.',
        practice:
            'On the next rain, place a clean container in a fully open spot and let it gather. While it rains, spend a minute at the window observing: what kind of rain is this — a washing, a relief, a growth? Name the water after what you felt. Then use half of it to water a beloved plant with an intention of growth, and keep the other half labeled for the next working.',
        pageTitle: 'My Rainwater',
        pagePurpose: 'Record the gathering and uses of rainwater',
        pageCategory: SpellCategory.prosperity,
        pageIngredients: ['Clean container', 'Rain', 'Open spot'],
        pagePrompts: [
          'Date and the "kind" of rain I gathered:',
          'The name I gave this water:',
          'The plant or working it watered:',
          'What I want to grow with it:',
        ],
      ),
      TrailLesson(
        id: 'am_05',
        recordKind: LessonRecordKind.note,
        title: 'Storm water',
        teaching:
            'Storm water is the wild sister of rainwater: gathered during thunderstorms and gales, it carries raw potency — breaking blockages, courage, strength to turn the game around. It is a water of respect, used in small doses in the workings that need a push gentle water cannot give.\n\nGathering with safety first: the container goes to the open spot BEFORE the storm or between showers — never stay outside under lightning. The clever witch sets the jar out when the sky darkens and collects it when the weather calms. Tradition says the stronger the thunder during the gathering, the more "charged" the water.\n\nTime-honored uses: anointing candles for banishing and blockage-breaking work, washing (a few drops) amulets that need extra strength, adding a spoonful to the heavy house-cleaning bucket after fights or difficult visits, and touching your own forehead with a wet finger before a conversation that demands courage. Small amounts, strong intention.\n\nThis water is not for everyday use: keep one small jar, well labeled ("January storm"), away from the gentle waters. When the working is done, release it to the earth, thanking the borrowed force. A storm that fulfilled its role is not kept out of nostalgia.',
        practice:
            'Prepare your "storm kit" today, even under a clear sky: a small jar, a written label and a defined spot outside to place it when the weather turns. Rehearse the gesture: exactly where the jar goes, how you retrieve it without standing under lightning. On the next thunderstorm, gather safely and note on your page what the storm seemed to want to break.',
        pageTitle: 'My Storm Water',
        pagePurpose: 'Record the gathering and uses of storm water',
        pageCategory: SpellCategory.banishing,
        pageIngredients: ['Small jar', 'A storm', 'Caution'],
        pagePrompts: [
          'Date and strength of the storm:',
          'How I gathered it safely:',
          'The blockage I want to break with it:',
          'How and where I released it after use:',
        ],
      ),
      TrailLesson(
        id: 'am_06',
        recordKind: LessonRecordKind.note,
        title: 'Sea water',
        teaching:
            'Sea water is the planet\'s great cauldron: salty, alive and merciless with what no longer serves. The salt makes it the most powerful water for heavy cleansing, banishing and protection — the sea takes away what we hand over to it. It is the water of true spiritual deep-cleanings.\n\nGathering: at the sea, feet on the sand, preferably thanking Yemanja or the sea deity of your tradition — gathering water is receiving a gift, not taking one. Far from the sea? Tradition accepts the honest substitute: clean water with coarse salt dissolved in it, consecrated with the intention of the ocean. It is not the same, but it works.\n\nTime-honored uses: heavy cleansing of objects that arrived "loaded" (the ones that accept salt), cleansing baths from the neck down, washing the doorstep of a house that received bad energy, and protection circles traced with salted water in the corners of the room. Attention: salt corrodes metals and dries out plants — never use sea water on delicate crystals, metal tools or on your herb pots.\n\nThe release is part of the rite: salted water used in cleansing does not go back to the plants — it goes down the drain with thanks, taking along what it captured. Keep little, use it soon, and whenever you can, renew it at the source: a trip to the sea is, in itself, the greatest cleansing bath there is.',
        practice:
            'If the sea is within your reach, go to it this week: wet your feet, give thanks, gather a small jar and leave a simple, biodegradable offering (a flower). If it is not, prepare the substitute: dissolve coarse salt in clean water while naming the intention of the ocean. Then do a small, real cleansing — the door handle, the doorstep, a heavy object — and feel the difference of salted water.',
        pageTitle: 'My Sea Water',
        pagePurpose: 'Record the gathering and uses of sea water',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Jar', 'Sea water (or water + coarse salt)'],
        pagePrompts: [
          'Where my water came from (sea or preparation):',
          'What I thanked/offered when gathering:',
          'The cleansing I did with it:',
          'What the sea took away:',
        ],
      ),
      TrailLesson(
        id: 'am_07',
        recordKind: LessonRecordKind.note,
        title: 'River water',
        teaching:
            'The river is movement that never stops: river water carries unblocking, flow and the art of letting go. Where the sea rips away, the river conducts — it gently carries off what stagnates, which makes it the water for opening paths, releasing what binds and recovering the flow of life.\n\nGathering: from a running and as-clean-as-possible river, always from moving water — never from still puddles at the bank. Tradition asks the river for permission first (every river has an owner, a spirit or a name) and recommends gathering with the current, letting your hands feel the movement. A coin or a flower given to the water pays the passage.\n\nTime-honored uses: washing your hands when closing a cycle (a job, a relationship, a mourning), anointing your feet before new paths — an interview, a move, a journey —, spraying stalled documents and projects to unblock them, and the classic river rite: giving the current a leaf with what you want to release, written in pencil, and watching it go.\n\nRiver water is also never drunk — external ritual use only. Keep little of it, labeled ("such river, gathered on..."), and always prefer fresh water: the river\'s power lies in movement, and river water stored for months has become the opposite of what it was. When in doubt, go to the river again — the way there is already part of the spell.',
        practice:
            'Find the moving water near you — a river, a creek, a clean stream or even a running spring. Ask for permission, gather a little and do the leaf rite on the spot: write in pencil one thing that needs to flow or leave, fold it and give it to the current, watching until it disappears. At home, use a few drops on your feet before the next new path life asks of you.',
        pageTitle: 'My River Water',
        pagePurpose: 'Record the gathering and uses of river water',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Jar', 'Running river water'],
        pagePrompts: [
          'The river (or running water) I found:',
          'What I gave to the current:',
          'The path I want to unblock:',
          'What I felt when the leaf departed:',
        ],
      ),
      TrailLesson(
        id: 'am_08',
        recordKind: LessonRecordKind.note,
        title: 'Dew, spring water and other rare waters',
        teaching:
            'Before closing the book, the rare waters — the ones you do not gather when you want, but when nature offers. Dew, gathered early in the morning by running a clean cloth over leaves or leaving a bowl on the grass overnight, is the water of beauty, youth and delicate beginnings. Tradition says to wash your face with dew on the first day of May, and drops of it bless any self-love working.\n\nSpring or fountain water is purity in its raw state: water born from the earth, ideal for consecrations, blessings and for "baptizing" new tools. If there is a natural spring on your path, it is worth the trip — water gathered at the source itself, with permission asked, is among the most precious in a witch\'s stock.\n\nWell water, deep and kept in the darkness of the earth, serves the workings of mystery, secrecy and ancestry — it is the water of old questions. And melted ice, thaw water, carries the power of slow transitions: excellent for unfreezing, drop by drop, situations stuck for a long time. Even mist caught on a cloth has a name in the traditions: veil water, for workings of discretion.\n\nWhat these waters share: they are not planned, they are received. The witch of the waters carries an empty jar in her bag and keeps her eyes open — when nature offers a rare water, she gives thanks and gathers. Your page for this lesson is the map of the rare waters possible in your life.',
        practice:
            'Make your map of the rare waters: think about your routine and your region and list where you could gather dew (a garden, a park in the morning), spring water (a known natural spring?), well water or thaw water. If you can, gather dew early tomorrow with a clean cloth and touch it to your face while naming a delicate beginning you want for yourself. Note on your page what is already possible today and what remains a promise.',
        pageTitle: 'My Map of Rare Waters',
        pagePurpose: 'Map the rare waters within my reach',
        pageCategory: SpellCategory.selfLove,
        pageIngredients: ['Clean cloth', 'Small jar', 'Attention'],
        pagePrompts: [
          'Where I can gather dew:',
          'Springs or fountains I know:',
          'The rare water I want to gather one day:',
          'The delicate beginning I named for myself:',
        ],
      ),
      TrailLesson(
        id: 'am_09',
        recordKind: LessonRecordKind.note,
        title: 'Sacred release and your stock',
        teaching:
            'The last lesson is the art nobody teaches: the release. Every magical water has a proper destination, and returning it well matters as much as gathering it well — the cycle only completes when the water goes back to the world. A water forgotten at the back of the cupboard is not a reserve: it is unfinished work.\n\nThe general rule: sweet, clean waters (moon, sun, rain, dew, spring) return to the earth — water plants, give them back to the garden, offer them to a flowerbed. Heavy-work waters (salt, storm water used in banishing, cleansing water that "captured" something) go down the drain or into the earth far from plants, always with thanks for the service rendered.\n\nAnd the golden rule of the temples: never pour working water into a clean river or sea. They are not a bin — they are the source. What returns to nature must go back clean or neutral; what carries residue leaves through the ways of the house (drain, distant earth). The witch who respects the waters is respected by them.\n\nYour ideal stock is small and alive: a few jars, all labeled with type and date, renewed each cycle. The witch of the waters does not collect — she gathers, uses, thanks and returns. With the inventory of the first lesson and the waters of the whole trail, your book of waters is open: it grows with every rain, every moon and every tide of your life.',
        practice:
            'Close the trail\'s cycle with a full review of your stock: bring together all the jars you gathered, check labels and dates, and decide the destination of each one — use this week, renew, or return to the earth with gratitude. Perform at least one sacred release today, in the right way for that type of water. Record on your page the final state of your book of waters.',
        pageTitle: 'Closing My Book of Waters',
        pagePurpose: 'Review my stock and the destination of each water',
        pageCategory: SpellCategory.wisdom,
        pageIngredients: ['My jars', 'Labels', 'Gratitude'],
        pagePrompts: [
          'The waters I have today (type and date):',
          'What I returned to the earth and why:',
          'How my final stock looks:',
          'What the waters have taught me so far:',
        ],
      ),
    ]);
