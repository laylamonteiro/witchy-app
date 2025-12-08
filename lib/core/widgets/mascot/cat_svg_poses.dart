// Poses do gatinho mascote em SVG inline

enum CatPose {
  sitting,
  walking,
  lying,
  sleeping,
  alert,
  grooming,
  playing,
}

String getCatSvgForPose(CatPose pose, bool isBlinking, {bool isHappy = false}) {
  switch (pose) {
    case CatPose.sitting:
      return _getSittingCat(isBlinking, isHappy: isHappy);
    case CatPose.walking:
    case CatPose.alert:
    case CatPose.playing:
      return _getSittingCat(isBlinking, isHappy: isHappy); // Simplificado - todas usam pose sentada
    case CatPose.lying:
    case CatPose.sleeping:
    case CatPose.grooming:
      return _getSittingCat(isBlinking, isHappy: isHappy);
  }
}

// Gatinho bruxinha com capa roxa - baseado na imagem de referência
String _getSittingCat(bool isBlinking, {bool isHappy = false}) {
  // Expressão feliz (quando toca) - olhinhos fechados estilo ^_^
  if (isHappy) {
    return _getHappyCatSvg();
  }

  final eyes = isBlinking
    ? '''
      <!-- Olhos fechados piscando -->
      <path d="M 19 22 L 27 22" stroke="#FFD93D" stroke-width="2.5" fill="none" stroke-linecap="round"/>
      <path d="M 37 22 L 45 22" stroke="#FFD93D" stroke-width="2.5" fill="none" stroke-linecap="round"/>
    '''
    : '''
      <!-- Olhos amarelos com expressão séria/brava -->
      <ellipse cx="23" cy="22" rx="6" ry="7" fill="#FFD93D"/>
      <ellipse cx="41" cy="22" rx="6" ry="7" fill="#FFD93D"/>
      <!-- Contorno dos olhos -->
      <ellipse cx="23" cy="22" rx="6" ry="7" fill="none" stroke="#E8B92D" stroke-width="0.8"/>
      <ellipse cx="41" cy="22" rx="6" ry="7" fill="none" stroke="#E8B92D" stroke-width="0.8"/>
      <!-- Pupilas verticais de gato -->
      <ellipse cx="23" cy="22" rx="1.5" ry="5" fill="#0B0A16"/>
      <ellipse cx="41" cy="22" rx="1.5" ry="5" fill="#0B0A16"/>
      <!-- Brilho nos olhos -->
      <circle cx="21" cy="19" r="1.8" fill="#FFFFFF"/>
      <circle cx="39" cy="19" r="1.8" fill="#FFFFFF"/>
      <!-- Sobrancelhas bravas inclinadas -->
      <path d="M 17 15 L 27 17" stroke="#2D2640" stroke-width="2.5" stroke-linecap="round"/>
      <path d="M 47 15 L 37 17" stroke="#2D2640" stroke-width="2.5" stroke-linecap="round"/>
    ''';

  return '''
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <!-- Gradiente para a capa roxo-magenta -->
        <linearGradient id="capeGradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="#8B5CF6"/>
          <stop offset="50%" stop-color="#A855F7"/>
          <stop offset="100%" stop-color="#D946EF"/>
        </linearGradient>
        <!-- Gradiente para brilho da capa -->
        <linearGradient id="capeShine" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stop-color="#C084FC" stop-opacity="0.6"/>
          <stop offset="50%" stop-color="#E879F9" stop-opacity="0.3"/>
          <stop offset="100%" stop-color="#C084FC" stop-opacity="0.6"/>
        </linearGradient>
        <!-- Gradiente para brilho mágico -->
        <radialGradient id="magicGlow" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="#A855F7" stop-opacity="0.15"/>
          <stop offset="100%" stop-color="#A855F7" stop-opacity="0"/>
        </radialGradient>
        <filter id="softGlow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="1" result="blur"/>
          <feMerge>
            <feMergeNode in="blur"/>
            <feMergeNode in="SourceGraphic"/>
          </feMerge>
        </filter>
      </defs>

      <!-- Aura mágica suave -->
      <ellipse cx="32" cy="40" rx="24" ry="20" fill="url(#magicGlow)"/>

      <!-- Sombra suave -->
      <ellipse cx="32" cy="60" rx="16" ry="3" fill="#A855F7" opacity="0.15"/>

      <!-- === CAUDA ELEGANTE CURVADA === -->
      <path d="M 48 50 Q 56 46 58 38 Q 60 28 56 20 Q 54 16 52 18"
            stroke="#2D2640" stroke-width="6" stroke-linecap="round" fill="none"/>
      <!-- Highlight da cauda -->
      <path d="M 48 50 Q 56 46 58 38 Q 60 28 56 20 Q 54 16 52 18"
            stroke="#3D3555" stroke-width="3" stroke-linecap="round" fill="none" opacity="0.4"/>

      <!-- === CAPA ROXA MÁGICA - PARTE DE TRÁS === -->
      <path d="M 12 36
               Q 8 44 10 54
               L 14 58
               Q 18 56 22 58
               L 26 56
               Q 32 58 38 56
               L 42 58
               Q 46 56 50 58
               L 54 54
               Q 56 44 52 36
               Q 44 38 32 38
               Q 20 38 12 36 Z"
            fill="url(#capeGradient)"/>
      <!-- Brilho na capa -->
      <path d="M 14 40
               Q 10 48 12 56
               L 16 54
               Q 18 46 16 40 Z"
            fill="url(#capeShine)" opacity="0.5"/>
      <path d="M 50 40
               Q 54 48 52 56
               L 48 54
               Q 46 46 48 40 Z"
            fill="url(#capeShine)" opacity="0.5"/>
      <!-- Pontas da capa -->
      <path d="M 10 54 L 8 60 L 14 58 Z" fill="#7C3AED"/>
      <path d="M 26 56 L 24 62 L 30 58 Z" fill="#9333EA"/>
      <path d="M 38 56 L 40 62 L 34 58 Z" fill="#9333EA"/>
      <path d="M 54 54 L 56 60 L 50 58 Z" fill="#7C3AED"/>

      <!-- === CORPO DO GATO === -->
      <ellipse cx="32" cy="48" rx="12" ry="10" fill="#2D2640"/>
      <!-- Textura do corpo -->
      <ellipse cx="32" cy="48" rx="12" ry="10" fill="none" stroke="#3D3555" stroke-width="0.5" opacity="0.5"/>

      <!-- === CABEÇA DO GATO === -->
      <ellipse cx="32" cy="24" rx="16" ry="14" fill="#2D2640"/>
      <!-- Contorno da cabeça -->
      <ellipse cx="32" cy="24" rx="16" ry="14" fill="none" stroke="#3D3555" stroke-width="0.8" opacity="0.4"/>

      <!-- === ORELHAS PONTUDAS === -->
      <!-- Orelha esquerda -->
      <path d="M 18 18 L 14 2 L 26 14 Z" fill="#2D2640"/>
      <path d="M 18 18 L 14 2 L 26 14 Z" fill="none" stroke="#3D3555" stroke-width="0.5" opacity="0.5"/>
      <!-- Interior rosa da orelha esquerda -->
      <path d="M 19 15 L 16 5 L 24 13 Z" fill="#F8A5C2"/>

      <!-- Orelha direita -->
      <path d="M 46 18 L 50 2 L 38 14 Z" fill="#2D2640"/>
      <path d="M 46 18 L 50 2 L 38 14 Z" fill="none" stroke="#3D3555" stroke-width="0.5" opacity="0.5"/>
      <!-- Interior rosa da orelha direita -->
      <path d="M 45 15 L 48 5 L 40 13 Z" fill="#F8A5C2"/>

      $eyes

      <!-- === NARIZ ROSA TRIANGULAR === -->
      <path d="M 32 29 L 30 32 L 34 32 Z" fill="#F8A5C2"/>
      <!-- Brilho no nariz -->
      <ellipse cx="31" cy="30" rx="0.8" ry="0.5" fill="#FFFFFF" opacity="0.5"/>

      <!-- === CAPA ROXA - PARTE DA FRENTE (LAÇO) === -->
      <!-- Laço central -->
      <ellipse cx="32" cy="36" rx="4" ry="2.5" fill="#7C3AED"/>
      <!-- Centro do laço -->
      <circle cx="32" cy="36" r="2" fill="#6D28D9"/>
      <!-- Asas do laço -->
      <path d="M 28 36 Q 22 32 20 36 Q 22 40 28 36" fill="#9333EA"/>
      <path d="M 36 36 Q 42 32 44 36 Q 42 40 36 36" fill="#9333EA"/>
      <!-- Brilho no laço -->
      <ellipse cx="23" cy="35" rx="1.5" ry="1" fill="#C084FC" opacity="0.6"/>
      <ellipse cx="41" cy="35" rx="1.5" ry="1" fill="#C084FC" opacity="0.6"/>
      <!-- Pontas do laço caindo -->
      <path d="M 30 38 Q 28 42 26 46" stroke="#7C3AED" stroke-width="2.5" stroke-linecap="round" fill="none"/>
      <path d="M 34 38 Q 36 42 38 46" stroke="#7C3AED" stroke-width="2.5" stroke-linecap="round" fill="none"/>

      <!-- === PATINHAS === -->
      <ellipse cx="24" cy="56" rx="5" ry="4" fill="#2D2640"/>
      <ellipse cx="40" cy="56" rx="5" ry="4" fill="#2D2640"/>
      <!-- Contorno das patinhas -->
      <ellipse cx="24" cy="56" rx="5" ry="4" fill="none" stroke="#3D3555" stroke-width="0.5" opacity="0.5"/>
      <ellipse cx="40" cy="56" rx="5" ry="4" fill="none" stroke="#3D3555" stroke-width="0.5" opacity="0.5"/>

      <!-- Almofadinhas rosadas -->
      <ellipse cx="24" cy="57" rx="2.5" ry="1.8" fill="#F8A5C2"/>
      <circle cx="22.5" cy="55.5" r="1" fill="#F8A5C2"/>
      <circle cx="25.5" cy="55.5" r="1" fill="#F8A5C2"/>
      <circle cx="24" cy="54" r="0.8" fill="#F8A5C2"/>

      <ellipse cx="40" cy="57" rx="2.5" ry="1.8" fill="#F8A5C2"/>
      <circle cx="38.5" cy="55.5" r="1" fill="#F8A5C2"/>
      <circle cx="41.5" cy="55.5" r="1" fill="#F8A5C2"/>
      <circle cx="40" cy="54" r="0.8" fill="#F8A5C2"/>

      <!-- Estrelinhas mágicas decorativas -->
      <text x="4" y="12" font-size="5" fill="#FFD93D" opacity="0.7">✦</text>
      <text x="56" y="8" font-size="4" fill="#A855F7" opacity="0.6">✧</text>
      <text x="58" y="44" font-size="3" fill="#FFD93D" opacity="0.5">✦</text>
    </svg>
  ''';
}

// Gatinho feliz quando toca nele - olhinhos fechados estilo ^_^
String _getHappyCatSvg() {
  return '''
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <!-- Gradiente para a capa roxo-magenta -->
        <linearGradient id="capeGradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="#8B5CF6"/>
          <stop offset="50%" stop-color="#A855F7"/>
          <stop offset="100%" stop-color="#D946EF"/>
        </linearGradient>
        <!-- Gradiente para brilho da capa -->
        <linearGradient id="capeShine" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stop-color="#C084FC" stop-opacity="0.6"/>
          <stop offset="50%" stop-color="#E879F9" stop-opacity="0.3"/>
          <stop offset="100%" stop-color="#C084FC" stop-opacity="0.6"/>
        </linearGradient>
        <!-- Gradiente para brilho mágico -->
        <radialGradient id="magicGlow" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="#A855F7" stop-opacity="0.15"/>
          <stop offset="100%" stop-color="#A855F7" stop-opacity="0"/>
        </radialGradient>
        <filter id="softGlow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="1" result="blur"/>
          <feMerge>
            <feMergeNode in="blur"/>
            <feMergeNode in="SourceGraphic"/>
          </feMerge>
        </filter>
      </defs>

      <!-- Aura mágica suave -->
      <ellipse cx="32" cy="40" rx="24" ry="20" fill="url(#magicGlow)"/>

      <!-- Sombra suave -->
      <ellipse cx="32" cy="60" rx="16" ry="3" fill="#A855F7" opacity="0.15"/>

      <!-- === CAUDA ELEGANTE CURVADA === -->
      <path d="M 48 50 Q 56 46 58 38 Q 60 28 56 20 Q 54 16 52 18"
            stroke="#2D2640" stroke-width="6" stroke-linecap="round" fill="none"/>
      <!-- Highlight da cauda -->
      <path d="M 48 50 Q 56 46 58 38 Q 60 28 56 20 Q 54 16 52 18"
            stroke="#3D3555" stroke-width="3" stroke-linecap="round" fill="none" opacity="0.4"/>

      <!-- === CAPA ROXA MÁGICA - PARTE DE TRÁS === -->
      <path d="M 12 36
               Q 8 44 10 54
               L 14 58
               Q 18 56 22 58
               L 26 56
               Q 32 58 38 56
               L 42 58
               Q 46 56 50 58
               L 54 54
               Q 56 44 52 36
               Q 44 38 32 38
               Q 20 38 12 36 Z"
            fill="url(#capeGradient)"/>
      <!-- Brilho na capa -->
      <path d="M 14 40
               Q 10 48 12 56
               L 16 54
               Q 18 46 16 40 Z"
            fill="url(#capeShine)" opacity="0.5"/>
      <path d="M 50 40
               Q 54 48 52 56
               L 48 54
               Q 46 46 48 40 Z"
            fill="url(#capeShine)" opacity="0.5"/>
      <!-- Pontas da capa -->
      <path d="M 10 54 L 8 60 L 14 58 Z" fill="#7C3AED"/>
      <path d="M 26 56 L 24 62 L 30 58 Z" fill="#9333EA"/>
      <path d="M 38 56 L 40 62 L 34 58 Z" fill="#9333EA"/>
      <path d="M 54 54 L 56 60 L 50 58 Z" fill="#7C3AED"/>

      <!-- === CORPO DO GATO === -->
      <ellipse cx="32" cy="48" rx="12" ry="10" fill="#2D2640"/>
      <!-- Textura do corpo -->
      <ellipse cx="32" cy="48" rx="12" ry="10" fill="none" stroke="#3D3555" stroke-width="0.5" opacity="0.5"/>

      <!-- === CABEÇA DO GATO === -->
      <ellipse cx="32" cy="24" rx="16" ry="14" fill="#2D2640"/>
      <!-- Contorno da cabeça -->
      <ellipse cx="32" cy="24" rx="16" ry="14" fill="none" stroke="#3D3555" stroke-width="0.8" opacity="0.4"/>

      <!-- === ORELHAS PONTUDAS === -->
      <!-- Orelha esquerda -->
      <path d="M 18 18 L 14 2 L 26 14 Z" fill="#2D2640"/>
      <path d="M 18 18 L 14 2 L 26 14 Z" fill="none" stroke="#3D3555" stroke-width="0.5" opacity="0.5"/>
      <!-- Interior rosa da orelha esquerda -->
      <path d="M 19 15 L 16 5 L 24 13 Z" fill="#F8A5C2"/>

      <!-- Orelha direita -->
      <path d="M 46 18 L 50 2 L 38 14 Z" fill="#2D2640"/>
      <path d="M 46 18 L 50 2 L 38 14 Z" fill="none" stroke="#3D3555" stroke-width="0.5" opacity="0.5"/>
      <!-- Interior rosa da orelha direita -->
      <path d="M 45 15 L 48 5 L 40 13 Z" fill="#F8A5C2"/>

      <!-- === OLHINHOS FELIZES FECHADOS estilo ^_^ === -->
      <path d="M 18 21 Q 23 17 28 21" stroke="#FFD93D" stroke-width="3" fill="none" stroke-linecap="round"/>
      <path d="M 36 21 Q 41 17 46 21" stroke="#FFD93D" stroke-width="3" fill="none" stroke-linecap="round"/>
      <!-- Blush de felicidade -->
      <ellipse cx="17" cy="26" rx="4" ry="2.5" fill="#FF9EBB" opacity="0.6"/>
      <ellipse cx="47" cy="26" rx="4" ry="2.5" fill="#FF9EBB" opacity="0.6"/>

      <!-- === NARIZ ROSA TRIANGULAR === -->
      <path d="M 32 29 L 30 32 L 34 32 Z" fill="#F8A5C2"/>
      <!-- Brilho no nariz -->
      <ellipse cx="31" cy="30" rx="0.8" ry="0.5" fill="#FFFFFF" opacity="0.5"/>

      <!-- === BOQUINHA SORRIDENTE === -->
      <path d="M 28 33 Q 32 37 36 33" stroke="#F8A5C2" stroke-width="1.5" fill="none" stroke-linecap="round"/>

      <!-- === CAPA ROXA - PARTE DA FRENTE (LAÇO) === -->
      <!-- Laço central -->
      <ellipse cx="32" cy="36" rx="4" ry="2.5" fill="#7C3AED"/>
      <!-- Centro do laço -->
      <circle cx="32" cy="36" r="2" fill="#6D28D9"/>
      <!-- Asas do laço -->
      <path d="M 28 36 Q 22 32 20 36 Q 22 40 28 36" fill="#9333EA"/>
      <path d="M 36 36 Q 42 32 44 36 Q 42 40 36 36" fill="#9333EA"/>
      <!-- Brilho no laço -->
      <ellipse cx="23" cy="35" rx="1.5" ry="1" fill="#C084FC" opacity="0.6"/>
      <ellipse cx="41" cy="35" rx="1.5" ry="1" fill="#C084FC" opacity="0.6"/>
      <!-- Pontas do laço caindo -->
      <path d="M 30 38 Q 28 42 26 46" stroke="#7C3AED" stroke-width="2.5" stroke-linecap="round" fill="none"/>
      <path d="M 34 38 Q 36 42 38 46" stroke="#7C3AED" stroke-width="2.5" stroke-linecap="round" fill="none"/>

      <!-- === PATINHAS === -->
      <ellipse cx="24" cy="56" rx="5" ry="4" fill="#2D2640"/>
      <ellipse cx="40" cy="56" rx="5" ry="4" fill="#2D2640"/>
      <!-- Contorno das patinhas -->
      <ellipse cx="24" cy="56" rx="5" ry="4" fill="none" stroke="#3D3555" stroke-width="0.5" opacity="0.5"/>
      <ellipse cx="40" cy="56" rx="5" ry="4" fill="none" stroke="#3D3555" stroke-width="0.5" opacity="0.5"/>

      <!-- Almofadinhas rosadas -->
      <ellipse cx="24" cy="57" rx="2.5" ry="1.8" fill="#F8A5C2"/>
      <circle cx="22.5" cy="55.5" r="1" fill="#F8A5C2"/>
      <circle cx="25.5" cy="55.5" r="1" fill="#F8A5C2"/>
      <circle cx="24" cy="54" r="0.8" fill="#F8A5C2"/>

      <ellipse cx="40" cy="57" rx="2.5" ry="1.8" fill="#F8A5C2"/>
      <circle cx="38.5" cy="55.5" r="1" fill="#F8A5C2"/>
      <circle cx="41.5" cy="55.5" r="1" fill="#F8A5C2"/>
      <circle cx="40" cy="54" r="0.8" fill="#F8A5C2"/>

      <!-- Estrelinhas mágicas decorativas - mais brilhantes quando feliz -->
      <text x="4" y="12" font-size="6" fill="#FFD93D" opacity="0.9">✦</text>
      <text x="56" y="8" font-size="5" fill="#A855F7" opacity="0.8">✧</text>
      <text x="58" y="44" font-size="4" fill="#FFD93D" opacity="0.7">✦</text>
      <text x="2" y="32" font-size="4" fill="#FF9EBB" opacity="0.7">♥</text>
      <text x="58" y="28" font-size="4" fill="#FF9EBB" opacity="0.7">♥</text>
    </svg>
  ''';
}
