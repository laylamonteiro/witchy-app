import '../models/enums.dart';
import '../models/zodiac_sign_data.dart';

/// The 12 zodiac signs — English content.
///
/// The `sign` field is invariant across languages; only the texts are
/// translated. Keep the same order/count across the three files
/// (`zodiac_signs_data_pt/en/es.dart`) — parity is verified in
/// `test/astrology_content_parity_test.dart`.
const List<ZodiacSignData> zodiacSignsEn = [
  ZodiacSignData(
    sign: ZodiacSign.aries,
    dateRange: 'March 21 - April 19',
    rulingPlanet: 'Mars',
    keywords: 'Courage, Initiative, Leadership, Pioneering',
    personality:
        'Aries is the first sign of the zodiac, representing the beginning of all things. '
        'Aries people are naturally brave, direct and full of energy. '
        'They have a competitive spirit and love challenges. They are born leaders who prefer '
        'to act quickly rather than plan for a long time. Their honesty can '
        'sometimes seem blunt, but it comes from a genuine place.',
    magicalGifts:
        'Arians have a very strong life force, excellent for action magic '
        'and protection. They have a natural knack for rituals of courage, willpower '
        'and new beginnings. Their inner flame is powerful for banishing and energy cleansing.',
    bestPractices:
        'Candle magic (especially red and orange), protection rituals, '
        'spells for courage and strength, New Moon work for fresh starts, '
        'martial magic and work with the Fire element.',
    crystals: 'Carnelian, Red Jasper, Ruby, Diamond, Hematite',
    herbs: 'Pepper, Ginger, Garlic, Cinnamon, Nettle',
    colors: 'Red, Orange, Gold',
  ),
  ZodiacSignData(
    sign: ZodiacSign.taurus,
    dateRange: 'April 20 - May 20',
    rulingPlanet: 'Venus',
    keywords: 'Stability, Sensuality, Persistence, Abundance',
    personality:
        'Taurus is the sign of fertile earth and abundance. Taurus people value '
        'security, comfort and sensory pleasures. They are extremely loyal, patient '
        'and hard-working. They appreciate the beautiful things in life and have a strong aesthetic sense. '
        'When they commit to something, they see it through with unshakable determination.',
    magicalGifts:
        'Taureans have a special connection with the earth and nature. They excel at '
        'prosperity, fertility and material manifestation magic. They possess a natural '
        'healing touch and an ability to work with plants and crystals.',
    bestPractices:
        'Green witchcraft and herbalism, prosperity and abundance magic, '
        'Full Moon rituals, crystal work, magical gardening, '
        'love and beauty spells, aromatic ritual baths.',
    crystals: 'Rose Quartz, Emerald, Jade, Malachite, Green Tourmaline',
    herbs: 'Rose, Vervain, Thyme, Apple, Mint',
    colors: 'Green, Pink, Earthy tones',
  ),
  ZodiacSignData(
    sign: ZodiacSign.gemini,
    dateRange: 'May 21 - June 20',
    rulingPlanet: 'Mercury',
    keywords: 'Communication, Curiosity, Versatility, Intellect',
    personality:
        'Gemini is the sign of duality and communication. Geminis are curious, '
        'versatile and excellent communicators. They love learning new things and '
        'sharing knowledge. Their quick mind can handle multiple tasks '
        'at once. They are sociable, witty and always have something interesting to say.',
    magicalGifts:
        'Geminis have a natural gift for word magic - enchantments, sigils '
        'and invocations. They excel at divination, especially tarot and bibliomancy. '
        'Their versatility lets them master many forms of magic.',
    bestPractices:
        'Word magic and verbal enchantments, sigil crafting, '
        'divination (tarot, runes, pendulum), communication magic, '
        'work with incense and the Air element, esoteric study.',
    crystals: 'Agate, Citrine, Tiger\'s Eye, Aquamarine, Howlite',
    herbs: 'Lavender, Rosemary, Mint, Fenugreek, Fennel',
    colors: 'Yellow, Gray, Light blue',
  ),
  ZodiacSignData(
    sign: ZodiacSign.cancer,
    dateRange: 'June 21 - July 22',
    rulingPlanet: 'Moon',
    keywords: 'Intuition, Nurturing, Protection, Emotion',
    personality:
        'Cancer is the sign of the Moon, governing emotions and intuition. Cancerians are '
        'deeply intuitive, protective and affectionate. They value family and home '
        'above all else. They have a strong emotional memory and are very loyal to those they love. '
        'Their sensitivity is both their strength and their vulnerability.',
    magicalGifts:
        'Cancerians have a natural connection with the Moon and its cycles. They possess strong '
        'psychic intuition, a gift for emotional magic and a natural ability for '
        'home protection. They excel at water work and lunar magic.',
    bestPractices: 'Lunar magic in all phases, protection of home and family, '
        'water rituals (baths, potions, mirrors), ancestor work, '
        'emotional healing magic, dream divination.',
    crystals: 'Moonstone, Pearl, Selenite, Opal, Milky Quartz',
    herbs: 'Mugwort, Jasmine, Lettuce, Cucumber, Water Lily',
    colors: 'White, Silver, Pale blue',
  ),
  ZodiacSignData(
    sign: ZodiacSign.leo,
    dateRange: 'July 23 - August 22',
    rulingPlanet: 'Sun',
    keywords: 'Creativity, Expression, Generosity, Power',
    personality:
        'Leo is the sign of the Sun, radiating light and warmth. Leos are naturally '
        'charismatic, creative and generous. They love being the center of attention and '
        'have a talent for leadership. They are loyal, protective and big-hearted. '
        'Their presence lights up any room they enter.',
    magicalGifts:
        'Leos carry powerful solar energy. They are masters of success magic, '
        'glamour and manifestation. They have a natural gift for leading group rituals '
        'and channeling life force. Excellent at self-confidence work.',
    bestPractices:
        'Solar magic and midday rituals, work for success and recognition, '
        'magical glamour, golden candle magic, creativity rituals, '
        'self-esteem spells, leading magical circles.',
    crystals: 'Amber, Citrine, Tiger\'s Eye, Pyrite, Topaz',
    herbs: 'Sunflower, Chamomile, Cinnamon, Bay Laurel, Marigold',
    colors: 'Gold, Orange, Bright yellow',
  ),
  ZodiacSignData(
    sign: ZodiacSign.virgo,
    dateRange: 'August 23 - September 22',
    rulingPlanet: 'Mercury',
    keywords: 'Analysis, Service, Perfection, Practicality',
    personality:
        'Virgo is the sign of organization and service. Virgos are analytical, '
        'practical and extremely detail-oriented. They have a strong sense of duty and love helping '
        'others. They are perfectionists by nature and always strive to improve. '
        'Their organized mind is excellent for solving complex problems.',
    magicalGifts:
        'Virgos have a special talent for herbalism and healing magic. '
        'They excel at preparing potions, tinctures and magical remedies. '
        'Their attention to detail makes their rituals precise and effective.',
    bestPractices: 'Herbalism and potion making, healing and health magic, '
        'purification rituals, altar organization, '
        'practical everyday magic, crafting talismans and amulets.',
    crystals: 'Amazonite, Peridot, Jasper, Carnelian, Sapphire',
    herbs: 'Valerian, Lemon Balm, Chamomile, Fennel, Lavender',
    colors: 'Green, Brown, Beige, Navy blue',
  ),
  ZodiacSignData(
    sign: ZodiacSign.libra,
    dateRange: 'September 23 - October 22',
    rulingPlanet: 'Venus',
    keywords: 'Balance, Harmony, Justice, Relationships',
    personality:
        'Libra is the sign of balance and harmony. Librans are diplomatic, '
        'fair and appreciate beauty in all its forms. They value relationships '
        'and seek peace and cooperation. They have a strong aesthetic sense and a natural ability '
        'to see every side of an issue.',
    magicalGifts:
        'Librans are naturally skilled in love and relationship magic. '
        'They have a gift for balancing energies and harmonizing spaces. They excel '
        'at justice work and magical contracts.',
    bestPractices:
        'Love and relationship magic, rituals of balance and harmony, '
        'beauty and glamour spells, justice work, '
        'partnership magic, decorating aesthetic altars.',
    crystals: 'Rose Quartz, Jade, Lapis Lazuli, Opal, Pink Tourmaline',
    herbs: 'Rose, Violet, Thyme, Myrrh, Vervain',
    colors: 'Pink, Light blue, Soft green, Lavender',
  ),
  ZodiacSignData(
    sign: ZodiacSign.scorpio,
    dateRange: 'October 23 - November 21',
    rulingPlanet: 'Pluto (and Mars)',
    keywords: 'Transformation, Intensity, Mystery, Power',
    personality:
        'Scorpio is the sign of deep transformation. Scorpios are intense, '
        'mysterious and extremely perceptive. They can see beyond '
        'appearances and are not afraid to explore the shadows. They are loyal to the death '
        'and possess unmatched willpower.',
    magicalGifts:
        'Scorpios have a natural connection with the occult and mystical death. '
        'They are masters of transformation, banishing and shadow work. '
        'They possess strong psychic intuition and an ability for mediumship.',
    bestPractices:
        'Shadow and deep psyche work, transformation magic, '
        'Samhain rituals and ancestral contact, powerful banishings, '
        'sex magic, work with Pluto, respectful necromancy.',
    crystals: 'Obsidian, Black Tourmaline, Garnet, Labradorite, Malachite',
    herbs: 'Wormwood, Mandrake, Basil, Patchouli, Dragon\'s Blood',
    colors: 'Black, Dark red, Deep purple',
  ),
  ZodiacSignData(
    sign: ZodiacSign.sagittarius,
    dateRange: 'November 22 - December 21',
    rulingPlanet: 'Jupiter',
    keywords: 'Expansion, Philosophy, Adventure, Optimism',
    personality:
        'Sagittarius is the sign of expansion and the search for truth. Sagittarians are '
        'optimistic, adventurous and philosophical. They love to travel (physically and mentally) '
        'and expand their horizons. They are honest, generous and have faith in life. '
        'Their search for meaning leads them to explore many spiritual traditions.',
    magicalGifts:
        'Sagittarians have a connection with higher wisdom and expanded consciousness. '
        'They excel at luck, abundance and astral travel magic. '
        'They easily connect with spirit guides and ascended masters.',
    bestPractices:
        'Luck and expansion magic, Jupiterian prosperity rituals, '
        'astral travel and shamanic journeys, work with ancient philosophies, '
        'spells for study and wisdom, rituals in sacred places.',
    crystals: 'Turquoise, Amethyst, Sodalite, Lapis Lazuli, Blue Topaz',
    herbs: 'Sage, Cedar, Nutmeg, Anise, Dandelion',
    colors: 'Purple, Royal blue, Turquoise',
  ),
  ZodiacSignData(
    sign: ZodiacSign.capricorn,
    dateRange: 'December 22 - January 19',
    rulingPlanet: 'Saturn',
    keywords: 'Discipline, Ambition, Structure, Responsibility',
    personality:
        'Capricorn is the sign of structure and ambition. Capricorns are '
        'disciplined, responsible and extremely determined. They value tradition '
        'and hard work. They may seem serious, but they have a dry sense of humor. '
        'They build their lives with patience, brick by brick.',
    magicalGifts:
        'Capricorns have mastery of long-term manifestation magic. '
        'They excel at structure, protection and ancestor rituals. '
        'Their discipline enables consistent and powerful magical practice.',
    bestPractices: 'Career and material success magic, Saturnian rituals, '
        'work with ancestors and old traditions, protection spells, '
        'commitment and contract magic, Yule rituals.',
    crystals: 'Onyx, Black Tourmaline, Obsidian, Garnet, Jet',
    herbs: 'Comfrey, Cypress, Ivy, Thistle, Valerian Root',
    colors: 'Black, Gray, Dark brown, Moss green',
  ),
  ZodiacSignData(
    sign: ZodiacSign.aquarius,
    dateRange: 'January 20 - February 18',
    rulingPlanet: 'Uranus (and Saturn)',
    keywords: 'Innovation, Humanitarianism, Originality, Freedom',
    personality:
        'Aquarius is the sign of innovation and collective consciousness. Aquarians are '
        'original, independent and humanitarian. They think outside the box and value '
        'freedom above all. They are visionaries who genuinely care '
        'about the well-being of humanity.',
    magicalGifts:
        'Aquarians have a connection with cosmic energies and expanded consciousness. '
        'They excel at group magic and work for the collective good. '
        'They take easily to magical innovation and technomancy.',
    bestPractices:
        'Group magic and witch circles, rituals for humanitarian causes, '
        'work with astrology and birth charts, innovation in magical practices, '
        'freedom and independence spells, technomancy.',
    crystals: 'Amethyst, Aquamarine, Fluorite, Labradorite, Angelite',
    herbs: 'Lavender, Myrrh, Frankincense, Peppermint, Vervain',
    colors: 'Electric blue, Violet, Silver, Turquoise',
  ),
  ZodiacSignData(
    sign: ZodiacSign.pisces,
    dateRange: 'February 19 - March 20',
    rulingPlanet: 'Neptune (and Jupiter)',
    keywords: 'Intuition, Compassion, Mysticism, Dreams',
    personality:
        'Pisces is the sign of transcendence and universal compassion. Pisceans are '
        'extremely intuitive, empathic and creative. They move between the material '
        'and spiritual worlds with ease. They are artists of the soul, able to feel '
        'the emotions of others and of the collective deeply.',
    magicalGifts:
        'Pisceans have the strongest psychic gifts of the zodiac. They are natural '
        'mediums, seers and empathic healers. Their connection with the spirit world '
        'is innate, and they take easily to dream and vision work.',
    bestPractices:
        'Dream work and dream interpretation, mediumship and channeling, '
        'water magic and rituals with water, empathic healing, '
        'astral travel, connecting with spirit beings, art as magic.',
    crystals: 'Amethyst, Aquamarine, Fluorite, Moonstone, Sugilite',
    herbs: 'Jasmine, Lotus, Eucalyptus, Seaweed, Willow',
    colors: 'Navy blue, Purple, Sea green, Silver',
  ),
];
