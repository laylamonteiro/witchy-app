import 'guided_ritual_model.dart';

/// Guided rituals content — English.
/// Parity with PT/ES checked in test/guided_rituals_parity_test.dart.

const Map<String, GuidedRitualText> guidedRitualTextsEn = {
  'sabbat_samhain': (
    title: 'Samhain Ritual',
    intro:
        "The Witches' New Year. The veil between worlds is at its thinnest: tonight we honor ancestors, close cycles and listen to our own intuition.",
    timing: 'On Samhain day, preferably at dusk, when the veil grows thin.',
  ),
  'sabbat_yule': (
    title: 'Yule Ritual',
    intro:
        'The Winter Solstice brings the longest night of the year. We celebrate the rebirth of the light: from now on, the days grow again.',
    timing: 'On the solstice day, at dusk or in the evening.',
  ),
  'sabbat_imbolc': (
    title: 'Imbolc Ritual',
    intro:
        'Festival of the growing light. The Earth slowly awakens and the first signs of spring appear. Time to purify, cleanse and prepare for new growth.',
    timing: 'On Imbolc day, in the morning or at noon, honoring the growing light.',
  ),
  'sabbat_ostara': (
    title: 'Ostara Ritual',
    intro:
        'Spring Equinox: light and darkness in perfect balance while nature fully awakens. A time for new beginnings and fertile ideas.',
    timing: 'On the equinox day, in the morning.',
  ),
  'sabbat_beltane': (
    title: 'Beltane Ritual',
    intro:
        'The festival of fire and fertility. Life is in full bloom: celebrate love, passion and the joy of being alive.',
    timing: 'On Beltane day, from late afternoon into the night.',
  ),
  'sabbat_litha': (
    title: 'Litha Ritual',
    intro:
        'Summer Solstice: the longest day and the peak of solar power. A moment to celebrate achievements, give thanks and absorb the strength of the Sun.',
    timing: 'On the solstice day, from sunrise to sunset.',
  ),
  'sabbat_lammas': (
    title: 'Lammas Ritual',
    intro:
        'The first harvest. After the abundance of summer, it is time to give thanks, share, and honor the effort behind every achievement.',
    timing: 'On Lammas day, in the afternoon.',
  ),
  'sabbat_mabon': (
    title: 'Mabon Ritual',
    intro:
        "Autumn Equinox: the year's second harvest and second balance. A time for gratitude, taking stock, and releasing what no longer needs to travel with you.",
    timing: 'On the equinox day, at dusk.',
  ),
  'full_moon': (
    title: 'Full Moon Ritual',
    intro:
        'The Moon is at the height of her power, illuminating everything you have been building. It is time to manifest intentions, charge your crystals and tools, and practice divination.',
    timing: 'On the night of the full moon (the energy also holds the night before and after).',
  ),
  'new_moon': (
    title: 'New Moon Ritual',
    intro:
        'The dark sky is a blank page. The new moon is the moment to plant intentions, start projects and reconnect with what you want to attract.',
    timing: 'On the night of the new moon, in a quiet place.',
  ),
  'moon_water': (
    title: 'Moon Water',
    intro:
        'Moon Water stores the energy of the full moon for whenever you need it: in spells, baths, cleansings and even to water your plants.',
    timing:
        'Prepare it on the night of the full moon and collect it before sunrise, so the water does not absorb solar energy.',
  ),
  'sun_water': (
    title: 'Sun Water',
    intro:
        'Sun Water carries vitality, courage and joy. It is the daytime sister of moon water: use it whenever you need a boost of energy and strength.',
    timing:
        'On a sunny day, from early morning to mid-afternoon (3 to 6 hours of sunlight is enough).',
  ),
};

const Map<String, List<RitualStepText>> guidedRitualStepsEn = {
  'sabbat_samhain': [
    (
      title: 'Prepare the space',
      description:
          'Clean the room, light some incense (sage or rosemary) and dim the bright lights. Let the atmosphere become quiet and welcoming.'
    ),
    (
      title: 'Set up the ancestor altar',
      description:
          'Place photos or objects of loved ones who have passed, with a simple offering: a glass of water, bread or a piece of fruit.'
    ),
    (
      title: 'Light the candles',
      description:
          'Light a black candle (to release what stays behind) and an orange one (for the harvest of life). Quietly thank those who came before you.'
    ),
    (
      title: 'Speak to memory',
      description:
          'Say aloud (or write down) one good memory of each person you honor. If you wish, share a silent supper.'
    ),
    (
      title: 'Practice divination',
      description:
          'With the veil thin, draw a tarot card, cast runes or use a pendulum asking: "what should I leave in the year that ends?".'
    ),
    (
      title: 'Close and give thanks',
      description:
          'Put out the candles, thank your ancestors, and return the offering to nature the next day.'
    ),
  ],
  'sabbat_yule': [
    (
      title: 'Decorate with natural elements',
      description:
          'Gather (or set out) pinecones, branches, cinnamon and dried fruit, and arrange them on your altar or table.'
    ),
    (
      title: 'Turn everything off for a moment',
      description:
          'Stay in the dark for a moment, breathing deeply. Honor the longest night of the year and all that rests in order to be reborn.'
    ),
    (
      title: 'Light the returning light',
      description:
          'Light golden, red or white candles one by one, naming what you want to grow along with the light in the coming months.'
    ),
    (
      title: 'Purifying herbal bath',
      description:
          'Prepare a bath with rosemary and cinnamon (from the neck down). Visualize whatever feels heavy washing down the drain.'
    ),
    (
      title: 'Meditate on the cycle',
      description:
          'In front of the candles, meditate for a few minutes on death and rebirth: what is ending in you, and what is being born?'
    ),
    (
      title: 'Share warmth',
      description:
          'Prepare a hot drink (mulled wine or ginger tea) and, if you can, share it with someone dear. Yule is a feast of coziness.'
    ),
  ],
  'sabbat_imbolc': [
    (
      title: 'Do the spring cleaning',
      description:
          'Sweep the house from the back door to the front (or visualize the dust leaving), making room for the new. If you own a ritual besom, this is its moment.'
    ),
    (
      title: 'Purify with smoke or water',
      description:
          'Carry lavender or chamomile incense through the rooms, or sprinkle salted water, asking stagnant energy to dissolve.'
    ),
    (
      title: 'Light the candle of the growing light',
      description:
          'Light a white, yellow or red candle in honor of the returning Sun. If you wish, dedicate it to Brigid, lady of fire and inspiration.'
    ),
    (
      title: 'Plant your seeds',
      description:
          'Plant real seeds (herbs, flowers) or symbolic ones: write on paper what you want to see bloom and keep it next to a small pot.'
    ),
    (
      title: 'Milk and honey bath',
      description:
          'If you can, take a bath with a little milk and honey, asking for softness, nourishment and new beginnings.'
    ),
    (
      title: 'Close with gratitude',
      description:
          'Thank the growing light. Let the candle burn safely to the end (or put it out and relight it over the next days).'
    ),
  ],
  'sabbat_ostara': [
    (
      title: 'Arrange a spring altar',
      description:
          'Use fresh flowers, seeds and light colors. Open the windows and let the air flow.'
    ),
    (
      title: 'Paint or decorate eggs',
      description:
          'Paint eggs (or small stones) with symbols of what you want to bring to life: spirals, suns, runes, hearts.'
    ),
    (
      title: 'Plant flowers and herbs',
      description:
          'Plant in pots or in the garden. Each seedling is an intention: say aloud what each one stands for.'
    ),
    (
      title: 'Balance your energies',
      description:
          'The equinox calls for balance: light one white and one black candle and reflect on what needs balancing (work/rest, giving/receiving).'
    ),
    (
      title: 'Make a prosperity sachet',
      description:
          'In a green or yellow pouch, place basil, mint and a coin. Carry it with you or keep it near the front door.'
    ),
  ],
  'sabbat_beltane': [
    (
      title: 'Build a flower altar',
      description:
          'Fill your altar with red, pink and colorful flowers. Beltane celebrates life in its fullness.'
    ),
    (
      title: 'Light the sacred fire',
      description:
          'Light red candles (or a bonfire, safely). The Beltane fire purifies and vitalizes: hold your hands near the warmth and feel the energy.'
    ),
    (
      title: 'Dance and celebrate',
      description:
          'Play a song that makes you happy and dance, even alone. Let your body celebrate being alive.'
    ),
    (
      title: 'Make offerings to the elementals',
      description:
          'Leave honey, milk or flowers in a corner of the garden or in a pot, thanking the fairies and nature spirits.'
    ),
    (
      title: 'Celebrate love',
      description:
          'Write a love letter — to someone or to yourself. Keep it with a rose quartz until the next sabbat.'
    ),
  ],
  'sabbat_litha': [
    (
      title: 'Greet the Sun',
      description:
          'Watch the sunrise (or sunset). Give thanks aloud for the light, the warmth and everything that has ripened in your life.'
    ),
    (
      title: 'Harvest magical herbs',
      description:
          'Herbs are at the peak of their power: harvest (or buy) chamomile, mint and lavender to dry and use all year.'
    ),
    (
      title: 'Cast a circle of protection',
      description:
          'Walk the outline of your home (or visualize it) scattering salt or rosemary, asking protection for everyone living there.'
    ),
    (
      title: 'Charge your objects in the sun',
      description:
          'Let jewelry, amulets and sun-safe crystals (beware of those that fade) bathe in the light for a few hours.'
    ),
    (
      title: 'Celebrate with the colors of the Sun',
      description:
          'Set a table with fresh fruit and yellow and golden flowers. Eat slowly, with gratitude.'
    ),
  ],
  'sabbat_lammas': [
    (
      title: 'Bake (or buy) bread',
      description:
          'Bread is the symbol of the first harvest. If you can, bake it with your own hands, kneading intentions of plenty into every gesture.'
    ),
    (
      title: 'Give thanks for achievements',
      description:
          'List everything you have harvested this year — even the small harvests. Read it aloud before your altar.'
    ),
    (
      title: 'Make a corn dolly',
      description:
          'With corn husks (or paper), craft a little guardian doll of the harvest. Keep her until the next planting.'
    ),
    (
      title: 'Share the abundance',
      description: 'Set food aside to donate. The harvest grows when it is shared.'
    ),
    (
      title: 'Offer the first slice',
      description:
          'Offer the first piece of bread to the Earth (in a pot or garden), honoring the sacrifice that creates abundance.'
    ),
  ],
  'sabbat_mabon': [
    (
      title: 'Build the gratitude cornucopia',
      description:
          'In a basket or plate, arrange apples, grapes, nuts and pumpkins. With each item, name one thing you are grateful for.'
    ),
    (
      title: 'Take stock of the year',
      description:
          'Write down what worked and what weighed on you. Mabon is balance: look at both sides without judgment.'
    ),
    (
      title: 'Release what stays behind',
      description:
          'Write on paper what you release at this turning point. Burn it safely (or tear it up and discard it), thanking the lesson.'
    ),
    (
      title: 'Preserve the flavors',
      description:
          'Make a jam, a tea blend, or freeze fruit. Preserving food is foresight magic for the winter.'
    ),
    (
      title: 'Light autumn candles',
      description:
          'Light orange or brown candles and meditate on the beauty of letting go — as trees let go of their leaves.'
    ),
  ],
  'full_moon': [
    (
      title: 'Prepare the space under the moonlight',
      description:
          'If possible, stay where the moonlight reaches (window, balcony, yard). Light a white or silver candle.'
    ),
    (
      title: 'Set your Moon Water to brew',
      description:
          'Fill a jar or bottle with water and cap it. Leave it under the moonlight — collect it before dawn. (There is a guided ritual just for this!)'
    ),
    (
      title: 'Charge crystals and tools',
      description:
          'Leave crystals, decks, pendulums and jewelry under the moonbeams to cleanse and recharge their energy.'
    ),
    (
      title: 'Manifest your intentions',
      description:
          'Reread (or recall) the intentions planted at the new moon. Give thanks for what has bloomed and visualize the rest coming true.'
    ),
    (
      title: 'Practice divination',
      description:
          'The full moon heightens intuition: draw tarot or oracle cards, cast the runes or consult the pendulum.'
    ),
    (
      title: 'Make a protection amulet',
      description:
          'Let a necklace, ring or small stone absorb the moonlight and consecrate it as your amulet: "may this moon charge you with protection".'
    ),
    (
      title: 'Close with gratitude',
      description:
          'Thank the Moon, put out the candle and, if you harvested herbs today, hang them to dry — they dehydrate more easily in this phase.'
    ),
  ],
  'new_moon': [
    (
      title: 'Create a quiet space',
      description:
          'Dim the bright lights, light a single candle and take a few deep breaths. The new moon asks for stillness.'
    ),
    (
      title: 'Cleanse the energy',
      description:
          'Burn some incense or visualize a light sweeping the room and your body, carrying away the cycle that has ended.'
    ),
    (
      title: 'Write your intentions',
      description:
          'Write on paper what you want to plant this cycle: be specific and write in the present tense, as if it were already real.'
    ),
    (
      title: 'Plant symbolically',
      description:
          'Fold the paper and place it under a plant pot, inside a small box, or next to a truly planted seed.'
    ),
    (
      title: 'Visualize the growth',
      description:
          'With closed eyes, visualize each intention growing along with the moon until it is full. Feel it as if it had already happened.'
    ),
    (
      title: 'Seal the ritual',
      description:
          'Give thanks, put out the candle and keep the paper. Meet it again at the full moon to celebrate what has already moved.'
    ),
  ],
  'moon_water': [
    (
      title: 'Choose and wash the vessel',
      description:
          'Use a very clean glass jar, bottle or pot. If you like, wash it with salted water and rinse well.'
    ),
    (
      title: 'Fill it with water',
      description:
          'Drinking water if you intend to drink it; regular water if it is only for magical use (baths, cleansings, plants).'
    ),
    (
      title: 'Cap the vessel',
      description:
          'Capping protects the water from dirt and keeps the intention sealed. A capped glass vessel is the traditional way.'
    ),
    (
      title: 'State the intention',
      description:
          'Hold the vessel and say what this water will serve: cleansing, healing, intuition, protection... Water keeps the message.'
    ),
    (
      title: 'Leave it under the moonlight',
      description:
          'Place it where the moonlight reaches (window, balcony, yard) for at least a few hours of the night.'
    ),
    (
      title: 'Collect it before sunrise',
      description:
          'Store the water before dawn so it does not absorb solar energy. Label it with the date and the intention.'
    ),
  ],
  'sun_water': [
    (
      title: 'Pick a bright sunny day',
      description:
          'The brighter the day, the more vitality the water carries. Mornings are ideal: their energy is of beginnings and expansion.'
    ),
    (
      title: 'Prepare the vessel',
      description:
          'Clean, transparent glass is best. Fill it with drinking water if you plan to drink it, or regular water for magical use.'
    ),
    (
      title: 'State the intention',
      description:
          'Hold the jar up to the sun and say what you need: courage, joy, strength, creativity. The Sun is generous with those who ask.'
    ),
    (
      title: 'Leave it in the sun for 3 to 6 hours',
      description:
          'It does not need the whole day: mid-morning to mid-afternoon charges it well. Cap it for protection.'
    ),
    (
      title: 'Collect it before sunset',
      description:
          'Store the water while the sun is still in the sky. Label it with the date and use it over the next few days, while the energy is fresh.'
    ),
  ],
};

const Map<String, List<String>> guidedRitualMaterialsEn = {
  'sabbat_samhain': [
    'Black and orange candles',
    'Photos or objects of loved ones',
    'Sage or rosemary incense',
    'A simple offering (water, bread or fruit)',
    'Tarot, runes or pendulum (optional)',
  ],
  'sabbat_yule': [
    'Golden, red or white candles',
    'Pinecones, branches, cinnamon, dried fruit',
    'Rosemary and cinnamon for the bath',
    'A hot drink to share',
  ],
  'sabbat_imbolc': [
    'A white, yellow or red candle',
    'A besom (ritual or ordinary broom)',
    'Lavender or chamomile incense',
    'Seeds or paper for intentions',
    'Milk and honey (for the bath, optional)',
  ],
  'sabbat_ostara': [
    'Fresh flowers and seeds',
    'Eggs (or small stones) and paint',
    'One white and one black candle',
    'A pouch, basil, mint and a coin',
  ],
  'sabbat_beltane': [
    'Red and colorful flowers',
    'Red candles',
    'Honey, milk or flowers for the offering',
    'Paper and pen for the love letter',
    'Rose quartz (optional)',
  ],
  'sabbat_litha': [
    'Herbs to harvest or dry (chamomile, lavender)',
    'Salt or rosemary for the circle',
    'Crystals and amulets to charge',
    'Fresh fruit and yellow flowers',
  ],
  'sabbat_lammas': [
    'Bread (baked or bought)',
    'Corn husks or paper for the dolly',
    'Paper and pen for the achievements list',
    'Food to donate',
  ],
  'sabbat_mabon': [
    'Apples, grapes, nuts, pumpkin',
    'Paper and pen for taking stock',
    'Orange or brown candles',
    'Jars for preserves or teas',
  ],
  'full_moon': [
    'A white or silver candle',
    'A capped jar or bottle (moon water)',
    'Crystals, jewelry and tools to charge',
    'Tarot, runes or pendulum (optional)',
  ],
  'new_moon': [
    'One candle',
    'Paper and pen',
    'Incense (optional)',
    'A seed or small pot (optional)',
  ],
  'moon_water': [
    'A glass jar, bottle or pot with a lid',
    'Water (drinking water, if you plan to drink it)',
    'A label or ribbon to mark it',
  ],
  'sun_water': [
    'A transparent glass jar or bottle with a lid',
    'Water (drinking water, if you plan to drink it)',
    'A label or ribbon to mark it',
  ],
};

const Map<String, List<String>> guidedRitualUsesEn = {
  'moon_water': [
    'Drink it to absorb lunar energy (if the water is drinkable)',
    'Use it in spells and potions instead of regular water',
    'Add it to your bath for cleansing and intuition',
    'Water your plants to strengthen them',
    'Cleanse crystals and magical tools',
    'Sprinkle it around rooms to renew the energy',
  ],
  'sun_water': [
    'Drink it in the morning for vitality (if the water is drinkable)',
    'Use it in spells for energy, courage and success',
    'Add it to your bath before important challenges',
    'Sprinkle it in your work or study space',
    'Water sun-loving plants',
  ],
};

const Map<String, List<String>> guidedRitualCrystalsEn = {
  'full_moon': ['Selenite', 'Moonstone', 'Clear quartz', 'Amethyst'],
  'new_moon': ['Obsidian', 'Black tourmaline', 'Labradorite', 'Onyx'],
  'moon_water': ['Selenite', 'Moonstone', 'Clear quartz'],
  'sun_water': ['Citrine', "Tiger's eye", 'Amber', 'Carnelian'],
};

const Map<String, List<String>> guidedRitualHerbsEn = {
  'full_moon': ['Mugwort', 'Jasmine', 'Lavender', 'Chamomile'],
  'new_moon': ['Sage', 'Rosemary', 'Mint'],
  'moon_water': ['Jasmine', 'Mugwort', 'Lavender'],
  'sun_water': ['Rosemary', 'Chamomile', 'Calendula', 'Sunflower (petals)'],
};
