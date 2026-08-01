import 'sabbat_model.dart';

/// Sabbat texts — English content. Sabbat names (Samhain, Yule...) are
/// invariant proper nouns.
/// Paridade verificada em test/content_models_parity_test.dart.
const Map<SabbatType, String> sabbatDescriptionsEn = {
  SabbatType.samhain: 'The Witches\' New Year. The veil between worlds is thin. Honor your ancestors and loved ones. Start of autumn/winter, a time of turning inward',
  SabbatType.yule: 'Winter Solstice. The longest night of the year. Rebirth of the light. In Brazil it coincides with the June festivals that keep the sacred-fire tradition',
  SabbatType.imbolc: 'Festival of the growing light. The Earth awakens with the first signs of spring. A time for cleansing, purification, and preparing new growth',
  SabbatType.ostara: 'Spring Equinox. Perfect balance between light and darkness. Nature fully awakens. A time of new beginnings',
  SabbatType.beltane: 'Festival of fire and fertility. A celebration of life in its fullness. It coincides with All Souls\' Day in Brazil, but energetically it is about celebrating life and love',
  SabbatType.litha: 'Summer Solstice. The longest day, the peak of solar power. In Brazil it coincides with year-end festivities. A moment of celebration and gratitude',
  SabbatType.lammas: 'First harvest. After the abundant summer, it is time to give thanks and share. We honor the sacrifice that abundance requires',
  SabbatType.mabon: 'Autumn Equinox. Second harvest and second balance of the year. Preparing for autumn. A time of gratitude and equilibrium',
};

const Map<SabbatType, String> sabbatSouthDatesEn = {
  SabbatType.samhain: 'May 1',
  SabbatType.yule: 'June 21',
  SabbatType.imbolc: 'August 1',
  SabbatType.ostara: 'September 21',
  SabbatType.beltane: 'October 31',
  SabbatType.litha: 'December 21',
  SabbatType.lammas: 'February 2',
  SabbatType.mabon: 'March 20',
};

const Map<SabbatType, String> sabbatNorthDatesEn = {
  SabbatType.samhain: 'October 31',
  SabbatType.yule: 'December 21',
  SabbatType.imbolc: 'February 1',
  SabbatType.ostara: 'March 21',
  SabbatType.beltane: 'May 1',
  SabbatType.litha: 'June 21',
  SabbatType.lammas: 'August 1',
  SabbatType.mabon: 'September 21',
};

const Map<SabbatType, List<String>> sabbatCrystalsEn = {
  SabbatType.samhain: ['Obsidian', 'Onyx', 'Black tourmaline', 'Amethyst'],
  SabbatType.yule: ['Clear quartz', 'Citrine', 'Garnet', 'Ruby'],
  SabbatType.imbolc: ['Amethyst', 'Rose quartz', 'Selenite', 'Moonstone'],
  SabbatType.ostara: ['Rose quartz', 'Aventurine', 'Aquamarine', 'Jasper'],
  SabbatType.beltane: ['Rose quartz', 'Emerald', 'Malachite', 'Carnelian'],
  SabbatType.litha: ['Citrine', 'Tiger\'s eye', 'Clear quartz', 'Amber'],
  SabbatType.lammas: ['Citrine', 'Carnelian', 'Agate', 'Peridot'],
  SabbatType.mabon: ['Amber', 'Topaz', 'Citrine', 'Agate'],
};

const Map<SabbatType, List<String>> sabbatHerbsEn = {
  SabbatType.samhain: ['Mugwort', 'Rosemary', 'Sage', 'Rose (petals)', 'Mint'],
  SabbatType.yule: ['Rosemary', 'Cinnamon', 'Ginger', 'Pine', 'Bay laurel'],
  SabbatType.imbolc: ['Lavender', 'Chamomile', 'Angelica', 'Basil'],
  SabbatType.ostara: ['Rose', 'Lavender', 'Mint', 'Basil'],
  SabbatType.beltane: ['Rose', 'Lavender', 'Mint', 'Basil'],
  SabbatType.litha: ['Chamomile', 'Mint', 'Rose', 'Lavender'],
  SabbatType.lammas: ['Basil', 'Chamomile', 'Rosemary'],
  SabbatType.mabon: ['Sage', 'Rosemary', 'Chamomile'],
};

const Map<SabbatType, List<String>> sabbatColorsEn = {
  SabbatType.samhain: ['Black', 'Orange', 'Dark purple', 'Dark gold'],
  SabbatType.yule: ['Red', 'Green', 'Gold', 'White'],
  SabbatType.imbolc: ['White', 'Light pink', 'Light yellow', 'Light green'],
  SabbatType.ostara: ['Green', 'Yellow', 'Pink', 'Lilac'],
  SabbatType.beltane: ['Red', 'Vibrant green', 'Gold', 'Pink'],
  SabbatType.litha: ['Yellow', 'Orange', 'Gold', 'Red'],
  SabbatType.lammas: ['Gold', 'Brown', 'Orange', 'Dark green'],
  SabbatType.mabon: ['Orange', 'Red', 'Brown', 'Dark gold'],
};

const Map<SabbatType, List<String>> sabbatFoodsEn = {
  SabbatType.samhain: ['Pumpkin', 'Apples', 'Homemade bread', 'Soups', 'Chestnuts', 'Pomegranate'],
  SabbatType.yule: ['Mulled wine', 'Gingerbread', 'Dried fruit', 'Corn', 'Orange'],
  SabbatType.imbolc: ['Milk and dairy', 'Seeded bread', 'Honey', 'Teas'],
  SabbatType.ostara: ['Eggs', 'Green salads', 'Herb bread', 'Honey', 'Seeds'],
  SabbatType.beltane: ['Strawberries', 'Red berries', 'Wine', 'Honey cakes'],
  SabbatType.litha: ['Fresh fruit', 'Salads', 'Juices', 'Sunflower (seeds)'],
  SabbatType.lammas: ['Bread', 'Corn', 'Beer', 'Seasonal fruit', 'Grains'],
  SabbatType.mabon: ['Apples', 'Grapes', 'Wine', 'Pumpkins', 'Nuts', 'Mushrooms'],
};

const Map<SabbatType, List<String>> sabbatRitualsEn = {
  SabbatType.samhain: ['Create an ancestor altar with photos and offerings', 'Hold a silent supper honoring those who passed', 'Practice divination (tarot, runes, pendulum)', 'Light black and orange candles'],
  SabbatType.yule: ['Decorate your home with natural elements', 'Light candles to call the light back', 'Take a purifying herbal bath', 'Meditate on the cycle of death and rebirth'],
  SabbatType.imbolc: ['Clean and purify your home', 'Light white or yellow candles', 'Plant seeds (literal or symbolic)', 'Do a ritual bath with milk and honey'],
  SabbatType.ostara: ['Paint eggs with magical symbols', 'Plant flowers and herbs', 'Do a ritual of balance and harmony', 'Make prosperity sachets'],
  SabbatType.beltane: ['Light a bonfire or red candles', 'Dance and celebrate life', 'Make offerings to the fae and elementals', 'Create a flower altar'],
  SabbatType.litha: ['Watch the sunrise or sunset', 'Harvest magical herbs (at their peak)', 'Cast a circle of protection around your home', 'Celebrate with yellow/golden fruits and flowers'],
  SabbatType.lammas: ['Bake bread as an offering', 'Give thanks for the year\'s achievements', 'Make corn dollies', 'Donate food to those in need'],
  SabbatType.mabon: ['Create a gratitude cornucopia', 'Do a ritual of balance', 'Preserve food (jams, teas)', 'Meditate on what needs to be released'],
};
