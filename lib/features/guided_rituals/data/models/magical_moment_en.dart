import 'magical_moment_data.dart';

/// Magical Moment content — English.
/// Parity checked in test/guided_rituals_parity_test.dart.

const Map<int, WeekdayText> weekdayTextsEn = {
  DateTime.monday: (
    theme: "the Moon's day — emotions and intuition",
    goodFor: [
      'Emotions',
      'Intuition',
      'Dreams',
      'Reconciliation',
      'Habits and routine',
    ],
    suggestion:
        'A good day for intuition and dream work: write down what you dreamed, meditate and tend to your emotions.',
  ),
  DateTime.tuesday: (
    theme: "Mars' day — courage and strength",
    goodFor: [
      'Courage',
      'Protection',
      'Strength',
      'Energy',
      'Assertiveness',
    ],
    suggestion:
        "Use Mars' energy for courage and protection spells — and to face what you have been putting off.",
  ),
  DateTime.wednesday: (
    theme: "Mercury's day — communication and knowledge",
    goodFor: [
      'Communication',
      'Studies',
      'Travel',
      'Memory',
      'Creativity',
    ],
    suggestion:
        'A perfect day to study, write and settle pending conversations. Communication spells flow better today.',
  ),
  DateTime.thursday: (
    theme: "Jupiter's day — prosperity and expansion",
    goodFor: [
      'Prosperity',
      'Abundance',
      'Career and work',
      'Luck',
      'Optimism',
    ],
    suggestion:
        'Jupiter expands whatever you plant: a great day for prosperity spells, job applications and new projects.',
  ),
  DateTime.friday: (
    theme: "Venus' day — love and beauty",
    goodFor: [
      'Love',
      'Self-love',
      'Beauty',
      'Friendships',
      'Fertility',
    ],
    suggestion:
        'Venus rules the day: love and self-love spells, beauty baths and time with people who do you good.',
  ),
  DateTime.saturday: (
    theme: "Saturn's day — cleansing and protection",
    goodFor: [
      'Banishings',
      'Cleansing',
      'Purification',
      'Protection',
      'Closures',
    ],
    suggestion:
        'Saturn helps to close and cleanse: a good day for banishings, energetic cleaning and setting boundaries.',
  ),
  DateTime.sunday: (
    theme: "the Sun's day — success and vitality",
    goodFor: [
      'Success',
      'Personal power',
      'Health',
      'Vitality',
      'Empowerment',
    ],
    suggestion:
        'The Sun favors shining: success and vitality spells, sun water and activities that recharge you.',
  ),
};

const Map<MagicDayPeriod, DayPeriodText> dayPeriodTextsEn = {
  MagicDayPeriod.sunrise: (
    title: 'Sunrise',
    goodFor: 'New beginnings, fresh energy, purifying, healing, studying, initiative.',
  ),
  MagicDayPeriod.day: (
    title: 'During the day',
    goodFor: 'Expansion, intelligence, leadership, the conscious mind.',
  ),
  MagicDayPeriod.noon: (
    title: 'Midday',
    goodFor: 'Power, health, money, success, strength, protection, opportunity, vitality.',
  ),
  MagicDayPeriod.sunset: (
    title: 'Sunset',
    goodFor: 'Finding the truth, letting go, banishing, breaking bad habits, closures.',
  ),
  MagicDayPeriod.night: (
    title: 'Night',
    goodFor: 'Inventing, self-development, awareness, releasing stress and worries, healing wounds.',
  ),
  MagicDayPeriod.midnight: (
    title: 'Midnight',
    goodFor: 'Banishment, divination, healing, personal improvement.',
  ),
};
