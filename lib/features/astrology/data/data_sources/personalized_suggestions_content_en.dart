import '../models/enums.dart';
import 'personalized_suggestions_content.dart';

/// Personalized suggestions page content — English.
const PersonalizedSuggestionsContent personalizedSuggestionsContentEn =
    PersonalizedSuggestionsContent(
  ui: {
    'premiumUnlockSubtitle': 'Unlock full personalized suggestions',
    'chartNeededTitle': 'Birth Chart Required',
    'chartNeededBody':
        'To receive personalized suggestions based on the astrological transits, you need to create your birth chart first.',
    'fillChartButton': 'Fill In Birth Chart',
    'today': 'Today',
    'infoBanner':
        'Suggestions based on the planetary transits and your birth chart',
    'mercuryRetrogradeActive': 'Mercury Retrograde Active!',
    'retrogradePlanets': 'Retrograde Planets',
    'retrogradeCountOne': '{count} planet in retrograde motion',
    'retrogradeCountMany': '{count} planets in retrograde motion',
    'retrogradeInSign': '{title} in {sign}',
    'effectsLabel': 'Effects:',
    'tipsLabel': 'Tips:',
    'suggestedPracticesLabel': 'Suggested Practices:',
    'relevantAspectsLabel': 'Relevant Aspects:',
    'noSuggestionsTitle': 'No Special Suggestions',
    'noSuggestionsBody':
        'There are no significant transits affecting your natal chart on this day. Keep up your regular practices.',
    'errorLoadChart':
        'Error loading birth chart. Please create your birth chart first.',
    'errorGenerate': 'Error generating suggestions. Please try again later.',
  },
  retrogradeInfo: {
    Planet.mercury: RetrogradePlanetInfo(
      title: 'Mercury Retrograde',
      effects: 'Confused communication, travel delays, technology issues',
      tips: 'Review contracts, avoid starting new projects, back up your data',
    ),
    Planet.venus: RetrogradePlanetInfo(
      title: 'Venus Retrograde',
      effects: 'Relationship issues, impulsive spending, self-esteem',
      tips:
          'Reassess relationships, avoid cosmetic surgery, reflect on your values',
    ),
    Planet.mars: RetrogradePlanetInfo(
      title: 'Mars Retrograde',
      effects: 'Low energy, frustrations, repressed aggression',
      tips: 'Avoid conflicts, do not start legal battles, practice patience',
    ),
    Planet.jupiter: RetrogradePlanetInfo(
      title: 'Jupiter Retrograde',
      effects: 'Inner expansion, reassessment of beliefs and philosophies',
      tips: 'A time for spiritual introspection, review long-term goals',
    ),
    Planet.saturn: RetrogradePlanetInfo(
      title: 'Saturn Retrograde',
      effects: 'Past responsibilities return, karma being worked through',
      tips: 'Resolve pending matters, work on inner discipline',
    ),
    Planet.uranus: RetrogradePlanetInfo(
      title: 'Uranus Retrograde',
      effects: 'Inner changes before outer ones, personal revelations',
      tips: 'Free yourself from old patterns, accept gradual change',
    ),
    Planet.neptune: RetrogradePlanetInfo(
      title: 'Neptune Retrograde',
      effects: 'Veils lift, illusions revealed, sharpened intuition',
      tips: 'Meditate, work with dreams, beware of escapism',
    ),
    Planet.pluto: RetrogradePlanetInfo(
      title: 'Pluto Retrograde',
      effects: 'Deep transformation, confronting shadows',
      tips: 'Shadow work, let go of what no longer serves you',
    ),
  },
);
