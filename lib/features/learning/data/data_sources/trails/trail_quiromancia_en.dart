import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// 'quiromancia' trail — English content.
/// Parity with _pt/_es is verified in test/trails_parity_test.dart.
const LearningTrail quiromanciaTrailEn = LearningTrail(
  id: 'quiromancia',
  emoji: '🖐️',
  title: 'Palmistry',
  subtitle: 'The technical reading of hands',
  description:
      'The art of reading hands with method: shape, lines, mounts, fingers, and marks. Nine lessons that teach you to truly observe — and not merely to imagine.',
  lessons: [
    TrailLesson(
      id: 'qm_01',
      recordKind: LessonRecordKind.note,
      title: 'The hand as a map',
      teaching:
          'Palmistry (from the Greek cheir, hand, and manteia, divination) starts from a simple idea: the hand records the person. Shape, texture, lines, and reliefs form a map of the temperament and tendencies of the one who carries them. Reading hands is not predicting a fixed destiny — it is observing natural inclinations and how they change over the course of a life, because the lines really do transform with the years.\n\nTwo technical distinctions open any reading. The first is between the dominant hand and the passive (or birth) hand: the passive one — the one you use less — shows inherited potential, the "raw material"; the dominant one shows what you have done with it, the present and the direction. Comparing the two is half the reading. The second distinction separates chirognomy (the study of the shape of the hand and fingers, more tied to character) from palmistry proper (the study of the lines and marks).\n\nBefore looking at any line, a serious reading begins with the whole: which hand is dominant, what the skin texture is like, the color, the flexibility, the temperature, whether the hand is tense or relaxed. A firm, warm hand speaks differently from a soft, cold one. Keep the honest palmist\'s golden rule: describe what you see, never invent what is not there, and treat every mark as a tendency to understand, never as a sentence.',
      practice:
          'In this practice you will get to know your own hands as a reader. First, identify your dominant hand and your passive hand. Then observe them side by side under good light and note the general differences: which has more lines, which has firmer skin, which looks more "busy". Finally, record your first impressions. The goal is to train the eye for the whole before diving into the lines.',
      pageTitle: 'The Map of My Hands',
      pagePurpose: 'Record the initial overall reading of both hands',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Both of your hands', 'Good lighting'],
      pagePrompts: [
        'My dominant hand and my passive hand:',
        'General differences I notice between them:',
        'Texture, temperature, and flexibility I observed:',
        'My first impressions of what my hands tell:',
      ],
    ),
    TrailLesson(
      id: 'qm_02',
      recordKind: LessonRecordKind.note,
      title: 'Hand shape: the four elements',
      teaching:
          'Classical chirognomy sorts hands into four elemental types, crossing the shape of the palm with the length of the fingers. It is the first technical datum of any reading, because it frames everything that comes after. The rule: compare the length of the palm (from the wrist to the base of the fingers) with the length of the middle fingers.\n\nEarth hand — square palm and short fingers. Practical, stable people, connected to the body and the concrete; firm hands, few lines, thicker skin. Air hand — square palm and long fingers. Agile mind, communication, curiosity; many fine, clear lines. Fire hand — rectangular palm (longer than it is wide) and short fingers. Energy, action, enthusiasm, impatience; strong, vivid lines. Water hand — long, narrow palm and long fingers. Sensitivity, imagination, emotion; soft skin and a web of delicate lines.\n\nIn practice, the shape is rarely "pure" — most hands mix two elements, and it is precisely that combination that individualizes the reading. The beginner\'s common mistake is memorizing labels and forcing the hand to fit into one of them. Do the opposite: measure, compare, and describe the mixture. The hand\'s element gives the emotional and practical background tone; the lines, which we will see next, tell the story over that background.',
      practice:
          'In this practice you will classify the shape of your hand. First, measure (by eye or with a ruler) the palm and fingers of your dominant hand. Then cross square/rectangular palm with short/long fingers and identify the element — or the mixture of two. Finally, see whether the element\'s temperament resonates with you. The goal is to anchor the reading in the shape before looking at the lines.',
      pageTitle: 'The Element of My Hand',
      pagePurpose: 'Classify the hand\'s elemental type and what it reveals',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Your dominant hand', 'Ruler (optional)'],
      pagePrompts: [
        'Shape of my palm (square or rectangular) and fingers (short or long):',
        'My dominant element (Earth, Air, Fire, or Water) — or the mixture:',
        'What that element\'s temperament says about me:',
        'How much this resonates with how I see myself:',
      ],
    ),
    TrailLesson(
      id: 'qm_03',
      recordKind: LessonRecordKind.note,
      title: 'The Life Line',
      teaching:
          'The Life Line is the one born between the thumb and the index finger, curving down around the Mount of Venus (the base of the thumb). It is the most misunderstood line in palmistry: contrary to the popular myth, its length does NOT measure how long someone will live. It speaks of vitality, physical strength, enthusiasm for life, and the great changes of course.\n\nWhat is technically read in it: the curvature — the more open it is, embracing a broad Mount of Venus, the more warmth, vigor, and physical generosity; the straighter and closer to the thumb, the more reserve and caution with energy. Depth and clarity indicate the robustness of vitality. Upward branches usually mark phases of growth and achievement; islands (that eye-shaped figure on the line) suggest periods of divided energy or health to look after; breaks and overlaps point to life changes — moves to another city, new directions, new phases — and not catastrophes.\n\nAn important technical point: the Life Line is read together with the Mount of Venus and the Fate Line, never alone. A "short" line may simply indicate that vitality is sustained by another line. As you practice, resist the dramatic temptation to read illness or endings where there is only a transition. Describe the course, locate the signs, and translate them as chapters of energy — open ones, never closed.',
      practice:
          'In this practice you will map your Life Line. First, find where it begins and follow its curve around the base of the thumb. Then observe: is it open or close to the thumb? Is it deep or faint? Does it have branches, islands, or breaks? Finally, note what each feature suggests about your vitality — without turning any sign into a sentence. The goal is to read the most mythologized line with method and serenity.',
      pageTitle: 'My Life Line',
      pagePurpose: 'Record the technical reading of the Life Line',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Your dominant hand', 'Good light'],
      pagePrompts: [
        'What the course of my Life Line is like (curve, depth):',
        'Branches, islands, or breaks I found — and where:',
        'What it suggests about my vitality and my life turning points:',
        'A myth about this line that I leave behind:',
      ],
    ),
    TrailLesson(
      id: 'qm_04',
      recordKind: LessonRecordKind.note,
      title: 'The Head Line',
      teaching:
          'The Head Line crosses the palm horizontally, more or less through the middle, and speaks of the intellect: how you think, learn, decide, and concentrate. It usually begins near the start of the Life Line, between the thumb and the index finger, and runs toward the opposite edge of the hand. Its reading is one of the most revealing of mental temperament.\n\nThe technical signs: length indicates the breadth of thought — a long line, crossing much of the palm, suggests a detail-oriented, reflective mind; a short one, direct, practical thinking. The slope is decisive: a straight Head Line indicates logical, objective, "down-to-earth" reasoning; one that curves down toward the Mount of the Moon (the base of the palm, on the side opposite the thumb) indicates imagination, creativity, and an associative mind. Depth speaks of focus and memory; islands and chains indicate periods of scattering or worry.\n\nA classic and important detail is how it begins: joined to the Life Line at its start, it suggests caution, attachment to family, and prudence in acting; separate from it from the beginning, it suggests early independence and impulsiveness. When reading, always cross the Head Line with the Heart Line — together, they show the person\'s balance between reason and emotion. Describe the direction, the clarity, and the starting point before any conclusion.',
      practice:
          'In this practice you will read your Head Line. First, locate it in the middle of the palm and follow its path. Then observe: is it straight (logical) or does it descend toward the Moon (imaginative)? Is it long or short? Does it begin joined to or separate from the Life Line? Finally, record what it reveals about your way of thinking and deciding. The goal is to recognize your own mental style in the palm.',
      pageTitle: 'My Head Line',
      pagePurpose: 'Record the reading of the Head Line and the mental style',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Your dominant hand', 'Good light'],
      pagePrompts: [
        'Direction of my Head Line (straight or curved toward the Moon):',
        'Length and clarity — and how it begins (joined to or separate from the Life Line):',
        'What this says about how I think and decide:',
        'Where reason and emotion balance in me:',
      ],
    ),
    TrailLesson(
      id: 'qm_05',
      recordKind: LessonRecordKind.note,
      title: 'The Heart Line',
      teaching:
          'The Heart Line is the highest of the three great lines, running horizontally beneath the fingers. It speaks of the emotional life: how you love, bond, express emotion, and care for relationships. It is read from the edge of the hand (the little-finger side) toward the index and middle fingers.\n\nTechnique looks first at where it ends. A Heart Line that rises and ends under the index finger (Mount of Jupiter) indicates idealism in love, devotion, and high standards; ending under the middle finger (Mount of Saturn), it suggests a more realistic, contained affection, at times more drawn to desire than to romance; ending between the two, a mature balance. A long, curved line expresses emotions with warmth and openness; a short, straight one indicates reserve or difficulty putting feelings into words. Upward branches mark happy relationships and important connections; downward branches, disappointments that taught; chains and islands, periods of emotional instability.\n\nThe common mistake is to look in the Heart Line for the "number of great loves" or exact dates — serious palmistry does not do that. What this line delivers is the emotional style: warm or reserved, idealistic or pragmatic, generous or guarded. Read it together with the Head Line to understand how thought and feeling converse in the person, and always describe the tendency, with respect and without drama.',
      practice:
          'In this practice you will read your Heart Line. First, locate it beneath the fingers and see where it ends (under the index finger, the middle finger, or between them). Then observe whether it is long and curved or short and straight, and look for upward and downward branches. Finally, note what it reveals about your style of loving. The goal is to recognize your emotional signature with gentleness.',
      pageTitle: 'My Heart Line',
      pagePurpose: 'Record the reading of the Heart Line and the emotional style',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Your dominant hand', 'Good light'],
      pagePrompts: [
        'Where my Heart Line ends and what that suggests:',
        'Is it long and curved or short and straight? Branches I found:',
        'What it reveals about how I love and bond:',
        'How my heart and my head converse:',
      ],
    ),
    TrailLesson(
      id: 'qm_06',
      recordKind: LessonRecordKind.note,
      title: 'The Fate Line',
      teaching:
          'The Fate Line (or Line of Saturn) is a vertical line rising from the base of the palm toward the middle finger. Not everyone has it strongly marked — and its absence is not bad luck. It speaks of the sense of direction, of career, of the guiding thread the person feels (or does not feel) in their trajectory, and of the external forces that shape the path.\n\nTechnically, one observes where it starts. Rising from the base of the wrist, it suggests a sense of purpose from early on; rising from the Mount of the Moon, a path strongly influenced by others, by the public, or by favorable chance; rising from the Life Line, a trajectory built by one\'s own effort. A clear, continuous line indicates a stable course; interruptions, changes of career or life direction; a double line, the ability to carry two paths at once. When it is faint or absent, the person usually builds their own course with more freedom, without a pre-laid track — which is a reading, not a verdict.\n\nThe Fate Line is the best example of why palmistry reads tendencies, and not sentences: it changes visibly over a lifetime as choices are made. That is why it is read last among the vertical lines and always in dialogue with the Head Line (the decisions) and the Life Line (the energy). Describe the origin, the continuity, and the turns — and remember that here the map is drawn, in large part, by the person themselves.',
      practice:
          'In this practice you will look for your Fate Line. First, see whether there is a vertical line rising toward the middle finger — and do not worry if it is faint or absent. Then, if it exists, observe where it starts and whether it is continuous or has turns. Finally, note what it suggests about your sense of direction. The goal is to understand the line that changes the most with your choices.',
      pageTitle: 'My Fate Line',
      pagePurpose: 'Record the reading of the Fate Line and the sense of direction',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Your dominant hand', 'Good light'],
      pagePrompts: [
        'Is my Fate Line strong, faint, or absent? Where it starts:',
        'Continuity and turns I observed in it:',
        'What it suggests about my sense of direction and career:',
        'In what way I feel I build my own path:',
      ],
    ),
    TrailLesson(
      id: 'qm_07',
      recordKind: LessonRecordKind.note,
      title: 'The mounts',
      teaching:
          'The mounts are the fleshy pads of the palm, each associated with a celestial body and a set of qualities. Reading the mounts means assessing which are more developed (high, firm, rosy) and which are flatter — because the relief shows where the person\'s energy concentrates. It is the part of palmistry closest to astrology.\n\nThe main ones: the Mount of Venus, at the base of the thumb, speaks of love, sensuality, vitality, and affection for life — full and firm, warmth and generosity; flattened, reserve. The Mount of Jupiter, under the index finger, rules ambition, leadership, and self-confidence. The Mount of Saturn, under the middle finger, speaks of responsibility, discipline, and introspection. The Mount of Apollo (or the Sun), under the ring finger, rules creativity, expression, and radiance. The Mount of Mercury, under the little finger, communication, shrewdness, and business. The Mount of the Moon, at the base of the palm on the side opposite the thumb, rules imagination, intuition, and the world of dreams. And the Mounts of Mars (two of them, an active one between thumb and index finger, a passive one on the opposite side) speak of courage, combativeness, and endurance.\n\nThe technique is comparative: no mount is read alone. You observe which one stands out — that one "wins" and colors the temperament — and how the others balance out. A high Jupiter with a flat Saturn draws one person; the reverse, another. Marks on a mount (a cross, a star, a grid) intensify or disturb its quality, the subject of the next lesson. As you practice, feel gently and compare the reliefs — describe where your energy lives.',
      practice:
          'In this practice you will map your mounts. First, with your hand relaxed and slightly curved, observe and feel the pads under each finger and at the base of the thumb and palm. Then identify which are fuller and firmer and which are flatter. Finally, note which mount stands out and what that says about you. The goal is to locate where your energy concentrates.',
      pageTitle: 'My Mounts',
      pagePurpose: 'Record which mounts stand out and what they reveal',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Your dominant hand', 'Good light'],
      pagePrompts: [
        'My most developed mount (Venus, Jupiter, Saturn, Apollo, Mercury, Moon, or Mars):',
        'Flatter mounts I noticed:',
        'What this balance says about where my energy lives:',
        'How this dialogues with the element of my hand:',
      ],
    ),
    TrailLesson(
      id: 'qm_08',
      recordKind: LessonRecordKind.note,
      title: 'Fingers, thumb, and special marks',
      teaching:
          'Beyond lines and mounts, the palmist reads the fingers, the thumb, and the small marks. The fingers take the names of the same celestial bodies as the mounts they touch: Jupiter (index), Saturn (middle), Apollo (ring), and Mercury (little finger). One assesses the relative length, the straightness or leaning, and the shape of the tips — pointed (idealism, sensitivity), conic (art, intuition), square (order, practicality), or spatulate (energy, restlessness). A long Apollo finger, for example, reinforces creative expression; a slightly crooked Mercury, sharpness with words.\n\nThe thumb is considered by many palmists the most important datum of the hand, because it represents willpower and reason. One looks at its size (a large, firm thumb indicates strong will), the flexibility of the tip (rigid: stubbornness and firm principles; flexible: adaptability, generosity), and the opening angle in relation to the hand (open: a free, generous mind; closed: caution and reserve). The phalanx of will (the tip) and the phalanx of logic (the middle one) should be compared: whichever is longer shows whether the person is driven more by wanting or by reasoning.\n\nFinally, the smaller marks on lines and mounts refine the reading: the island (weakens, divides), the cross (obstacle or turning point), the star (an intense event, brilliance or shock, depending on the place), the grid (blocked or scattered energy), the square (protection, repair), and the triangle (talent). No mark is read in isolation — it modifies the quality of the place where it appears. The good reader describes the mark, the place, and the interaction, always as nuance, never as sealed destiny.',
      practice:
          'In this practice you will read your fingers and thumb. First, compare the length and the tip shape of the four fingers. Then study the thumb: size, flexibility of the tip, and opening angle. Finally, look for a special mark (island, cross, star, grid, square) on some line or mount and note where it is. The goal is to sharpen your eye for the details that individualize the reading.',
      pageTitle: 'My Fingers, Thumb, and Marks',
      pagePurpose: 'Record the reading of the fingers, the thumb, and the marks',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Both of your hands', 'Good light'],
      pagePrompts: [
        'The shape of my fingertips and what they reinforce:',
        'My thumb (size, flexibility, angle) and what it says about my will:',
        'A special mark I found and where it is:',
        'How that mark colors the quality of that place:',
      ],
    ),
    TrailLesson(
      id: 'qm_09',
      recordKind: LessonRecordKind.note,
      tool: LessonTool.palmistry,
      title: 'The complete reading',
      teaching:
          'A complete reading is not the sum of fragments: it is a synthesis. The experienced palmist follows an order that integrates everything you have learned. First the whole — dominant and passive hand, texture, the element of the shape. Then the three great lines in the classic sequence: Life (energy), Head (mind), Heart (affection). Next, the Fate Line (direction). Then the mounts (where the energy lives) and, finally, fingers, thumb, and marks (the nuances). Each layer is read in the light of the previous ones.\n\nThe art lies in crossing the data instead of listing it. An imaginative Head Line on a Water hand, with a high Mount of the Moon, tell the same story by three paths — and that convergence is what gives a reading confidence. Contradictions inform too: a reserved Heart Line on a Fire hand reveals an interesting tension between warmth and protection. Comparing the passive hand with the dominant one shows the movement: what was potential and what the person has developed. The good reader tells a coherent narrative, not an off-the-shelf horoscope.\n\nTwo ethics close the art. First: palmistry reads tendencies, not sentences — the lines change, and naming open paths is truer (and more useful) than nailing down destinies. Second: read with care. Never make health diagnoses, death predictions, or absolute promises; always give the person back the power to choose. Now you have the method. In this final practice, bring it all together in a reading of your own — and, if you wish, use the app\'s Palm Reading to compare your analysis with the Mystic Counselor\'s.',
      practice:
          'In this practice you will do your first complete reading. First, go through the order: the whole → Life, Head, Heart → Fate → mounts → fingers and marks. Then look for convergences (data that repeat) and contrasts (interesting tensions) and write a synthesis in a few sentences. Finally, open the app\'s Palm Reading, photograph your palm, and compare the AI\'s reading with yours. The goal is to integrate the whole method into a coherent narrative of your own.',
      pageTitle: 'My Complete Reading',
      pagePurpose: 'Integrate the whole method into a coherent palm reading',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Both of your hands', 'Good light', 'The app\'s Palm Reading'],
      pagePrompts: [
        'My synthesis of the whole and the three great lines:',
        'Convergences I found (data that repeat):',
        'Interesting contrasts between lines, mounts, and shape:',
        'What the app\'s Palm Reading added to my analysis:',
      ],
    ),
  ],
);
