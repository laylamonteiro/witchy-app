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

String getCatSvgForPose(CatPose pose, bool isBlinking) {
  switch (pose) {
    case CatPose.sitting:
      return _getSittingCat(isBlinking);
    case CatPose.walking:
    case CatPose.alert:
    case CatPose.playing:
      return _getSittingCat(isBlinking); // Simplificado - todas usam pose sentada
    case CatPose.lying:
    case CatPose.sleeping:
    case CatPose.grooming:
      return _getSittingCat(isBlinking);
  }
}

// Gatinho sentado fofo com silhueta elegante e nariz de coração
String _getSittingCat(bool isBlinking) {
  final eyes = isBlinking
    ? '''
      <!-- Olhos fechados felizes (estilo ^_^) - menores -->
      <path d="M 22 22 Q 25 19.5 28 22" stroke="#C9A7FF" stroke-width="2" fill="none" stroke-linecap="round"/>
      <path d="M 36 22 Q 39 19.5 42 22" stroke="#C9A7FF" stroke-width="2" fill="none" stroke-linecap="round"/>
      <!-- Blush de felicidade -->
      <ellipse cx="19" cy="27" rx="3.5" ry="2" fill="#FF9EBB" opacity="0.6"/>
      <ellipse cx="45" cy="27" rx="3.5" ry="2" fill="#FF9EBB" opacity="0.6"/>
    '''
    : '''
      <!-- Olhos menores e fofos -->
      <ellipse cx="25" cy="22" rx="4" ry="4.5" fill="#FFFFFF"/>
      <ellipse cx="39" cy="22" rx="4" ry="4.5" fill="#FFFFFF"/>
      <!-- Outline dos olhos para mais definição -->
      <ellipse cx="25" cy="22" rx="4" ry="4.5" fill="none" stroke="#0B0A16" stroke-width="0.5"/>
      <ellipse cx="39" cy="22" rx="4" ry="4.5" fill="none" stroke="#0B0A16" stroke-width="0.5"/>
      <!-- Pupilas -->
      <ellipse cx="25.5" cy="22.5" rx="2.2" ry="2.8" fill="#1A1A2E"/>
      <ellipse cx="39.5" cy="22.5" rx="2.2" ry="2.8" fill="#1A1A2E"/>
      <!-- Brilho principal -->
      <circle cx="24" cy="20.5" r="1.5" fill="#FFFFFF"/>
      <circle cx="38" cy="20.5" r="1.5" fill="#FFFFFF"/>
      <!-- Brilho secundário -->
      <circle cx="26.5" cy="23.5" r="0.8" fill="#FFFFFF" opacity="0.8"/>
      <circle cx="40.5" cy="23.5" r="0.8" fill="#FFFFFF" opacity="0.8"/>
      <!-- Blush fofo permanente -->
      <ellipse cx="19" cy="27" rx="3.5" ry="2" fill="#FF9EBB" opacity="0.5"/>
      <ellipse cx="45" cy="27" rx="3.5" ry="2" fill="#FF9EBB" opacity="0.5"/>
    ''';

  return '''
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <!-- Gradiente para brilho mágico -->
        <radialGradient id="magicGlow" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="#C9A7FF" stop-opacity="0.2"/>
          <stop offset="100%" stop-color="#C9A7FF" stop-opacity="0"/>
        </radialGradient>
        <filter id="softGlow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="1.5" result="blur"/>
          <feMerge>
            <feMergeNode in="blur"/>
            <feMergeNode in="SourceGraphic"/>
          </feMerge>
        </filter>
      </defs>

      <!-- Aura mágica suave -->
      <ellipse cx="32" cy="38" rx="26" ry="22" fill="url(#magicGlow)"/>

      <!-- Sombra suave -->
      <ellipse cx="32" cy="59" rx="18" ry="4" fill="#C9A7FF" opacity="0.2"/>

      <!-- === RABO ELEGANTE COM CURVA === -->
      <path d="M 46 46 Q 54 42 56 32 Q 58 22 54 14 Q 51 10 48 12"
            stroke="#0B0A16" stroke-width="7" stroke-linecap="round" fill="none"/>
      <!-- Contorno do rabo -->
      <path d="M 46 46 Q 54 42 56 32 Q 58 22 54 14 Q 51 10 48 12"
            stroke="#2D2A3D" stroke-width="4" stroke-linecap="round" fill="none" opacity="0.3"/>

      <!-- === CORPO COM SILHUETA DEFINIDA === -->
      <ellipse cx="32" cy="46" rx="15" ry="13" fill="#0B0A16"/>
      <!-- Contorno sutil do corpo -->
      <ellipse cx="32" cy="46" rx="15" ry="13" fill="none" stroke="#1E1B2E" stroke-width="1" opacity="0.5"/>
      <!-- Peito com pelagem clara -->
      <ellipse cx="32" cy="48" rx="6" ry="7" fill="#1E1B2E" opacity="0.3"/>

      <!-- === CABEÇA REDONDA COM CONTORNO === -->
      <circle cx="32" cy="24" r="17" fill="#0B0A16"/>
      <!-- Contorno da cabeça para mais definição -->
      <circle cx="32" cy="24" r="17" fill="none" stroke="#1E1B2E" stroke-width="1" opacity="0.4"/>

      <!-- === ORELHAS PONTUDAS ELEGANTES === -->
      <!-- Orelha esquerda -->
      <path d="M 18 16 L 12 -1 L 27 11 Z" fill="#0B0A16"/>
      <path d="M 18 16 L 12 -1 L 27 11 Z" fill="none" stroke="#1E1B2E" stroke-width="0.5" opacity="0.5"/>
      <!-- Interior da orelha esquerda -->
      <path d="M 19 13 L 15 3 L 25 11 Z" fill="#FF9EBB"/>

      <!-- Orelha direita -->
      <path d="M 46 16 L 52 -1 L 37 11 Z" fill="#0B0A16"/>
      <path d="M 46 16 L 52 -1 L 37 11 Z" fill="none" stroke="#1E1B2E" stroke-width="0.5" opacity="0.5"/>
      <!-- Interior da orelha direita -->
      <path d="M 45 13 L 49 3 L 39 11 Z" fill="#FF9EBB"/>

      $eyes

      <!-- === NARIZ DE CORAÇÃO PEQUENO E MAIS ALTO === -->
      <path d="M 32 27
               C 30 25.5, 29.5 27, 30 28.5
               L 32 31
               L 34 28.5
               C 34.5 27, 34 25.5, 32 27 Z"
            fill="#FF6B9D"/>
      <!-- Brilho no nariz coração -->
      <ellipse cx="30.8" cy="27" rx="0.8" ry="0.5" fill="#FFFFFF" opacity="0.6"/>
      <!-- Contorno sutil do nariz -->
      <path d="M 32 27
               C 30 25.5, 29.5 27, 30 28.5
               L 32 31
               L 34 28.5
               C 34.5 27, 34 25.5, 32 27 Z"
            fill="none" stroke="#E85A8A" stroke-width="0.3"/>

      <!-- === BOQUINHA FOFA LOGO EMBAIXO DO NARIZ === -->
      <path d="M 29.5 33 Q 30.8 34.5 32 33 Q 33.2 34.5 34.5 33"
            stroke="#FF6B9D" stroke-width="1.2" fill="none" stroke-linecap="round"/>

      <!-- === BIGODES ELEGANTES === -->
      <!-- Esquerda -->
      <line x1="8" y1="24" x2="18" y2="25" stroke="#B7B2D6" stroke-width="1.2" stroke-linecap="round"/>
      <line x1="7" y1="28" x2="18" y2="28" stroke="#B7B2D6" stroke-width="1.2" stroke-linecap="round"/>
      <line x1="9" y1="32" x2="18" y2="31" stroke="#B7B2D6" stroke-width="1" stroke-linecap="round" opacity="0.8"/>
      <!-- Direita -->
      <line x1="46" y1="25" x2="56" y2="24" stroke="#B7B2D6" stroke-width="1.2" stroke-linecap="round"/>
      <line x1="46" y1="28" x2="57" y2="28" stroke="#B7B2D6" stroke-width="1.2" stroke-linecap="round"/>
      <line x1="46" y1="31" x2="55" y2="32" stroke="#B7B2D6" stroke-width="1" stroke-linecap="round" opacity="0.8"/>

      <!-- === PATINHAS COM SILHUETA === -->
      <ellipse cx="24" cy="55" rx="6" ry="5" fill="#0B0A16"/>
      <ellipse cx="40" cy="55" rx="6" ry="5" fill="#0B0A16"/>
      <!-- Contorno das patinhas -->
      <ellipse cx="24" cy="55" rx="6" ry="5" fill="none" stroke="#1E1B2E" stroke-width="0.5" opacity="0.5"/>
      <ellipse cx="40" cy="55" rx="6" ry="5" fill="none" stroke="#1E1B2E" stroke-width="0.5" opacity="0.5"/>

      <!-- Almofadinhas rosadas -->
      <ellipse cx="24" cy="56" rx="3" ry="2.2" fill="#FF9EBB"/>
      <circle cx="22" cy="54" r="1.3" fill="#FF9EBB"/>
      <circle cx="26" cy="54" r="1.3" fill="#FF9EBB"/>
      <circle cx="24" cy="52.5" r="1" fill="#FF9EBB" opacity="0.9"/>

      <ellipse cx="40" cy="56" rx="3" ry="2.2" fill="#FF9EBB"/>
      <circle cx="38" cy="54" r="1.3" fill="#FF9EBB"/>
      <circle cx="42" cy="54" r="1.3" fill="#FF9EBB"/>
      <circle cx="40" cy="52.5" r="1" fill="#FF9EBB" opacity="0.9"/>

      <!-- === COLEIRA MÁGICA === -->
      <ellipse cx="32" cy="38" rx="11" ry="2" fill="#C9A7FF" filter="url(#softGlow)"/>
      <!-- Pingente em forma de lua/estrela -->
      <circle cx="32" cy="40" r="3" fill="#FFE8A3"/>
      <circle cx="32" cy="40" r="2" fill="#FFF4D1"/>
      <!-- Estrela no pingente -->
      <path d="M 32 38.5 L 32.6 39.3 L 33.5 39.3 L 32.8 39.9 L 33.1 40.8 L 32 40.3 L 30.9 40.8 L 31.2 39.9 L 30.5 39.3 L 31.4 39.3 Z"
            fill="#E8C77A"/>

      <!-- Estrelinhas mágicas decorativas -->
      <text x="6" y="10" font-size="5" fill="#FFE8A3" opacity="0.7">✦</text>
      <text x="54" y="6" font-size="4" fill="#C9A7FF" opacity="0.6">✧</text>
      <text x="58" y="48" font-size="3" fill="#FFE8A3" opacity="0.5">✦</text>
    </svg>
  ''';
}
