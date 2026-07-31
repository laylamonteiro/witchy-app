import '../repositories/spell_repository.dart';
import 'spell_localizer.dart';

/// English overlays for the 65 preloaded spells.
///
/// Keys are computed with the SAME Portuguese seed names from
/// `spells_data.dart`, so they always match the `preloaded_*` slug ids
/// stored in SQLite. Only display text is translated here — identity and
/// structure live exclusively in the PT seed.
final Map<String, SpellContentOverlay> spellOverlaysEn = {
  // ============================================
  // LOVE AND ROMANCE
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Rosa para Atrair Amor'):
      const SpellContentOverlay(
    name: 'Pink Candle to Attract Love',
    purpose: 'Attract romantic love',
    ingredients: [
      '1 pink candle',
      'Rose or rosehip oil',
      'Dried rose petals',
      'Rose quartz',
    ],
    steps: '''1. Cleanse your space with incense or herb smoke
2. Anoint the candle with oil, from the center out to the ends
3. Roll the candle in the rose petals
4. Place the rose quartz beside the candle
5. Light the candle while visualizing love coming to you
6. Say: "True love, come to me, with respect and reciprocity"
7. Let the candle burn all the way down
8. Carry the rose quartz with you''',
    observations:
        'Best done on a Friday (the day of Venus). Keep your heart open to new possibilities.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Rosas para Amor'):
      const SpellContentOverlay(
    name: 'Rose Bath for Love',
    purpose: 'Attract love and open the heart',
    ingredients: [
      'Rose petals (white, red or pink)',
      'Honey',
      'Cinnamon stick',
      'Warm water',
    ],
    steps: '''1. Draw a warm bath
2. Add rose petals, 1 spoonful of honey and cinnamon
3. Step into the water and relax
4. Visualize yourself radiating love and being loved
5. Say: "I open my heart to true love"
6. Immerse yourself 3 times
7. Let your skin dry naturally''',
    observations:
        'Can be done under the full or waxing moon. Wonderful for opening the heart after heartbreak.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Sache de Amor'):
      const SpellContentOverlay(
    name: 'Love Sachet',
    purpose: 'Carry love energy with you',
    ingredients: [
      'Small pink or red pouch',
      'Rose petals',
      'Lavender',
      'Small rose quartz',
      'Cinnamon',
      'Paper and pen',
    ],
    steps: '''1. Write on the paper the qualities you seek in a love
2. Fold the paper toward you (drawing it in)
3. Place it in the pouch with the herbs and the crystal
4. Hold the sachet in your hands and visualize love arriving
5. Say: "This love is mine, for the good of all and the harm of none"
6. Carry it in your bag or keep it near your bed
7. Recharge it under the full moon''',
    observations: 'Replace the herbs every 3 months or whenever you feel the need.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Feitiço do Espelho do Amor'):
      const SpellContentOverlay(
    name: 'Love Mirror Spell',
    purpose: 'Reflect love back to you',
    ingredients: [
      'Small mirror',
      'Pink candle',
      'Rose essential oil',
      'A photo of yourself',
    ],
    steps: '''1. Under the full moon, cleanse the mirror
2. Anoint the candle with rose oil
3. Place your photo in front of the mirror
4. Light the candle
5. Look into the mirror and say: "I am worthy of love, I deserve love, I attract love"
6. Let the candle burn down
7. Keep the mirror in a special place''',
    observations: 'This spell works on self-love and attraction at the same time.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Mel para Adoçar Relacionamento'):
      const SpellContentOverlay(
    name: 'Honey to Sweeten a Relationship',
    purpose: 'Sweeten an existing relationship',
    ingredients: [
      'Jar of honey',
      'Paper and a red pen',
      'Ground cinnamon',
      '2 small red candles',
    ],
    steps: '''1. Write your name and the person\'s name on the paper
2. Place the paper at the bottom of a bowl
3. Cover it with honey and sprinkle cinnamon on top
4. Place the candles on either side
5. Light them and say: "May our relationship be as sweet as this honey"
6. Let them burn down
7. Bury the remains in a garden''',
    observations:
        'Only for relationships that already exist. It does not work against free will.',
  ),

  // ============================================
  // SELF-LOVE
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Ritual do Espelho'):
      const SpellContentOverlay(
    name: 'Mirror Ritual',
    purpose: 'Strengthen self-love',
    ingredients: [
      'Mirror',
      'Pink candle',
      'Rose quartz',
    ],
    steps: '''1. Light the pink candle
2. Hold the rose quartz
3. Look at yourself in the mirror
4. Speak positive affirmations about yourself
5. "I love myself", "I am enough", "I deserve happiness"
6. Do this for 5-10 minutes
7. Repeat daily for one week''',
    observations:
        'It may feel strange at first, but with persistence it is transformative.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Amor Próprio'):
      const SpellContentOverlay(
    name: 'Self-Love Bath',
    purpose: 'Nurture and love yourself',
    ingredients: [
      'Pink Himalayan salt',
      'Rose petals',
      'Lavender',
      'Honey',
      'Orange essential oil',
    ],
    steps: '''1. Draw a warm bath
2. Add the pink salt, petals, lavender, honey and oil
3. Step into the water
4. Place your hands over your heart
5. Breathe and visualize pink light wrapping around you
6. Say: "I love and accept myself completely"
7. Relax for 20 minutes
8. Let your skin dry naturally''',
    observations: 'Do this whenever you need to reconnect with yourself.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Frasco de Amor Próprio'):
      const SpellContentOverlay(
    name: 'Self-Love Jar',
    purpose: 'Store self-love energy',
    ingredients: [
      'Glass jar with a lid',
      'Pink salt',
      'Rose petals',
      'Small rose quartz',
      'Cinnamon',
      'Paper and a pink pen',
    ],
    steps: '''1. Write down qualities you love about yourself
2. Place the paper in the jar
3. Add the salt, petals, quartz and cinnamon
4. Hold the jar and infuse it with love
5. Say: "I am love, I am light, I am enough"
6. Close it and keep it somewhere visible
7. Hold it whenever you need strength''',
    observations:
        'Add new slips of paper with qualities whenever you discover more about yourself.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Lista de Gratidão'):
      const SpellContentOverlay(
    name: 'Gratitude List',
    purpose: 'Cultivate self-love through gratitude',
    ingredients: [
      'A beautiful notebook',
      'A pen you love',
      'Pink or gold candle',
    ],
    steps: '''1. Light the candle
2. Open the notebook
3. List 10 things you like about yourself
4. List 10 things your body does for you
5. List 10 of your achievements (small or great)
6. Read them out loud
7. Thank yourself
8. Repeat weekly''',
    observations: 'Gratitude transforms the way we see ourselves.',
  ),

  // ============================================
  // PROTECTION
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Círculo de Sal'):
      const SpellContentOverlay(
    name: 'Salt Circle',
    purpose: 'Basic protection for a space',
    ingredients: [
      'Coarse or sea salt',
    ],
    steps: '''1. Walk the perimeter of the space
2. Sprinkle the salt while visualizing a barrier of light
3. Say: "This space is protected, only love and light may enter"
4. Repeat in the corners of the room
5. Renew monthly or whenever you feel the need''',
    observations:
        'The simplest and most powerful protection there is. Works for a home, bedroom or altar.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Sache de Proteção'):
      const SpellContentOverlay(
    name: 'Protection Sachet',
    purpose: 'Portable personal protection',
    ingredients: [
      'Small black or red pouch',
      'Rosemary',
      'Rue (handle with care)',
      'Coarse salt',
      'Black tourmaline or obsidian',
      'Garlic clove',
    ],
    steps: '''1. Place all the ingredients in the pouch
2. Hold it between your hands
3. Visualize a protective shield around you
4. Say: "Protection with me always, no harm shall reach me"
5. Carry it in your bag or backpack
6. Renew it at each new moon''',
    observations: 'Keep away from children and pets (rue is toxic).',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Proteção'):
      const SpellContentOverlay(
    name: 'Protection Bath',
    purpose: 'Cleanse and shield your personal energy',
    ingredients: [
      'Coarse salt',
      'Rosemary',
      'Rue',
      'Guinea hen weed (anamu)',
      'Water',
    ],
    steps: '''1. Boil the herbs in water for 10 minutes
2. Strain and let it cool
3. After your regular shower, pour it from the neck down
4. Visualize negative energies washing away
5. Say: "I am cleansed and protected"
6. Do not towel off — let your skin dry naturally''',
    observations:
        'Do it after heavy situations, or weekly for maintenance.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Garrafa de Bruxa'):
      const SpellContentOverlay(
    name: 'Witch\'s Bottle',
    purpose: 'Permanent protection for the home',
    ingredients: [
      'Glass jar with a lid',
      'Nails, pins, needles',
      'Coarse salt',
      'Black pepper',
      'Garlic',
      'Rosemary',
      'Your urine (traditional) or vinegar',
    ],
    steps: '''1. Place the sharp objects in the jar
2. Add the salt, pepper, garlic and rosemary
3. Add liquid until the jar is full
4. Seal it tightly and shake
5. Say: "This home is protected"
6. Bury it at the entrance of the home or hide it near the door
7. Never open it''',
    observations: 'A very powerful traditional protection. Lasts for years.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vassoura de Proteção'):
      const SpellContentOverlay(
    name: 'Protection Broom',
    purpose: 'Sweep away negative energies',
    ingredients: [
      'A broom (an ordinary one is fine)',
      'Fresh rosemary',
      'Coarse salt',
    ],
    steps: '''1. Tie rosemary to the broom handle
2. Scatter salt over the floor
3. Sweep from the front door inward
4. Sweep each room counterclockwise
5. Say: "I sweep all negativity out of this home"
6. Gather the salt and discard it far from the house
7. Keep the broom behind the door''',
    observations: 'Do this after heavy visits or arguments at home.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Pentagrama de Proteção'):
      const SpellContentOverlay(
    name: 'Protection Pentagram',
    purpose: 'Personal energetic protection',
    ingredients: [
      'Your index finger or an athame (ritual knife)',
      'Visualization',
    ],
    steps: '''1. Standing, take 3 deep breaths
2. With your index finger, draw a glowing pentagram in the air before you
3. Start at the top, go down to the lower left, up to the right, across to the left, down to the right, back to the top
4. Visualize it shining blue or white
5. Say: "I am protected by this sacred symbol"
6. Draw one in each direction (north, south, east, west)
7. Feel yourself wrapped in protection''',
    observations:
        'Can be done mentally, anywhere, whenever you feel the need.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Proteção com Espelho'):
      const SpellContentOverlay(
    name: 'Mirror Protection',
    purpose: 'Reflect negative energies back',
    ingredients: [
      'Small mirror',
      'Black candle',
      'Coarse salt',
      'Rosemary',
    ],
    steps: '''1. Cleanse the mirror with salt water
2. Place the mirror facing outward in a window or doorway
3. Light the black candle beside it
4. Surround it with salt and rosemary
5. Say: "May all negativity be reflected back to its source, transformed into light"
6. Let the candle burn down''',
    observations:
        'The mirror must always face outward, never into the home.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Óleo de Proteção'):
      const SpellContentOverlay(
    name: 'Protection Oil',
    purpose: 'Protective anointing',
    ingredients: [
      'Carrier oil (almond or jojoba)',
      'Rosemary',
      'Clove',
      'Cinnamon',
      'Black pepper',
      'Dark glass bottle',
    ],
    steps: '''1. Place the herbs in the bottle
2. Cover them with oil
3. Shake while visualizing protection
4. Say: "This oil protects me from all harm"
5. Leave it on the windowsill under the waning moon for 3 nights
6. Strain and use it to anoint candles, doors, windows, or yourself''',
    observations: 'Long-lasting. Keep in a cool, dark place.',
  ),

  // ============================================
  // PROSPERITY
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Folha de Louro dos Desejos'):
      const SpellContentOverlay(
    name: 'Bay Leaf Wishes',
    purpose: 'Manifest prosperity',
    ingredients: [
      'Dried bay leaves',
      'Pen or a pointed stick',
      'Fireproof container',
    ],
    steps: '''1. Write what you wish to manifest on the bay leaf
2. It can be an amount, an opportunity, or simply "prosperity"
3. Hold the leaf and visualize your wish fulfilled
4. Feel the gratitude of having already received it
5. Carefully burn the leaf
6. Say: "My prosperity grows every day"
7. Let the wind carry the ashes, or cast them into running water''',
    observations:
        'Can be done whenever you feel the need. Trust the timing of the universe.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Manjericão'):
      const SpellContentOverlay(
    name: 'Basil Bath',
    purpose: 'Attract prosperity and open paths',
    ingredients: [
      'Fresh or dried basil',
      'Cinnamon',
      'Honey',
      'Water',
    ],
    steps: '''1. Boil the basil and cinnamon in water
2. Let it cool and add honey
3. After your regular shower, pour it from the neck down
4. Visualize paths opening and money flowing in
5. Say: "Prosperity flows to me with ease"
6. Let your skin dry naturally''',
    observations: 'Excellent before interviews or important meetings.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vela Verde da Abundância'):
      const SpellContentOverlay(
    name: 'Green Candle of Abundance',
    purpose: 'Attract money and abundance',
    ingredients: [
      'Green candle',
      'Cinnamon oil, or cooking oil with cinnamon',
      'Basil',
      'A coin',
    ],
    steps: '''1. Anoint the candle with oil, from the center out to the ends
2. Roll it in dried basil
3. Place the coin under the candle
4. Light it while visualizing abundance flowing to you
5. Say: "Money comes to me in abundance, with ease and joy"
6. Let it burn all the way down
7. Carry the coin in your wallet''',
    observations:
        'Best on a Thursday (the day of Jupiter). Repeat whenever you feel the need.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Frasco da Prosperidade'):
      const SpellContentOverlay(
    name: 'Prosperity Jar',
    purpose: 'Attract and keep prosperity',
    ingredients: [
      'Glass jar with a lid',
      'Coins',
      'Rice',
      'Cinnamon',
      'Basil',
      'Citrine or pyrite',
      'Green paper',
    ],
    steps: '''1. Write your financial goal on the paper
2. Place it at the bottom of the jar
3. Add layers: coins, rice, herbs, crystal
4. Fill it to the top
5. Hold the jar and visualize abundance
6. Say: "My prosperity grows steadily"
7. Keep it near where you store your money
8. Add coins whenever money comes in''',
    observations:
        'Never open it or take anything out. It is a permanent prosperity magnet.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Carteira Magnetizada'):
      const SpellContentOverlay(
    name: 'Magnetized Wallet',
    purpose: 'Draw money into your wallet',
    ingredients: [
      'Your empty wallet',
      'Basil',
      'Cinnamon',
      'A banknote',
    ],
    steps: '''1. Clean out your wallet
2. Place a pinch of basil and cinnamon inside
3. Add the banknote
4. Hold the wallet and visualize it always full
5. Say: "Money comes in and multiplies, there is always enough and more"
6. Never leave the wallet completely empty
7. Always keep at least one note inside''',
    observations:
        'Renew the herbs at each new moon. The note must never be spent.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Ritual da Chuva de Moedas'):
      const SpellContentOverlay(
    name: 'Rain of Coins Ritual',
    purpose: 'Multiply money',
    ingredients: [
      'Several coins',
      'Bowl of water',
      'Gold or yellow candle',
    ],
    steps: '''1. Under the full moon, set the bowl in the moonlight
2. Light the candle beside it
3. Hold the coins in your hands
4. Visualize your money multiplying
5. Drop the coins into the water one by one
6. For each coin say: "One becomes two, two become four..."
7. Let the water absorb the lunar energy
8. The next morning, use that water to water your plants''',
    observations:
        'Prosperity will "grow" like the plants. The coins may be given away.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Sigilo de Prosperidade'):
      const SpellContentOverlay(
    name: 'Prosperity Sigil',
    purpose: 'Manifest abundance through symbols',
    ingredients: [
      'Green or gold paper',
      'Gold or green pen',
      'Green candle',
    ],
    steps: '''1. Write your intention: "I am prosperous and abundant"
2. Remove the repeated letters
3. Create a unique symbol from the remaining letters
4. Focus on the sigil and visualize prosperity
5. Light the candle
6. Burn the paper with the sigil, or keep it in your wallet
7. Forget about it (let the universe do its work)''',
    observations:
        'A chaos magic technique. The less you think about it afterward, the better it works.',
  ),

  // ============================================
  // HEALING
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Cura'):
      const SpellContentOverlay(
    name: 'Healing Bath',
    purpose: 'Physical and energetic healing',
    ingredients: [
      'Coarse salt or Himalayan salt',
      'Rosemary',
      'Mint',
      'Eucalyptus',
      'Chamomile',
    ],
    steps: '''1. Boil the herbs in water
2. Strain and let it cool
3. Add it to a warm bath with the salt
4. Step into the water and relax
5. Visualize healing green light surrounding you
6. Say: "My body heals, my energy renews itself"
7. Stay for at least 15 minutes
8. Let your skin dry naturally''',
    observations:
        'Not a substitute for medical treatment. It complements healing processes.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vela de Cura'):
      const SpellContentOverlay(
    name: 'Healing Candle',
    purpose: 'Send healing energy',
    ingredients: [
      'Blue or white candle',
      'Eucalyptus or mint oil',
      'Clear quartz or amethyst',
      'A photo of the person (or paper with their name)',
    ],
    steps: '''1. Cleanse the crystal
2. Anoint the candle with the oil
3. Place the photo/paper under the candle
4. Set the crystal beside it
5. Light the candle
6. Visualize healing light surrounding the person
7. Say: "May [name] be healed for their highest good"
8. Let the candle burn all the way down''',
    observations:
        'Always ask permission before working magic for others. Respect free will.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Chá Mágico de Cura'):
      const SpellContentOverlay(
    name: 'Magical Healing Tea',
    purpose: 'A potion for inner healing',
    ingredients: [
      'Chamomile tea',
      'Mint',
      'Ginger',
      'Honey',
      'Lemon',
    ],
    steps: '''1. Brew the tea with the intention of healing
2. Stir clockwise as you make it
3. Add honey and lemon
4. Hold the cup in your hands
5. Visualize golden light in the tea
6. Say: "This potion heals me, cell by cell"
7. Drink slowly, with full attention
8. Feel the healing moving through your body''',
    observations: 'May be done daily during a healing process.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Grade de Cristais Curativa'):
      const SpellContentOverlay(
    name: 'Healing Crystal Grid',
    purpose: 'Amplify healing through crystals',
    ingredients: [
      '1 large clear quartz (center)',
      '4 amethysts (corners)',
      '4 rose quartz (sides)',
      'A photo of yourself, or of the place of pain',
    ],
    steps: '''1. Cleanse all the crystals
2. Place the photo in the center
3. Position the clear quartz on top of the photo
4. Place the amethysts at the 4 corners (a square)
5. Place the rose quartz on the 4 sides (between the amethysts)
6. Visualize light flowing between the crystals
7. Say: "This grid amplifies perfect healing"
8. Leave it set up for 3 days
9. Carry the center crystal with you''',
    observations:
        'A potent amplifier of healing energy. Recharge the crystals after use.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Poppet de Cura'):
      const SpellContentOverlay(
    name: 'Healing Poppet',
    purpose: 'An energetic doll for healing',
    ingredients: [
      'White or green fabric',
      'Needle and thread',
      'Cotton for stuffing',
      'Healing herbs (chamomile, rosemary)',
      'A small healing crystal',
      'Paper with a name/photo',
    ],
    steps: '''1. Cut two pieces of fabric in a human shape
2. Sew them together, leaving an opening
3. Place inside: cotton, herbs, crystal, paper
4. Sew it closed
5. Hold the poppet and visualize healing
6. Say: "This doll represents [name] in perfect health"
7. Keep it in a safe place
8. Unstitch it when the healing is complete''',
    observations:
        'A traditional technique. Treat the poppet with care, as if it were the person.',
  ),

  // ============================================
  // ENERGY CLEANSING
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Defumação com Alecrim'):
      const SpellContentOverlay(
    name: 'Rosemary Smoke Cleansing',
    purpose: 'Cleanse the energy of a space',
    ingredients: [
      'Dried rosemary',
      'Charcoal or a fireproof container',
    ],
    steps: '''1. Light the rosemary (use charcoal if you prefer)
2. Let it smoke well
3. Start at the front door
4. Walk through the whole space counterclockwise
5. Give special attention to corners
6. Say: "All negativity is banished, only light remains"
7. Open the windows to let the energy out
8. Let the rosemary burn out completely''',
    observations:
        'Do this whenever the space feels heavy, or after arguments.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Limpeza com Sálvia Branca'):
      const SpellContentOverlay(
    name: 'White Sage Cleansing',
    purpose: 'Deep purification',
    ingredients: [
      'White sage (smudge stick)',
      'A feather (optional)',
      'Fireproof container',
    ],
    steps: '''1. Open the windows
2. Light the sage
3. Use the feather to direct the smoke
4. Cleanse yourself first (from head to toe)
5. Then cleanse the space (counterclockwise)
6. Say: "With this sacred smoke, I cleanse and purify"
7. Extinguish it by pressing it into sand or earth''',
    observations:
        'Buy from ethical sources. White sage is sacred to Indigenous peoples.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Spray de Limpeza Lunar'):
      const SpellContentOverlay(
    name: 'Lunar Cleansing Spray',
    purpose: 'Quick, practical cleansing',
    ingredients: [
      'Spray bottle',
      'Full moon water',
      'Sea salt',
      'Rosemary',
      'Lavender',
      'Quartz crystal',
    ],
    steps: '''1. On the full moon, set water out in a container under the moon
2. Add a pinch of salt and the herbs
3. Leave the quartz inside
4. In the morning, strain it into the spray bottle
5. To use: spritz the space or yourself
6. Say: "I am cleansed and protected"
7. Recharge the spray at the next full moon''',
    observations: 'Handy for quick cleansings. Keep refrigerated.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Sal nos Cantos'):
      const SpellContentOverlay(
    name: 'Salt in the Corners',
    purpose: 'Cleanse and protect a space',
    ingredients: [
      'Coarse salt',
    ],
    steps: '''1. Place a pinch of salt in every corner of the house
2. Start at the front door and move counterclockwise
3. In each corner say: "This space is cleansed and protected"
4. Leave it for 24 hours
5. Sweep it up and throw the salt away (never reuse it)
6. Wash the floor with water and vinegar''',
    observations: 'A simple and very effective method. Do it monthly.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Descarrego Completo'):
      const SpellContentOverlay(
    name: 'Complete Uncrossing Bath',
    purpose: 'Clear heavy personal energy',
    ingredients: [
      'Coarse salt',
      'Rue',
      'Guinea hen weed (anamu)',
      'Rosemary',
      'Lavender',
      'Water',
    ],
    steps: '''1. Boil all the herbs in water
2. Strain and set aside
3. Take your regular shower as usual
4. Pour the herbal bath from the neck down
5. Visualize everything bad being washed away
6. Say 3 times: "I am cleansed, I am renewed, I am protected"
7. Let your skin dry naturally
8. Put on clean clothes''',
    observations:
        'For after very heavy situations. A potent energetic cleansing.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Limpeza com Som'):
      const SpellContentOverlay(
    name: 'Sound Cleansing',
    purpose: 'Cleanse with sound vibration',
    ingredients: [
      'A bell, singing bowl, or your own clapping hands',
    ],
    steps: '''1. Start at the front door
2. Ring the bell (or clap) in every corner
3. Continue through the whole space
4. The vibration breaks up stagnant energy
5. Visualize the sound dispersing dark mist
6. Say: "With this sound, I cleanse and renew this space"
7. Finish back at the front door''',
    observations:
        'A smoke-free method, great for anyone with respiratory sensitivity.',
  ),

  // ============================================
  // BANISHING
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Cebola de Banimento'):
      const SpellContentOverlay(
    name: 'Banishing Onion',
    purpose: 'Absorb and banish negativity',
    ingredients: [
      'Large red onion',
      'Pins or nails',
      'Coarse salt',
    ],
    steps: '''1. Cut the onion in half
2. Write the name of the person/situation to banish on paper
3. Place the paper between the halves
4. Pin them back together
5. Bury it somewhere far away or discard it in a distant bin
6. Say: "As this onion rots, so [situation/person] leaves my life"
7. Wash your hands well
8. Do not look back''',
    observations:
        'Only for toxic situations/people. Use with responsibility.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vela Preta de Banimento'):
      const SpellContentOverlay(
    name: 'Black Banishing Candle',
    purpose: 'Banish a person or negative energy',
    ingredients: [
      'Black candle',
      'Paper and pen',
      'Garlic powder',
      'Black pepper',
      'Salt',
    ],
    steps: '''1. Write what you wish to banish on the paper
2. Place the paper under the candle
3. Circle it with salt, garlic and pepper
4. Light the candle
5. Visualize the situation moving away from you
6. Say: "I release you, you are banished from my life"
7. Let it burn all the way down
8. Bury or discard the remains far from home''',
    observations:
        'Always finish with a personal cleansing and protection.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Corda de Banimento'):
      const SpellContentOverlay(
    name: 'Banishing Cord',
    purpose: 'Cut energetic ties',
    ingredients: [
      'Black cord or thick thread',
      'Scissors or a knife',
      'Black candle',
    ],
    steps: '''1. Light the candle
2. Hold the cord
3. Visualize the connection you want to cut
4. Say: "This tie no longer serves me"
5. Cut the cord with decision
6. Burn the pieces in the candle flame
7. Say: "I am free"
8. Cast the ashes to the wind or into running water''',
    observations:
        'Powerful for ending relationships or energetic attachments.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Freezer Spell (Congelamento)'):
      const SpellContentOverlay(
    name: 'Freezer Spell',
    purpose: 'Stop gossip or harmful behavior',
    ingredients: [
      'Paper',
      'Container with water',
      'Freezer',
    ],
    steps: '''1. Write the person\'s name and the behavior to be stopped
2. Fold the paper away from you (pushing it away)
3. Place it in the container with water
4. Say: "Your actions against me are frozen"
5. Put it in the freezer
6. Keep it frozen until the situation resolves
7. Once resolved, thaw it and throw it away''',
    observations:
        'It causes no harm — it only immobilizes negative action. Ethical for self-defense.',
  ),

  // ============================================
  // LUCK
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Sache da Sorte'):
      const SpellContentOverlay(
    name: 'Lucky Sachet',
    purpose: 'Attract good luck in general',
    ingredients: [
      'Small green or gold pouch',
      'A clover (if you can find one)',
      'Cinnamon',
      'Basil',
      'Star anise',
      'A lucky coin',
      'Citrine or aventurine',
    ],
    steps: '''1. Place all the ingredients in the pouch
2. Hold it between your hands
3. Visualize opportunities appearing
4. Say: "Luck goes with me wherever I go"
5. Carry it with you
6. Touch the pouch whenever you need luck
7. Recharge it under the full moon''',
    observations: 'The more you believe, the better it works.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vela Laranja da Oportunidade'):
      const SpellContentOverlay(
    name: 'Orange Candle of Opportunity',
    purpose: 'Open doors to opportunity',
    ingredients: [
      'Orange candle',
      'Orange essential oil',
      'Cinnamon',
      'Aventurine',
    ],
    steps: '''1. Anoint the candle with orange oil
2. Roll it in cinnamon
3. Place the aventurine beside it
4. Light the candle
5. Visualize doors opening
6. Say: "Opportunities flow to me with ease"
7. Let it burn for 30 minutes
8. Snuff it out and repeat for 3 days in a row''',
    observations:
        'Great before important events or life changes.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Mão da Sorte'):
      const SpellContentOverlay(
    name: 'Lucky Hand',
    purpose: 'Luck in games and bets',
    ingredients: [
      'Ground cinnamon',
      'Salt',
      'Your dominant hand',
    ],
    steps: '''1. Mix the cinnamon and salt
2. Rub it into the palm of your dominant hand
3. Visualize yourself winning
4. Say: "Luck is in my hands"
5. Blow the mixture into the wind (away from you)
6. Do not wash your hands right away
7. Use that hand to play/bet''',
    observations: 'Magic does not guarantee a win. Play responsibly.',
  ),

  // ============================================
  // CREATIVITY
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Amarela da Inspiração'):
      const SpellContentOverlay(
    name: 'Yellow Candle of Inspiration',
    purpose: 'Unblock creativity',
    ingredients: [
      'Yellow or orange candle',
      'Orange or lemon essential oil',
      'Cinnamon',
      'Carnelian or citrine',
    ],
    steps: '''1. Anoint the candle with the oil
2. Roll it in cinnamon
3. Place the crystal beside it
4. Light the candle in your creative space
5. Say: "Creativity flows through me"
6. Work on your project with the candle burning
7. Repeat whenever you need to''',
    observations:
        'The flame represents the creative spark. Keep it burning while you work.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Chá da Inspiração'):
      const SpellContentOverlay(
    name: 'Inspiration Tea',
    purpose: 'Spark creative ideas',
    ingredients: [
      'Green or white tea',
      'Mint',
      'Ginger',
      'Lemon',
      'Honey',
    ],
    steps: '''1. Brew the tea with the intention of awakening creativity
2. Add the ingredients
3. Stir clockwise
4. Say: "This tea awakens my creative genius"
5. Drink while visualizing ideas flowing
6. Sit down to create right afterward''',
    observations:
        'Works as a ritual for entering a creative state.',
  ),

  // ============================================
  // COMMUNICATION
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Mel na Língua'):
      const SpellContentOverlay(
    name: 'Honey on the Tongue',
    purpose: 'Sweeten your words and communication',
    ingredients: [
      'Honey',
      'Your finger',
    ],
    steps: '''1. Put a little honey on your finger
2. Lightly touch your tongue with the honey
3. Visualize your words being well received
4. Say in your mind: "My words are sweet and well received"
5. Use before important conversations
6. Stay mindful of what you say''',
    observations:
        'Before interviews, presentations or difficult conversations.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vela Azul da Comunicação Clara'):
      const SpellContentOverlay(
    name: 'Blue Candle of Clear Communication',
    purpose: 'Improve expression and be understood',
    ingredients: [
      'Light blue candle',
      'Lavender or mint oil',
      'Sodalite or lapis lazuli',
      'Paper and a blue pen',
    ],
    steps: '''1. Write your intention for clear communication
2. Place the paper under the candle
3. Anoint the candle with the oil
4. Set the crystal beside it
5. Light the candle
6. Say: "I express myself with clarity, I am heard and understood"
7. Let it burn while you visualize communication flowing
8. Carry the crystal when you need to communicate''',
    observations:
        'Works with the throat chakra. Great for anyone who struggles to express themselves.',
  ),

  // ============================================
  // DREAMS
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Travesseiro dos Sonhos'):
      const SpellContentOverlay(
    name: 'Dream Pillow',
    purpose: 'Prophetic and lucid dreams',
    ingredients: [
      'Small fabric pouch',
      'Lavender',
      'Mugwort',
      'Chamomile',
      'Small amethyst',
    ],
    steps: '''1. On the full moon, place the herbs and crystal in the pouch
2. Hold it and say: "May my dreams be clear and memorable"
3. Place it under or inside your pillow
4. Before sleep, say: "I remember my dreams clearly"
5. Keep a dream journal by the bed
6. Write in it as soon as you wake''',
    observations:
        'Mugwort is potent for dreams. It may bring intense dreaming.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Água Lunar dos Sonhos'):
      const SpellContentOverlay(
    name: 'Lunar Dream Water',
    purpose: 'Clarify dreams and intuition',
    ingredients: [
      'Water',
      'Glass cup or jar',
      'Amethyst or moonstone',
    ],
    steps: '''1. On the full moon, pour water into the cup
2. Add the crystal
3. Leave it under the moonlight overnight
4. In the morning, remove the crystal
5. Drink a sip before bed
6. Say: "This moon water clarifies my dreams"
7. Write down your dreams when you wake''',
    observations:
        'Moon water deepens the connection with the unconscious.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Óleo de Unção para Sonhos'):
      const SpellContentOverlay(
    name: 'Dream Anointing Oil',
    purpose: 'Ease the way into lucid dreams',
    ingredients: [
      'Carrier oil (jojoba or almond)',
      'Lavender essential oil',
      'Mugwort',
      'Chamomile',
      'Small bottle',
    ],
    steps: '''1. Mix the essential oils with the carrier oil
2. Add pinches of the herbs
3. Leave it out under the full moon
4. Before sleep, anoint your third eye (between the eyebrows)
5. Anoint your wrists as well
6. Say: "I am conscious within my dreams"
7. Sleep with the intention of dreaming lucidly''',
    observations:
        'Practice lucid dreaming techniques along with the oil for better results.',
  ),

  // ============================================
  // ENERGY
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Vermelha de Vitalidade'):
      const SpellContentOverlay(
    name: 'Red Candle of Vitality',
    purpose: 'Boost physical energy',
    ingredients: [
      'Red candle',
      'Cinnamon oil',
      'Ground ginger',
      'Carnelian or red jasper',
    ],
    steps: '''1. Anoint the candle with the oil
2. Roll it in ginger
3. Place the crystal beside it
4. Light the candle
5. Visualize vibrant energy filling you
6. Say: "I am full of vital energy and strength"
7. Let it burn while you do something active
8. Carry the crystal for steady energy''',
    observations:
        'No substitute for needed rest. Use when you need extra energy.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho Energizante'):
      const SpellContentOverlay(
    name: 'Energizing Bath',
    purpose: 'Renew vital energy',
    ingredients: [
      'Rosemary',
      'Mint',
      'Orange peel',
      'Ginger',
      'Sea salt',
    ],
    steps: '''1. Boil the herbs in water
2. Strain and let it cool a little
3. Take your regular shower
4. Pour it from the neck down
5. Visualize golden energy filling you
6. Say: "I am renewed and energized"
7. Let your skin dry naturally
8. Wear vibrant clothes if you can''',
    observations:
        'Best in the morning, to start the day with energy.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Cristal de Energia Pessoal'):
      const SpellContentOverlay(
    name: 'Personal Energy Crystal',
    purpose: 'Charge a crystal with energy',
    ingredients: [
      'Clear quartz or citrine',
      'Sunlight',
    ],
    steps: '''1. Cleanse the crystal
2. Hold it between your hands
3. Visualize golden light entering through your crown
4. Feel the energy flow into your hands
5. Program the crystal: "You store energy and return it to me when I need it"
6. Place it in the sun for 2 hours
7. Carry it with you
8. Hold it whenever you need energy''',
    observations: 'Recharge the crystal in the sun monthly.',
  ),

  // ============================================
  // HOME AND HEARTH
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Proteção e Bênção do Lar'):
      const SpellContentOverlay(
    name: 'Home Blessing and Protection',
    purpose: 'Bless and protect the home',
    ingredients: [
      'Coarse salt',
      'Rosemary',
      'Lavender',
      'Water',
      'White candle',
    ],
    steps: '''1. Boil water with the herbs
2. Add the salt
3. Let it cool and strain
4. Light the white candle
5. Go room by room, spritzing or wiping with a cloth
6. In each room say: "This home is blessed, protected and full of love"
7. Finish at the front door
8. Let the candle burn all the way down''',
    observations:
        'Do it when moving in, or monthly to renew the energy.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vassoura de Bruxa para Lar'):
      const SpellContentOverlay(
    name: 'Witch\'s Broom for the Home',
    purpose: 'Cleanse and renew the home\'s energy',
    ingredients: [
      'A broom',
      'Fresh rosemary',
      'Purple or black ribbon',
      'Salt',
    ],
    steps: '''1. Tie rosemary to the broom handle with the ribbon
2. Scatter salt over the floor
3. Start at the front door
4. Sweep each room with an "outward" sweeping motion
5. Say: "I sweep away all negativity, I bring renewal"
6. Gather the salt and discard it far from home
7. Keep the broom behind the door or in a cupboard''',
    observations:
        'Weekly, or after heavy energy in the home.',
  ),

  // ============================================
  // WISDOM AND STUDY
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Roxa da Sabedoria'):
      const SpellContentOverlay(
    name: 'Purple Candle of Wisdom',
    purpose: 'Deepen understanding and wisdom',
    ingredients: [
      'Purple candle',
      'Rosemary oil',
      'Sage',
      'Amethyst or fluorite',
      'A book or study material',
    ],
    steps: '''1. Anoint the candle with rosemary oil
2. Place the amethyst beside the candle
3. Set the book/material nearby
4. Light the candle
5. Say: "May wisdom flow through me, may I understand and retain knowledge"
6. Study with the candle burning
7. Let it burn for at least 30 minutes''',
    observations:
        'Purple is the color of wisdom and the third eye. Use before exams or while studying.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Chá da Concentração'):
      const SpellContentOverlay(
    name: 'Concentration Tea',
    purpose: 'Sharpen focus for studying',
    ingredients: [
      'Green tea',
      'Mint',
      'Rosemary',
      'Honey',
      'Lemon',
    ],
    steps: '''1. Brew the tea with the intention of concentration
2. Add the mint and rosemary
3. Stir clockwise 3 times
4. Say: "This tea clears my mind and sharpens my focus"
5. Add honey and lemon
6. Drink slowly before studying
7. Feel the mental clarity arriving''',
    observations:
        'Mint and rosemary are herbs of mental clarity. Brew it fresh for best results.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Sachê do Estudante'):
      const SpellContentOverlay(
    name: 'Student\'s Sachet',
    purpose: 'Help retain knowledge',
    ingredients: [
      'Small yellow or purple pouch',
      'Rosemary (memory)',
      'Sage (wisdom)',
      'Mint (clarity)',
      'Fluorite or sodalite',
      'Paper with your study goal',
    ],
    steps: '''1. Write on the paper what you wish to learn
2. Place it in the pouch with the herbs and crystal
3. Hold it and visualize yourself absorbing knowledge
4. Say: "My mind is open, I absorb and retain knowledge with ease"
5. Keep it in your backpack or on your study desk
6. Smell the sachet before studying or taking exams
7. Recharge it at each new moon''',
    observations:
        'Rosemary has been used for memory since ancient Greece.',
  ),

  // ============================================
  // COURAGE
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Vermelha da Coragem'):
      const SpellContentOverlay(
    name: 'Red Candle of Courage',
    purpose: 'Summon courage and inner strength',
    ingredients: [
      'Red candle',
      'Cinnamon oil',
      'Black pepper',
      'Red jasper or carnelian',
    ],
    steps: '''1. Anoint the candle with cinnamon oil
2. Sprinkle pepper around its base
3. Place the crystal beside it
4. Light the candle
5. Look into the flame and say: "I am brave, I am strong, I face my fears"
6. Visualize yourself facing what you fear — and succeeding
7. Let it burn all the way down
8. Carry the crystal when you need courage''',
    observations:
        'Red is the color of Mars, planet of courage and action. Use before challenging situations.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Amuleto do Guerreiro'):
      const SpellContentOverlay(
    name: 'Warrior\'s Amulet',
    purpose: 'Carry courage with you',
    ingredients: [
      'Small red or orange pouch',
      'Black pepper',
      'Garlic powder',
      'Ginger',
      'Red jasper or hematite',
      'Red paper',
    ],
    steps: '''1. Write on the paper: "I am strong and brave"
2. Place all the ingredients in the pouch
3. Hold it with both hands against your chest
4. Take 3 deep breaths
5. Say: "I carry the strength of a warrior, nothing intimidates me"
6. Visualize yourself as an invincible warrior
7. Carry it in your pocket in difficult moments''',
    observations:
        'Touch the amulet when you feel fear or insecurity, to remember your strength.',
  ),

  // ============================================
  // FRIENDSHIP
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Laranja da Amizade'):
      const SpellContentOverlay(
    name: 'Orange Candle of Friendship',
    purpose: 'Attract new friendships',
    ingredients: [
      'Orange or yellow candle',
      'Sweet orange oil',
      'Cinnamon',
      'Citrine or rose quartz',
    ],
    steps: '''1. Anoint the candle with orange oil
2. Roll it in cinnamon
3. Place the crystal beside it
4. Light the candle
5. Say: "I attract true friends, kindred souls, bonds of joy and loyalty"
6. Visualize yourself surrounded by good friendships
7. Let it burn down
8. Go out and socialize (magic needs opportunity!)''',
    observations:
        'Orange is the color of joy and sociability. Magic opens paths, but you must walk them.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Nó de Amizade'):
      const SpellContentOverlay(
    name: 'Friendship Knot',
    purpose: 'Strengthen an existing friendship',
    ingredients: [
      '2 ribbons or cords (in colors you and your friend love)',
      'Pink or orange candle',
    ],
    steps: '''1. Light the candle
2. Hold the two ribbons
3. Visualize you and your friend happy together
4. Tie 3 knots in the intertwined ribbons
5. At each knot say: "Our friendship is strong, true and lasting"
6. Keep the tied ribbons, or gift one to your friend
7. Let the candle burn down''',
    observations:
        'Knot magic is ancient and powerful. Undo the knots only if the friendship ends.',
  ),

  // ============================================
  // WORK
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Verde do Sucesso Profissional'):
      const SpellContentOverlay(
    name: 'Green Candle of Professional Success',
    purpose: 'Attract success at work',
    ingredients: [
      'Green or gold candle',
      'Basil or cinnamon oil',
      'Basil',
      'Citrine or pyrite',
      'A business card, or paper with your professional goal',
    ],
    steps: '''1. Write your professional goal on the paper
2. Place it under the candle
3. Anoint the candle with the oil
4. Roll it in basil
5. Place the crystal beside it
6. Light the candle
7. Say: "Success comes to me, I am recognized and valued in my work"
8. Let it burn all the way down
9. Carry the crystal to interviews/work''',
    observations:
        'Thursday (the day of Jupiter) is ideal for work and career spells.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Óleo de Unção para Entrevista'):
      const SpellContentOverlay(
    name: 'Interview Anointing Oil',
    purpose: 'Success in job interviews',
    ingredients: [
      'Carrier oil (jojoba or almond)',
      'Basil essential oil',
      'Orange essential oil',
      'Ground cinnamon',
      'Small bottle',
    ],
    steps: '''1. Mix the essential oils with the carrier oil
2. Add a pinch of cinnamon
3. Hold the bottle and visualize success in the interview
4. Say: "This oil brings me confidence, clarity and success"
5. Before the interview, anoint your wrists and behind your ears
6. Say in your mind: "I am the right person for this job"
7. Go in confident!''',
    observations:
        'Also use for presentations or important meetings. Confidence is magic!',
  ),

  // ============================================
  // DIVINATION
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Água da Lua para Vidência'):
      const SpellContentOverlay(
    name: 'Moon Water for Second Sight',
    purpose: 'Amplify divinatory abilities',
    ingredients: [
      'Glass or silver bowl or goblet',
      'Pure water',
      'Amethyst or moonstone',
      'Lavender',
    ],
    steps: '''1. On the full moon, pour water into the bowl
2. Add the crystal and a pinch of lavender
3. Leave it under the moonlight all night
4. In the morning, remove the crystal and strain out the lavender
5. Use this water to cleanse divination tools (tarot, runes, pendulum)
6. Or drink a sip before doing readings
7. Say: "My vision is clear, my intuition is strong"''',
    observations:
        'Water charged under the full moon carries strong psychic energy.',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Ritual de Abertura do Terceiro Olho'):
      const SpellContentOverlay(
    name: 'Third Eye Opening Ritual',
    purpose: 'Develop intuition and clairvoyance',
    ingredients: [
      'Purple or indigo candle',
      'Amethyst or lapis lazuli',
      'Lavender or mugwort incense',
      'Lavender oil',
    ],
    steps: '''1. Light the candle and the incense
2. Sit comfortably
3. Place the crystal on your third eye (between the eyebrows)
4. Anoint your third eye with a drop of oil
5. Close your eyes and breathe deeply
6. Visualize indigo light spinning at your third eye
7. Say: "My third eye is open, I see beyond the veil"
8. Meditate for 10-15 minutes
9. Write down any visions or sensations''',
    observations:
        'Do it for 7 nights in a row for best results. Keep a journal of your experiences.',
  ),
};
