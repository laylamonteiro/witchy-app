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

// Gatinho sentado (pose padrão)
String _getSittingCat(bool isBlinking) {
  final eyes = isBlinking
    ? '''
      <!-- Olhos fechados -->
      <path d="M 18 20 Q 20 19 22 20" stroke="#C9A7FF" stroke-width="1.5" fill="none"/>
      <path d="M 42 20 Q 44 19 46 20" stroke="#C9A7FF" stroke-width="1.5" fill="none"/>
    '''
    : '''
      <!-- Olhos abertos -->
      <circle cx="20" cy="20" r="3" fill="#C9A7FF"/>
      <circle cx="44" cy="20" r="3" fill="#C9A7FF"/>
      <circle cx="21" cy="20" r="1.5" fill="#000000"/>
      <circle cx="45" cy="20" r="1.5" fill="#000000"/>
    ''';

  return '''
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
      <!-- Sombra -->
      <ellipse cx="32" cy="58" rx="18" ry="4" fill="#C9A7FF" opacity="0.2"/>

      <!-- Rabo -->
      <path d="M 45 40 Q 52 35 54 25 Q 55 20 52 18"
            stroke="#0B0A16" stroke-width="8" stroke-linecap="round" fill="none"/>

      <!-- Corpo -->
      <ellipse cx="32" cy="40" rx="16" ry="18" fill="#0B0A16"/>

      <!-- Cabeça -->
      <circle cx="32" cy="22" r="14" fill="#0B0A16"/>

      <!-- Orelhas -->
      <path d="M 20 15 L 18 8 L 24 12 Z" fill="#0B0A16"/>
      <path d="M 44 15 L 46 8 L 40 12 Z" fill="#0B0A16"/>

      <!-- Interior das orelhas -->
      <path d="M 20.5 12 L 19.5 9 L 22 11 Z" fill="#F1A7C5"/>
      <path d="M 43.5 12 L 44.5 9 L 42 11 Z" fill="#F1A7C5"/>

      $eyes

      <!-- Focinho -->
      <path d="M 32 24 L 30 26 L 32 27 L 34 26 Z" fill="#F1A7C5"/>

      <!-- Boca -->
      <path d="M 32 27 Q 29 29 26 27" stroke="#F1A7C5" stroke-width="1" fill="none"/>
      <path d="M 32 27 Q 35 29 38 27" stroke="#F1A7C5" stroke-width="1" fill="none"/>

      <!-- Bigodes -->
      <line x1="10" y1="22" x2="18" y2="21" stroke="#B7B2D6" stroke-width="0.5"/>
      <line x1="10" y1="25" x2="18" y2="24" stroke="#B7B2D6" stroke-width="0.5"/>
      <line x1="46" y1="21" x2="54" y2="22" stroke="#B7B2D6" stroke-width="0.5"/>
      <line x1="46" y1="24" x2="54" y2="25" stroke="#B7B2D6" stroke-width="0.5"/>

      <!-- Patas -->
      <ellipse cx="24" cy="52" rx="5" ry="7" fill="#0B0A16"/>
      <ellipse cx="40" cy="52" rx="5" ry="7" fill="#0B0A16"/>

      <!-- Almofadinhas -->
      <ellipse cx="24" cy="55" rx="2" ry="1.5" fill="#F1A7C5"/>
      <ellipse cx="40" cy="55" rx="2" ry="1.5" fill="#F1A7C5"/>

      <!-- Coleira mágica -->
      <ellipse cx="32" cy="32" rx="12" ry="2" fill="#C9A7FF"/>
      <circle cx="32" cy="33" r="2" fill="#FFE8A3"/>
    </svg>
  ''';
}
