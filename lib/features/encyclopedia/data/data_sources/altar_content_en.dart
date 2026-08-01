import '../models/altar_content_model.dart';

/// "The Magical Altar" page content — English.
///
/// Emojis and the order/count of the lists are invariant across languages.
/// Keep the same structure in all three files (`altar_content_pt/en/es.dart`)
/// — parity is checked in `test/encyclopedia_content_parity_test.dart`.
const AltarContent altarContentEn = AltarContent(
  pageTitle: 'The Magical Altar',
  introTitle: 'About the Altar',
  introBody:
      'An altar is your personal sacred space - a focal point for your magical practice. '
      'It does not need to be elaborate or expensive; what matters is the intention and respect with which you treat it. '
      'Your altar is an extension of your energy and a portal between the physical and spiritual worlds',
  introHint:
      'Explore the sections below to learn how to set up, cleanse, maintain, and use your altar',
  beginnerTitle: 'Step-by-Step for Beginners',
  beginnerSubtitle: 'Your first encounter with your altar',
  beginnerIntro:
      'Do not worry if you do not have all the "traditional" items. '
      'An altar can begin with a candle and an intention. What matters is that '
      'it is meaningful to YOU. There is no wrong altar when it is made with heart',
  beginnerSteps: [
    AltarNumberedStep(
      'Choose the Spot',
      'A little corner where you will not be disturbed. It can be a small table, a shelf, or even a box you open when it is time to practice',
      'It does not need to be big! A 30x30cm (12x12in) space is already enough',
    ),
    AltarNumberedStep(
      'Cleanse the Space',
      'Clean it physically with a cloth, then pass incense smoke over it or visualize a white light purifying it',
      'Say: "May this space be purified and blessed"',
    ),
    AltarNumberedStep(
      'Add a Candle',
      'The candle is the heart of the altar - it represents fire and divine light. A single white candle is already enough',
      'White candles are universal and can substitute for any color',
    ),
    AltarNumberedStep(
      'Add Meaningful Items',
      'Place what holds meaning for you: a photo of ancestors, a crystal you were given, flowers, a seashell from the beach',
      'Start with 3-5 items and keep adding over time',
    ),
    AltarNumberedStep(
      'Consecrate your Altar',
      'Light the candle, take a deep breath, and say: "I consecrate this altar as my sacred space. May it be a portal of connection"',
      'Use your own words! What matters is the intention',
    ),
  ],
  firstTimesTitle: '🌟 Your first few times at the altar',
  firstTimesItems: [
    '1. Light the candle with intention, watch the flame',
    '2. Take 3 deep breaths to center yourself',
    '3. Give thanks for the day, for life, for something good',
    '4. Set an intention: "Today I ask for/give thanks for..."',
    '5. Stay a few minutes in silence or speak freely',
    '6. Close: "I give thanks for the connection. So mote it be"',
  ],
  speakTitle: '💬 What to say at the altar?',
  speakExamples: [
    AltarSpeech('To open:',
        '"I light this candle as a symbol of my connection with the sacred"'),
    AltarSpeech('To ask:',
        '"I ask for guidance with [situation]. May wisdom light my path"'),
    AltarSpeech('To give thanks:',
        '"I give thanks for [specific blessing]. My heart is full of gratitude"'),
    AltarSpeech('To close:',
        '"I give thanks for the connection. May the magic stay with me. So mote it be"'),
  ],
  speakNote:
      'Remember: there is no wrong formula. The universe understands your intention!',
  faqTitle: '❓ Common Beginner Questions',
  faqs: [
    AltarFaq('Can I have a secret altar?',
        'Yes! Use a box that you open when it is time to practice'),
    AltarFaq('Do I need to visit the altar every day?',
        'There is no rule. Go when you feel called. A routine strengthens the bond, but it is not mandatory'),
    AltarFaq('Can I move things around?',
        'Yes! The altar is alive and should change with you'),
    AltarFaq('What if I forget the words?',
        'Improvise! The divine does not mind imperfect words'),
  ],
  mountTitle: 'How to Set Up your Altar',
  mountSteps: [
    AltarStep(
      '1. Choose the location',
      'Select a quiet space where you can have privacy. '
          'It can be a table, shelf, dresser, or even a corner of your bedroom. '
          'Avoid bathrooms and laundry rooms (energy drain points)',
    ),
    AltarStep(
      '2. Cleanse the space',
      'Clean the surface physically, and energetically with herbal smoke '
          '(rosemary, rue, sage) or by sprinkling salt water',
    ),
    AltarStep(
      '3. Use an altar cloth',
      'Optional, but recommended. Use colors that resonate with you: '
          'black (protection), white (purity), purple (spirituality), green (healing)',
    ),
    AltarStep(
      '4. Represent the 4 elements',
      'Each element brings an essential energy to the altar:\n\n'
          '🌍 Earth (North): Crystals, salt, stones, plants, pentacle\n'
          '💧 Water (West): Chalice with water, seashells, moon water\n'
          '🔥 Fire (South): Candle, cauldron, athame\n'
          '💨 Air (East): Incense, feathers, bells, wand\n\n'
          '💡 Tip: Place each element in its corresponding cardinal direction when possible',
    ),
    AltarStep(
      '5. Add personal items',
      'Images of deities, photos of ancestors, symbols that make sense to you, '
          'magical tools (athame, cauldron, wand), book of shadows',
    ),
  ],
  itemsTitle: 'What to Use on the Altar',
  items: [
    AltarEmojiItem('🕯️', 'Candles',
        'They represent the Fire element and divine light. Use colors that correspond to your intentions'),
    AltarEmojiItem('💎', 'Crystals',
        'They amplify energy and bring specific properties (rose quartz for love, amethyst for spirituality)'),
    AltarEmojiItem('🌿', 'Herbs',
        'Dried or fresh, each herb has unique magical correspondences'),
    AltarEmojiItem('🔮', 'Symbolic objects',
        'Pentacle, lunar symbols, runes, tarot, statuettes of deities'),
    AltarEmojiItem('💧', 'Chalice with water',
        'The Water element; it can be replaced regularly or used in rituals'),
    AltarEmojiItem(
        '🧂', 'Salt', 'Purification and protection; it represents Earth'),
    AltarEmojiItem('📿', 'Incense',
        'The Air element; it clears energy and raises vibrations'),
    AltarEmojiItem(
        '📖', 'Grimoire', 'Your book of shadows or practice journal'),
    AltarEmojiItem('🌙', 'Lunar items',
        'Representations of the moon, moon water, lunar calendar'),
    AltarEmojiItem(
        '🪶', 'Feathers', 'The Air element, connection with the divine'),
  ],
  itemsNote:
      '💡 Remember: there is no mandatory list. Use what resonates with you and your practice',
  avoidTitle: 'What to Avoid on the Altar',
  avoidItems: [
    AltarStep('Items with negative energy',
        'Objects that carry bad memories or uncomfortable feelings'),
    AltarStep('Too many objects',
        'A crowded altar scatters the energy. Keep it organized and intentional'),
    AltarStep('Borrowed items without permission',
        'Every object carries the energy of its owner'),
    AltarStep('Trash or dirt',
        'Keep your altar clean, both physically and energetically'),
    AltarStep('Objects foreign to your practice',
        'Do not place symbols of traditions you do not practice just to follow a trend'),
    AltarStep('Dead plants',
        'Remove dry leaves and dead plants regularly'),
  ],
  safetyNote:
      'SAFETY: Never leave lit candles unattended. Keep flammable materials away from flames',
  purifyTitle: 'How to Cleanse your Altar',
  purifyIntro:
      'Cleansing removes stagnant or negative energies, renewing the sacred space',
  purifyMethods: [
    AltarEmojiItem('🔥', 'Smoke cleansing',
        'Use rosemary, rue, sage, or palo santo. Pass the smoke over the whole altar and its objects with the intention of cleansing'),
    AltarEmojiItem('💧', 'Water and salt',
        'Sprinkle water with coarse salt (or moon water) around the space. Be careful with objects that cannot get wet'),
    AltarEmojiItem('🔔', 'Sound',
        'Use bells, Tibetan singing bowls, or clapping to break up stagnant energy'),
    AltarEmojiItem('🌙', 'Moonlight',
        'Leave objects under the light of the full moon for a deep energetic cleanse'),
    AltarEmojiItem('🧘', 'Visualization',
        'Visualize white or golden light filling the altar and dissolving dense energies'),
  ],
  purifyFrequency:
      '🌙 Recommended frequency: At each new or full moon, or whenever the energy feels heavy',
  maintainTitle: 'How to Maintain your Altar',
  maintainItems: [
    AltarStep('Regular physical cleaning',
        'Dust it, wipe surfaces, organize objects. Ideally during the waning moon'),
    AltarStep('Replace offerings',
        'If you leave offerings (flowers, food, water), replace them before they spoil'),
    AltarStep('Recharge crystals',
        'Cleanse and recharge crystals regularly (moon, sun, earth, smoke)'),
    AltarStep('Update with the seasons',
        'Adapt decorations and seasonal elements (Sabbats, solstices, equinoxes)'),
    AltarStep('Visit daily',
        'Even if briefly. Light a candle, give thanks, meditate. Keep the energy alive'),
    AltarStep('Rearrange when needed',
        'Your altar can evolve with you. Remove what no longer resonates, add the new'),
    AltarStep('Protect it energetically',
        'Renew protections regularly with salt around it, visualizations, or sigils'),
  ],
  usageTitle: 'How to Use your Altar',
  usageItems: [
    AltarStep('Meditation and connection',
        'Sit before the altar to meditate, center yourself, and connect with the divine'),
    AltarStep('Spells and rituals',
        'Use it as a magical workspace. Light candles, prepare potions, consecrate tools'),
    AltarStep('Offerings and thanksgiving',
        'Leave offerings for deities, ancestors, or spirits you honor'),
    AltarStep('Seasonal celebrations',
        'Decorate and celebrate Sabbats, full moons, and equinoxes at the altar'),
    AltarStep('Charging objects',
        'Leave items (talismans, jewelry, crystals) on the altar to charge them with energy'),
    AltarStep('Divination',
        'Practice tarot, runes, pendulum, or other forms of divination at the altar'),
    AltarStep('Daily focal point',
        'Begin or end the day at the altar, setting intentions or reflecting'),
  ],
  routineTitle: '💚 Suggested daily routine:',
  routineBody: '• Morning: Light a candle, set the intention for the day\n'
      '• Afternoon: A moment of gratitude or brief reflection\n'
      '• Night: Give thanks for the day, extinguish the candle with reverence',
  finalTitle: 'Final Thoughts',
  finalBody:
      'Your altar is a personal expression of your spirituality. There is no "right" or "wrong" way - '
      'what matters is that it is meaningful to YOU. '
      '\n\nA simple altar with three candles and a crystal charged with intention is more powerful '
      'than an elaborate altar without emotional connection. '
      '\n\nAllow your altar to grow organically, reflect your changes, and always be a space of peace, '
      'power, and connection with the sacred',
);
