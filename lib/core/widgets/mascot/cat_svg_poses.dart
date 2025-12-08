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
      return _getSittingCat(isBlinking, isHappy: isHappy);
    case CatPose.lying:
    case CatPose.sleeping:
    case CatPose.grooming:
      return _getSittingCat(isBlinking, isHappy: isHappy);
  }
}

// Gatinho bruxinha com capa roxa - baseado na imagem de referência
String _getSittingCat(bool isBlinking, {bool isHappy = false}) {
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
          <stop offset="0%" stop-color="#7C3AED"/>
          <stop offset="50%" stop-color="#9333EA"/>
          <stop offset="100%" stop-color="#C026D3"/>
        </linearGradient>
        <!-- Gradiente para brilho da capa -->
        <linearGradient id="capeShine" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" stop-color="#A855F7" stop-opacity="0.4"/>
          <stop offset="100%" stop-color="#7C3AED" stop-opacity="0"/>
        </linearGradient>
        <!-- Gradiente para brilho mágico -->
        <radialGradient id="magicGlow" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="#A855F7" stop-opacity="0.12"/>
          <stop offset="100%" stop-color="#A855F7" stop-opacity="0"/>
        </radialGradient>
      </defs>

      <!-- Aura mágica suave -->
      <ellipse cx="32" cy="42" rx="22" ry="18" fill="url(#magicGlow)"/>

      <!-- Sombra suave no chão -->
      <ellipse cx="32" cy="60" rx="14" ry="3" fill="#1A1730" opacity="0.3"/>

      <!-- === CAUDA MAIS ESCURA === -->
      <path d="M 46 48 Q 54 44 56 34 Q 58 24 54 16 Q 52 12 50 14"
            stroke="#1A1730" stroke-width="6" stroke-linecap="round" fill="none"/>
      <!-- Highlight sutil da cauda -->
      <path d="M 46 48 Q 54 44 56 34 Q 58 24 54 16 Q 52 12 50 14"
            stroke="#2D2640" stroke-width="2" stroke-linecap="round" fill="none" opacity="0.5"/>

      <!-- === CAPA ROXA - CAINDO GRACIOSAMENTE === -->
      <!-- Parte de trás da capa (mais suave e arredondada) -->
      <path d="M 18 34
               C 14 36, 10 42, 10 50
               Q 10 56, 14 58
               Q 20 60, 26 58
               Q 32 60, 38 58
               Q 44 60, 50 58
               Q 54 56, 54 50
               C 54 42, 50 36, 46 34
               Q 38 36, 32 36
               Q 26 36, 18 34 Z"
            fill="url(#capeGradient)"/>
      <!-- Brilho na capa (efeito de tecido brilhante) -->
      <path d="M 20 36 Q 16 44 16 52 Q 18 50 20 44 Q 22 38 20 36 Z"
            fill="#C084FC" opacity="0.3"/>
      <path d="M 44 36 Q 48 44 48 52 Q 46 50 44 44 Q 42 38 44 36 Z"
            fill="#C084FC" opacity="0.3"/>
      <!-- Pontas da capa (onduladas) -->
      <path d="M 14 58 Q 12 62 16 60 Q 20 58 18 56" fill="#6D28D9"/>
      <path d="M 26 58 Q 24 63 28 61 Q 32 59 30 57" fill="#7C3AED"/>
      <path d="M 38 58 Q 36 63 40 61 Q 44 59 42 57" fill="#7C3AED"/>
      <path d="M 50 58 Q 52 62 48 60 Q 44 58 46 56" fill="#6D28D9"/>

      <!-- === CORPO DO GATO === -->
      <ellipse cx="32" cy="48" rx="11" ry="9" fill="#2D2640"/>

      <!-- === PATINHAS TRASEIRAS === -->
      <ellipse cx="24" cy="56" rx="5" ry="4" fill="#2D2640"/>
      <ellipse cx="40" cy="56" rx="5" ry="4" fill="#2D2640"/>

      <!-- === PATINHAS DIANTEIRAS === -->
      <ellipse cx="26" cy="52" rx="3.5" ry="5" fill="#2D2640"/>
      <ellipse cx="38" cy="52" rx="3.5" ry="5" fill="#2D2640"/>
      <!-- Almofadinhas das patinhas dianteiras -->
      <ellipse cx="26" cy="55" rx="2" ry="1.5" fill="#F8A5C2"/>
      <ellipse cx="38" cy="55" rx="2" ry="1.5" fill="#F8A5C2"/>

      <!-- Almofadinhas das patinhas traseiras -->
      <ellipse cx="24" cy="57" rx="2.5" ry="1.8" fill="#F8A5C2"/>
      <ellipse cx="40" cy="57" rx="2.5" ry="1.8" fill="#F8A5C2"/>

      <!-- === CABEÇA DO GATO === -->
      <ellipse cx="32" cy="24" rx="16" ry="14" fill="#2D2640"/>

      <!-- === ORELHAS PONTUDAS === -->
      <!-- Orelha esquerda -->
      <path d="M 18 18 L 14 2 L 26 14 Z" fill="#2D2640"/>
      <!-- Interior rosa da orelha esquerda -->
      <path d="M 19 15 L 16 5 L 24 13 Z" fill="#F8A5C2"/>

      <!-- Orelha direita -->
      <path d="M 46 18 L 50 2 L 38 14 Z" fill="#2D2640"/>
      <!-- Interior rosa da orelha direita -->
      <path d="M 45 15 L 48 5 L 40 13 Z" fill="#F8A5C2"/>

      $eyes

      <!-- === NARIZ ROSA === -->
      <path d="M 32 29 L 30 32 L 34 32 Z" fill="#F8A5C2"/>
      <ellipse cx="31" cy="30" rx="0.8" ry="0.5" fill="#FFFFFF" opacity="0.5"/>

      <!-- === LAÇO DA CAPA === -->
      <!-- Centro do laço -->
      <circle cx="32" cy="36" r="2.5" fill="#6D28D9"/>
      <!-- Asas do laço (mais arredondadas) -->
      <ellipse cx="24" cy="36" rx="5" ry="3" fill="#9333EA"/>
      <ellipse cx="40" cy="36" rx="5" ry="3" fill="#9333EA"/>
      <!-- Brilho no laço -->
      <ellipse cx="23" cy="35" rx="2" ry="1" fill="#C084FC" opacity="0.5"/>
      <ellipse cx="41" cy="35" rx="2" ry="1" fill="#C084FC" opacity="0.5"/>
      <!-- Pontas do laço caindo -->
      <path d="M 30 38 Q 28 43 26 48" stroke="#7C3AED" stroke-width="3" stroke-linecap="round" fill="none"/>
      <path d="M 34 38 Q 36 43 38 48" stroke="#7C3AED" stroke-width="3" stroke-linecap="round" fill="none"/>

      <!-- Estrelinhas mágicas decorativas -->
      <text x="4" y="10" font-size="5" fill="#FFD93D" opacity="0.7">✦</text>
      <text x="56" y="6" font-size="4" fill="#A855F7" opacity="0.6">✧</text>
      <text x="2" y="38" font-size="3" fill="#FFD93D" opacity="0.5">✦</text>
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
          <stop offset="0%" stop-color="#7C3AED"/>
          <stop offset="50%" stop-color="#9333EA"/>
          <stop offset="100%" stop-color="#C026D3"/>
        </linearGradient>
        <!-- Gradiente para brilho da capa -->
        <linearGradient id="capeShine" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" stop-color="#A855F7" stop-opacity="0.4"/>
          <stop offset="100%" stop-color="#7C3AED" stop-opacity="0"/>
        </linearGradient>
        <!-- Gradiente para brilho mágico -->
        <radialGradient id="magicGlow" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="#A855F7" stop-opacity="0.15"/>
          <stop offset="100%" stop-color="#A855F7" stop-opacity="0"/>
        </radialGradient>
      </defs>

      <!-- Aura mágica suave -->
      <ellipse cx="32" cy="42" rx="22" ry="18" fill="url(#magicGlow)"/>

      <!-- Sombra suave no chão -->
      <ellipse cx="32" cy="60" rx="14" ry="3" fill="#1A1730" opacity="0.3"/>

      <!-- === CAUDA MAIS ESCURA === -->
      <path d="M 46 48 Q 54 44 56 34 Q 58 24 54 16 Q 52 12 50 14"
            stroke="#1A1730" stroke-width="6" stroke-linecap="round" fill="none"/>
      <!-- Highlight sutil da cauda -->
      <path d="M 46 48 Q 54 44 56 34 Q 58 24 54 16 Q 52 12 50 14"
            stroke="#2D2640" stroke-width="2" stroke-linecap="round" fill="none" opacity="0.5"/>

      <!-- === CAPA ROXA - CAINDO GRACIOSAMENTE === -->
      <!-- Parte de trás da capa (mais suave e arredondada) -->
      <path d="M 18 34
               C 14 36, 10 42, 10 50
               Q 10 56, 14 58
               Q 20 60, 26 58
               Q 32 60, 38 58
               Q 44 60, 50 58
               Q 54 56, 54 50
               C 54 42, 50 36, 46 34
               Q 38 36, 32 36
               Q 26 36, 18 34 Z"
            fill="url(#capeGradient)"/>
      <!-- Brilho na capa (efeito de tecido brilhante) -->
      <path d="M 20 36 Q 16 44 16 52 Q 18 50 20 44 Q 22 38 20 36 Z"
            fill="#C084FC" opacity="0.3"/>
      <path d="M 44 36 Q 48 44 48 52 Q 46 50 44 44 Q 42 38 44 36 Z"
            fill="#C084FC" opacity="0.3"/>
      <!-- Pontas da capa (onduladas) -->
      <path d="M 14 58 Q 12 62 16 60 Q 20 58 18 56" fill="#6D28D9"/>
      <path d="M 26 58 Q 24 63 28 61 Q 32 59 30 57" fill="#7C3AED"/>
      <path d="M 38 58 Q 36 63 40 61 Q 44 59 42 57" fill="#7C3AED"/>
      <path d="M 50 58 Q 52 62 48 60 Q 44 58 46 56" fill="#6D28D9"/>

      <!-- === CORPO DO GATO === -->
      <ellipse cx="32" cy="48" rx="11" ry="9" fill="#2D2640"/>

      <!-- === PATINHAS TRASEIRAS === -->
      <ellipse cx="24" cy="56" rx="5" ry="4" fill="#2D2640"/>
      <ellipse cx="40" cy="56" rx="5" ry="4" fill="#2D2640"/>

      <!-- === PATINHAS DIANTEIRAS === -->
      <ellipse cx="26" cy="52" rx="3.5" ry="5" fill="#2D2640"/>
      <ellipse cx="38" cy="52" rx="3.5" ry="5" fill="#2D2640"/>
      <!-- Almofadinhas das patinhas dianteiras -->
      <ellipse cx="26" cy="55" rx="2" ry="1.5" fill="#F8A5C2"/>
      <ellipse cx="38" cy="55" rx="2" ry="1.5" fill="#F8A5C2"/>

      <!-- Almofadinhas das patinhas traseiras -->
      <ellipse cx="24" cy="57" rx="2.5" ry="1.8" fill="#F8A5C2"/>
      <ellipse cx="40" cy="57" rx="2.5" ry="1.8" fill="#F8A5C2"/>

      <!-- === CABEÇA DO GATO === -->
      <ellipse cx="32" cy="24" rx="16" ry="14" fill="#2D2640"/>

      <!-- === ORELHAS PONTUDAS === -->
      <!-- Orelha esquerda -->
      <path d="M 18 18 L 14 2 L 26 14 Z" fill="#2D2640"/>
      <!-- Interior rosa da orelha esquerda -->
      <path d="M 19 15 L 16 5 L 24 13 Z" fill="#F8A5C2"/>

      <!-- Orelha direita -->
      <path d="M 46 18 L 50 2 L 38 14 Z" fill="#2D2640"/>
      <!-- Interior rosa da orelha direita -->
      <path d="M 45 15 L 48 5 L 40 13 Z" fill="#F8A5C2"/>

      <!-- === OLHINHOS FELIZES FECHADOS estilo ^_^ === -->
      <path d="M 18 21 Q 23 17 28 21" stroke="#FFD93D" stroke-width="3" fill="none" stroke-linecap="round"/>
      <path d="M 36 21 Q 41 17 46 21" stroke="#FFD93D" stroke-width="3" fill="none" stroke-linecap="round"/>
      <!-- Blush de felicidade -->
      <ellipse cx="17" cy="26" rx="4" ry="2.5" fill="#FF9EBB" opacity="0.6"/>
      <ellipse cx="47" cy="26" rx="4" ry="2.5" fill="#FF9EBB" opacity="0.6"/>

      <!-- === NARIZ ROSA === -->
      <path d="M 32 29 L 30 32 L 34 32 Z" fill="#F8A5C2"/>
      <ellipse cx="31" cy="30" rx="0.8" ry="0.5" fill="#FFFFFF" opacity="0.5"/>

      <!-- === BOQUINHA SORRIDENTE === -->
      <path d="M 28 33 Q 32 37 36 33" stroke="#F8A5C2" stroke-width="1.5" fill="none" stroke-linecap="round"/>

      <!-- === LAÇO DA CAPA === -->
      <!-- Centro do laço -->
      <circle cx="32" cy="36" r="2.5" fill="#6D28D9"/>
      <!-- Asas do laço (mais arredondadas) -->
      <ellipse cx="24" cy="36" rx="5" ry="3" fill="#9333EA"/>
      <ellipse cx="40" cy="36" rx="5" ry="3" fill="#9333EA"/>
      <!-- Brilho no laço -->
      <ellipse cx="23" cy="35" rx="2" ry="1" fill="#C084FC" opacity="0.5"/>
      <ellipse cx="41" cy="35" rx="2" ry="1" fill="#C084FC" opacity="0.5"/>
      <!-- Pontas do laço caindo -->
      <path d="M 30 38 Q 28 43 26 48" stroke="#7C3AED" stroke-width="3" stroke-linecap="round" fill="none"/>
      <path d="M 34 38 Q 36 43 38 48" stroke="#7C3AED" stroke-width="3" stroke-linecap="round" fill="none"/>

      <!-- Estrelinhas mágicas decorativas - mais brilhantes quando feliz -->
      <text x="4" y="10" font-size="6" fill="#FFD93D" opacity="0.9">✦</text>
      <text x="56" y="6" font-size="5" fill="#A855F7" opacity="0.8">✧</text>
      <text x="2" y="38" font-size="4" fill="#FFD93D" opacity="0.7">✦</text>
      <text x="0" y="24" font-size="4" fill="#FF9EBB" opacity="0.7">♥</text>
      <text x="58" y="20" font-size="4" fill="#FF9EBB" opacity="0.7">♥</text>
    </svg>
  ''';
}
