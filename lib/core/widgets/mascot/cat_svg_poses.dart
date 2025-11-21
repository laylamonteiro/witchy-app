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

// Gatinho sentado SUPER FOFO (pose padrão) - Kawaii style!
String _getSittingCat(bool isBlinking) {
  final eyes = isBlinking
    ? '''
      <!-- Olhos fechados felizes (estilo ^_^) -->
      <path d="M 21 20 Q 24 17 27 20" stroke="#C9A7FF" stroke-width="2" fill="none" stroke-linecap="round"/>
      <path d="M 37 20 Q 40 17 43 20" stroke="#C9A7FF" stroke-width="2" fill="none" stroke-linecap="round"/>
      <!-- Blush de felicidade -->
      <ellipse cx="18" cy="24" rx="4" ry="2.5" fill="#FFB6C1" opacity="0.5"/>
      <ellipse cx="46" cy="24" rx="4" ry="2.5" fill="#FFB6C1" opacity="0.5"/>
    '''
    : '''
      <!-- Olhos GIGANTES kawaii -->
      <ellipse cx="24" cy="20" rx="6" ry="6.5" fill="#FFFFFF"/>
      <ellipse cx="40" cy="20" rx="6" ry="6.5" fill="#FFFFFF"/>
      <!-- Pupilas grandes e brilhantes -->
      <ellipse cx="25" cy="21" rx="3.5" ry="4" fill="#1A1A2E"/>
      <ellipse cx="41" cy="21" rx="3.5" ry="4" fill="#1A1A2E"/>
      <!-- Brilho principal (grande) -->
      <circle cx="22.5" cy="18" r="2" fill="#FFFFFF"/>
      <circle cx="38.5" cy="18" r="2" fill="#FFFFFF"/>
      <!-- Brilho secundário (pequeno) -->
      <circle cx="26" cy="22" r="1" fill="#FFFFFF" opacity="0.7"/>
      <circle cx="42" cy="22" r="1" fill="#FFFFFF" opacity="0.7"/>
      <!-- Reflexo lilás mágico -->
      <circle cx="23" cy="19" r="0.8" fill="#C9A7FF" opacity="0.5"/>
      <circle cx="39" cy="19" r="0.8" fill="#C9A7FF" opacity="0.5"/>
      <!-- Blush permanente fofo -->
      <ellipse cx="17" cy="25" rx="4" ry="2.5" fill="#FFB6C1" opacity="0.4"/>
      <ellipse cx="47" cy="25" rx="4" ry="2.5" fill="#FFB6C1" opacity="0.4"/>
    ''';

  return '''
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
      <!-- Brilho mágico de fundo -->
      <defs>
        <radialGradient id="magicGlow" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="#C9A7FF" stop-opacity="0.3"/>
          <stop offset="100%" stop-color="#C9A7FF" stop-opacity="0"/>
        </radialGradient>
        <filter id="softGlow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="2" result="blur"/>
          <feMerge>
            <feMergeNode in="blur"/>
            <feMergeNode in="SourceGraphic"/>
          </feMerge>
        </filter>
      </defs>

      <!-- Aura mágica -->
      <ellipse cx="32" cy="35" rx="28" ry="25" fill="url(#magicGlow)"/>

      <!-- Sombra fofinha -->
      <ellipse cx="32" cy="58" rx="20" ry="5" fill="#C9A7FF" opacity="0.25"/>

      <!-- Rabo SUPER FLUFFY com curvinha fofa -->
      <path d="M 46 44 Q 52 40 55 32 Q 57 24 54 16 Q 52 12 50 14"
            stroke="#0B0A16" stroke-width="9" stroke-linecap="round" fill="none"/>
      <!-- Pelagem do rabo -->
      <path d="M 46 44 Q 52 40 55 32 Q 57 24 54 16 Q 52 12 50 14"
            stroke="#1E1B2E" stroke-width="5" stroke-linecap="round" fill="none" opacity="0.4"/>
      <!-- Ponta fofa do rabo -->
      <circle cx="50" cy="13" r="4" fill="#0B0A16"/>
      <circle cx="50" cy="13" r="2" fill="#1E1B2E" opacity="0.3"/>

      <!-- Corpo REDONDINHO e fofo -->
      <ellipse cx="32" cy="44" rx="16" ry="14" fill="#0B0A16"/>
      <!-- Pelagem fofa no corpo -->
      <ellipse cx="32" cy="46" rx="12" ry="10" fill="#1E1B2E" opacity="0.2"/>
      <!-- Peito branquinho fofo -->
      <ellipse cx="32" cy="46" rx="7" ry="8" fill="#2D2A3D" opacity="0.4"/>

      <!-- Cabecinha REDONDA e grande (proporção kawaii) -->
      <circle cx="32" cy="22" r="16" fill="#0B0A16"/>
      <!-- Pelagem da cabeça -->
      <circle cx="32" cy="23" r="13" fill="#1E1B2E" opacity="0.15"/>

      <!-- Orelhinhas GRANDES e fofas -->
      <path d="M 20 14 L 14 0 L 26 10 Z" fill="#0B0A16"/>
      <path d="M 44 14 L 50 0 L 38 10 Z" fill="#0B0A16"/>
      <!-- Interior das orelhas rosa brilhante -->
      <path d="M 20 12 L 16 4 L 24 10 Z" fill="#FFB6C1"/>
      <path d="M 44 12 L 48 4 L 40 10 Z" fill="#FFB6C1"/>
      <!-- Tufinho de pelo nas orelhas -->
      <path d="M 18 8 Q 16 5 17 3" stroke="#2D2A3D" stroke-width="1.5" fill="none" stroke-linecap="round"/>
      <path d="M 46 8 Q 48 5 47 3" stroke="#2D2A3D" stroke-width="1.5" fill="none" stroke-linecap="round"/>

      $eyes

      <!-- Focinho coração rosa -->
      <path d="M 32 27 Q 30 26 30 28 Q 30 30 32 31 Q 34 30 34 28 Q 34 26 32 27 Z" fill="#FFB6C1"/>
      <!-- Brilho no nariz -->
      <ellipse cx="31" cy="27.5" rx="0.8" ry="0.5" fill="#FFFFFF" opacity="0.5"/>

      <!-- Boquinha kawaii ω -->
      <path d="M 28 32 Q 30 34 32 32 Q 34 34 36 32" stroke="#FFB6C1" stroke-width="1.5" fill="none" stroke-linecap="round"/>

      <!-- Bigodes FLUFFY -->
      <line x1="6" y1="22" x2="17" y2="21" stroke="#B7B2D6" stroke-width="1" opacity="0.9"/>
      <line x1="5" y1="26" x2="17" y2="25" stroke="#B7B2D6" stroke-width="1" opacity="0.9"/>
      <line x1="7" y1="30" x2="17" y2="28" stroke="#B7B2D6" stroke-width="0.8" opacity="0.7"/>
      <line x1="47" y1="21" x2="58" y2="22" stroke="#B7B2D6" stroke-width="1" opacity="0.9"/>
      <line x1="47" y1="25" x2="59" y2="26" stroke="#B7B2D6" stroke-width="1" opacity="0.9"/>
      <line x1="47" y1="28" x2="57" y2="30" stroke="#B7B2D6" stroke-width="0.8" opacity="0.7"/>

      <!-- Patinhas REDONDAS e fofas -->
      <ellipse cx="24" cy="54" rx="6" ry="5" fill="#0B0A16"/>
      <ellipse cx="40" cy="54" rx="6" ry="5" fill="#0B0A16"/>

      <!-- Almofadinhas rosadas com brilho -->
      <ellipse cx="24" cy="55" rx="3" ry="2.5" fill="#FFB6C1"/>
      <circle cx="22" cy="53" r="1.2" fill="#FFB6C1" opacity="0.8"/>
      <circle cx="26" cy="53" r="1.2" fill="#FFB6C1" opacity="0.8"/>
      <circle cx="24" cy="51" r="1" fill="#FFB6C1" opacity="0.7"/>
      <ellipse cx="40" cy="55" rx="3" ry="2.5" fill="#FFB6C1"/>
      <circle cx="38" cy="53" r="1.2" fill="#FFB6C1" opacity="0.8"/>
      <circle cx="42" cy="53" r="1.2" fill="#FFB6C1" opacity="0.8"/>
      <circle cx="40" cy="51" r="1" fill="#FFB6C1" opacity="0.7"/>
      <!-- Brilho nas almofadinhas -->
      <circle cx="23" cy="54" r="0.5" fill="#FFFFFF" opacity="0.5"/>
      <circle cx="39" cy="54" r="0.5" fill="#FFFFFF" opacity="0.5"/>

      <!-- Coleira mágica brilhante -->
      <ellipse cx="32" cy="36" rx="12" ry="2.5" fill="#C9A7FF" filter="url(#softGlow)"/>
      <!-- Sininho/pingente mágico -->
      <circle cx="32" cy="38" r="3.5" fill="#FFE8A3"/>
      <circle cx="32" cy="38" r="2.5" fill="#FFF4D1"/>
      <!-- Estrela no pingente -->
      <path d="M 32 36.5 L 32.8 37.5 L 34 37.5 L 33 38.3 L 33.4 39.5 L 32 38.8 L 30.6 39.5 L 31 38.3 L 30 37.5 L 31.2 37.5 Z" fill="#E8C77A"/>
      <!-- Brilho no pingente -->
      <circle cx="31" cy="37" r="0.8" fill="#FFFFFF" opacity="0.7"/>

      <!-- Pelinhos fofos extras -->
      <path d="M 26 8 Q 28 6 30 8" stroke="#2D2A3D" stroke-width="1" fill="none" opacity="0.3"/>
      <path d="M 34 8 Q 36 6 38 8" stroke="#2D2A3D" stroke-width="1" fill="none" opacity="0.3"/>

      <!-- Estrelinhas mágicas ao redor -->
      <text x="8" y="12" font-size="6" fill="#FFE8A3" opacity="0.8">✦</text>
      <text x="52" y="8" font-size="5" fill="#C9A7FF" opacity="0.7">✧</text>
      <text x="56" y="50" font-size="4" fill="#FFE8A3" opacity="0.6">✦</text>
    </svg>
  ''';
}
