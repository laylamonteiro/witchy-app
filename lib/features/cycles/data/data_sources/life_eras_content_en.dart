import '../../domain/era_ruler.dart';
import '../models/cycle_content.dart';

/// Eras and Phases content — English.
///
/// Keep the SAME ORDER and the SAME COUNT across the three files
/// (`life_eras_content_pt/en/es.dart`) — parity is checked in
/// `test/life_eras_content_parity_test.dart`. Only prose changes between
/// languages; `regente` and the tag count are invariant.
const List<EraContent> erasEn = [
  EraContent(
    regente: EraRegente.cauda,
    titulo: 'A time to let go and look far',
    tags: ['release', 'silence', 'searching'],
    corpo:
        'The Tail rules a time of loosening your grip. Things you were holding tight begin '
            'to slip away on their own — ties, plans, versions of yourself that already did '
            'what they came to do. It can feel like loss, but it is altar-cleaning: only '
            'what is truly yours stays. It is also a hungry time, when what used to be '
            'enough starts to feel small',
    sombra:
        'The risk is mistaking release for giving up. You may find yourself unmoored, '
            'wanting nothing, sure you have lost your way. That sense of standing outside '
            'the world can harden into isolation if you let it',
    convite:
        'Do not force big decisions now — this time asks questions, it does not answer '
            'them. Keep whatever surfaces in your dream journal, because that is where the '
            'Tail tends to speak. A simple altar, with few things on it, works better than '
            'a crowded one',
  ),
  EraContent(
    regente: EraRegente.venus,
    titulo: 'A time for beauty and pleasure',
    tags: ['love', 'pleasure', 'harmony'],
    corpo:
        'Venus opens the longest stretch of the cycle, and she opens it gently. Affection '
            'gains weight: what begins here tends to last, and what already exists asks for '
            'care and beauty. It is good for money that comes from what you enjoy doing, '
            'for making your home lovely, for treating your body with tenderness instead of '
            'demands',
    sombra:
        'Twenty years of sweetness can also settle into comfort. You may get so used to '
            'ease that any friction becomes a reason to leave. Watch for saying yes just to '
            'keep the peace, and for spending on pleasure past what fits',
    convite:
        'Say what you want, out loud, to the person who needs to hear it. Make something '
            'with your hands for no reason but the pleasure of it. Work with roses, copper '
            'and anything fragrant — Venus answers beauty offered on purpose',
  ),
  EraContent(
    regente: EraRegente.sol,
    titulo: 'A time to be seen',
    tags: ['expression', 'courage', 'recognition'],
    corpo:
        'Six short, warm years. The Sun lights up what you do, and people start to notice. '
            'This is the time to claim your own name: to lead, to sign, to step onto '
            'whatever stage is yours. Doors open because of who you are rather than who you '
            'know, and your word carries further than it used to',
    sombra:
        'Strong light also blinds. You may want to be seen at any cost, to stretch the '
            'story until it fits the admiration. And wounded pride stings more in this '
            'period than in any other',
    convite:
        'Pick one place to shine and go all the way there — this time is short and does '
            'not stretch across five. Gold, sunflower and midday light are your allies. Do '
            'at least one important thing with your name on it',
  ),
  EraContent(
    regente: EraRegente.lua,
    titulo: 'A time to feel everything',
    tags: ['emotion', 'care', 'roots'],
    corpo:
        'The Moon rules ten thin-skinned years. You feel more, and deeper: what others '
            'barely register arrives whole in you. Home, family and the people who are your '
            'harbour move to the centre. It is also a time of sharp intuition, when the '
            'body knows before the mind does',
    sombra:
        'Feeling everything is tiring. Mood becomes a tide and you can end up governed by '
            'it, swallowing hurt instead of naming it, or caring for everyone but yourself. '
            'Poor sleep and clinging to the past are the signs you went past the mark',
    convite:
        'Track the moon phases in your journal and notice what repeats — that is the map '
            'of your own tides. Silver, jasmine and water on your head will settle you. And '
            'ask to be held: in this time, asking is not weakness, it is technique',
  ),
  EraContent(
    regente: EraRegente.marte,
    titulo: 'A time to act and defend',
    tags: ['courage', 'action', 'boundaries'],
    corpo:
        'Mars lights the fuse. Seven years of raw energy on tap, asking to be spent on '
            'something. It is the best stretch of the cycle for starting from nothing, '
            'training your body, fighting for what matters and finally saying no. Courage '
            'arrives before certainty — and it works anyway',
    sombra:
        'Energy without a destination turns into friction. Short fuse, pointless arguments, '
            'accidents from rushing, decisions made in anger and paid for later. If nothing '
            'is being built, Mars will find something to tear down',
    convite:
        'Give your body what it is asking for: movement, sweat, effort at a set hour. Pick '
            'one fight worth having and let the rest go by. Iron, nettle and a red candle '
            'lit before anything hard gets decided',
  ),
  EraContent(
    regente: EraRegente.serpente,
    titulo: 'A time of turning inside out',
    tags: ['rupture', 'desire', 'reinvention'],
    corpo:
        'The Serpent brings eighteen years in which life stops following the rules you '
            'know. Things happen at the wrong moment, in the wrong way, and work out '
            'regardless. You may catch yourself doing what you swore you never would — '
            'moving far away, changing your name or your world. Someone else walks out the '
            'other side',
    sombra:
        'This is the season of mirages. What glitters may not be gold, and the hunger for '
            'more can carry you far from what actually matters. Haste, shortcuts and offers '
            'that sound too good all need checking twice here',
    convite:
        'Before any large decision, let a moon cycle pass — what is true will still be '
            'there afterwards. Write down what you swore you would never do, so you '
            'recognise the turn when it comes. And trust the strange: it is taking you '
            'where you need to go',
  ),
  EraContent(
    regente: EraRegente.jupiter,
    titulo: 'A time to harvest and multiply',
    tags: ['expansion', 'abundance', 'wisdom'],
    corpo:
        'Jupiter is the most generous ruler of the cycle, and sixteen years of him change '
            'the size of your life. What you planted starts coming in by the armful. Study, '
            'travel, recognition and money arrive more easily than usual, and people with '
            'the power to open doors cross your path without you looking for them',
    sombra:
        'Abundance also overdoes it. You can say yes too often, promise more than the week '
            'holds, and grow in every direction without finishing anything. Excess — of '
            'food, of spending, of opinions — is how Jupiter warns you',
    convite:
        'Choose one direction to grow in and decline the rest politely. Teach what you '
            'know: in this time, giving multiplies instead of subtracting. Tin, sage and a '
            'purpose written where you see it daily',
  ),
  EraContent(
    regente: EraRegente.saturno,
    titulo: 'A time to build with your own hands',
    tags: ['discipline', 'maturity', 'consequence'],
    corpo:
        'Saturn is the stern teacher of the cycle, and nineteen years of him build a whole '
            'person. Nothing comes free, but nothing that comes is lost: what you raise '
            'here stands for decades. It is the time to own what is yours, finish what was '
            'left half-done, and discover you can carry more than you thought',
    sombra:
        'It is also the heaviest stretch. Old choices come back asking to be settled, '
            'doors take their time, and the tiredness is real. You may want to shut down, '
            'to decide you are not capable, to treat yourself with a harshness you would '
            'never use on anyone else',
    convite:
        'Do a little, but do it every day — Saturn pays for constancy, never for bursts. '
            'Write down what you finished, not what is missing. Lead, cypress and the '
            'patience of someone who knows this harvest is not for this moon',
  ),
  EraContent(
    regente: EraRegente.mercurio,
    titulo: 'A time to learn and connect',
    tags: ['communication', 'study', 'movement'],
    corpo:
        'Mercury opens seventeen years with the mind switched on. You learn fast, speak '
            'better and move more: new people, new subjects, new cities. It is excellent '
            'for studying, writing, negotiating and any work where words are the tool. '
            'Ideas arrive faster than you can write them down',
    sombra:
        'A mind switched on does not switch off. Thoughts on loop, insomnia from a full '
            'head, ten things started and none finished. And the word that opens a door is '
            'the same one that shuts it: here, speaking without thinking costs',
    convite:
        'Write — in a journal, a notebook, anywhere. Getting it out is what lets this mind '
            'rest. Pick three subjects a year and leave the others for later. Mercury, '
            'lavender and deliberate silence once a week',
  ),
];

/// Phases — the short flavour each ruler gives to the Era in progress.
const List<FaseContent> fasesEn = [
  FaseContent(
    regente: EraRegente.cauda,
    titulo: 'Let what is over fall away',
    tags: ['clearing', 'pause', 'intuition'],
    sabor:
        'The Tail passes briefly and asks for empty space. Something ends without noise, '
            'and holding on only makes it hurt more. Use it to clear out drawers, calendars '
            'and old promises',
  ),
  FaseContent(
    regente: EraRegente.venus,
    titulo: 'Focus on feeling good',
    tags: ['pleasure', 'affection', 'beauty'],
    sabor:
        'Venus sweetens the period. Meeting people gets easier, the body asks for care, '
            'and what is beautiful goes further than what is correct. A good time to ask '
            'for a raise, to confess, and to receive',
  ),
  FaseContent(
    regente: EraRegente.sol,
    titulo: 'Take your place',
    tags: ['visibility', 'name', 'clarity'],
    sabor:
        'The Sun turns the spotlight on for a short while. You are noticed, asked of and '
            'recognised in a larger dose. If you have something to show the world, show it '
            'now',
  ),
  FaseContent(
    regente: EraRegente.lua,
    titulo: 'Tend to what you feel',
    tags: ['emotion', 'home', 'rest'],
    sabor:
        'The Moon makes everything more sensitive. Family and household matters come '
            'forward, and intuition sharpens. If you feel like withdrawing, withdraw — this '
            'time it is not avoidance',
  ),
  FaseContent(
    regente: EraRegente.marte,
    titulo: 'Make it happen',
    tags: ['action', 'courage', 'friction'],
    sabor:
        'Mars speeds everything up. Energy to begin and appetite for a fight show up, '
            'sometimes in the same sentence. Spend it on your body and your work before it '
            'spends itself on an argument',
  ),
  FaseContent(
    regente: EraRegente.serpente,
    titulo: 'Expect the unexpected',
    tags: ['reversal', 'desire', 'haste'],
    sabor:
        'The Serpent reshuffles the deck. Plans change at the last minute and an '
            'opportunity shows up looking too good. Check it twice and do not sign in a '
            'hurry',
  ),
  FaseContent(
    regente: EraRegente.jupiter,
    titulo: 'Say yes to what expands',
    tags: ['luck', 'study', 'open door'],
    sabor:
        'Jupiter clears the way. Invitations, good news and people willing to help arrive '
            'easily. Just be careful not to accept more than your week can hold',
  ),
  FaseContent(
    regente: EraRegente.saturno,
    titulo: 'Finish what was left half-done',
    tags: ['effort', 'testing', 'structure'],
    sabor:
        'Saturn presses down. Everything takes longer and asks more, and whatever was done '
            'badly comes to light. It is uncomfortable and it is useful: what you repair '
            'now stays repaired',
  ),
  FaseContent(
    regente: EraRegente.mercurio,
    titulo: 'Speak, write, arrange',
    tags: ['word', 'idea', 'transit'],
    sabor:
        'Mercury quickens the mind and the conversation. Great for studying, negotiating '
            'and settling loose ends in writing. Bad for promising without thinking — read '
            'it again before you send',
  ),
];
