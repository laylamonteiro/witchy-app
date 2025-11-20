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
      <path d="M 23 19 Q 25 18 27 19" stroke="#C9A7FF" stroke-width="1.5" fill="none"/>
      <path d="M 37 19 Q 39 18 41 19" stroke="#C9A7FF" stroke-width="1.5" fill="none"/>
    '''
    : '''
      <!-- Olhos abertos grandes e fofos -->
      <ellipse cx="25" cy="19" rx="3.5" ry="4" fill="#FFFFFF"/>
      <ellipse cx="39" cy="19" rx="3.5" ry="4" fill="#FFFFFF"/>
      <!-- Pupilas -->
      <ellipse cx="25.5" cy="19.5" rx="1.8" ry="2.2" fill="#000000"/>
      <ellipse cx="39.5" cy="19.5" rx="1.8" ry="2.2" fill="#000000"/>
      <!-- Brilho nos olhos -->
      <circle cx="24.5" cy="18" r="0.8" fill="#FFFFFF" opacity="0.8"/>
      <circle cx="38.5" cy="18" r="0.8" fill="#FFFFFF" opacity="0.8"/>
    ''';

  return '''
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
      <!-- Sombra -->
      <ellipse cx="32" cy="58" rx="18" ry="4" fill="#C9A7FF" opacity="0.2"/>

      <!-- Rabo fofo e curvo -->
      <path d="M 46 42 Q 54 38 56 28 Q 57 22 54 18"
            stroke="#0B0A16" stroke-width="7" stroke-linecap="round" fill="none"/>
      <path d="M 46 42 Q 54 38 56 28 Q 57 22 54 18"
            stroke="#1A1625" stroke-width="4" stroke-linecap="round" fill="none" opacity="0.3"/>

      <!-- Corpo menos redondo -->
      <ellipse cx="32" cy="42" rx="14" ry="16" fill="#0B0A16"/>

      <!-- Peito mais claro -->
      <ellipse cx="32" cy="42" rx="8" ry="10" fill="#1A1625" opacity="0.3"/>

      <!-- Cabeça mais triangular (formato de gato) -->
      <path d="M 32 8 Q 42 10 45 20 Q 45 28 38 32 Q 32 34 26 32 Q 19 28 19 20 Q 22 10 32 8 Z"
            fill="#0B0A16"/>

      <!-- Orelhas grandes e pontiagudas -->
      <path d="M 22 12 L 18 2 L 26 10 Z" fill="#0B0A16"/>
      <path d="M 42 12 L 46 2 L 38 10 Z" fill="#0B0A16"/>

      <!-- Interior das orelhas rosa -->
      <path d="M 22.5 10 L 20 5 L 24 9 Z" fill="#F1A7C5"/>
      <path d="M 41.5 10 L 44 5 L 40 9 Z" fill="#F1A7C5"/>

      <!-- Pelinho nas orelhas -->
      <path d="M 21 8 L 20 5" stroke="#2D2838" stroke-width="0.5" opacity="0.5"/>
      <path d="M 43 8 L 44 5" stroke="#2D2838" stroke-width="0.5" opacity="0.5"/>

      $eyes

      <!-- Bochechas fofas -->
      <circle cx="19" cy="23" r="3" fill="#1A1625" opacity="0.15"/>
      <circle cx="45" cy="23" r="3" fill="#1A1625" opacity="0.15"/>

      <!-- Focinho mais fofo -->
      <path d="M 32 23 L 30 25 L 32 26.5 L 34 25 Z" fill="#F1A7C5"/>
      <!-- Detalhe no nariz -->
      <line x1="32" y1="23.5" x2="32" y2="25" stroke="#D98BB0" stroke-width="0.5"/>

      <!-- Boca fofinha em W -->
      <path d="M 32 26.5 L 30 28 Q 28 29 26 27.5" stroke="#F1A7C5" stroke-width="1.2" fill="none" stroke-linecap="round"/>
      <path d="M 32 26.5 L 34 28 Q 36 29 38 27.5" stroke="#F1A7C5" stroke-width="1.2" fill="none" stroke-linecap="round"/>

      <!-- Bigodes mais evidentes -->
      <line x1="8" y1="21" x2="18" y2="20" stroke="#B7B2D6" stroke-width="0.7" opacity="0.9"/>
      <line x1="8" y1="24" x2="18" y2="23.5" stroke="#B7B2D6" stroke-width="0.7" opacity="0.9"/>
      <line x1="9" y1="27" x2="18" y2="26" stroke="#B7B2D6" stroke-width="0.6" opacity="0.8"/>
      <line x1="46" y1="20" x2="56" y2="21" stroke="#B7B2D6" stroke-width="0.7" opacity="0.9"/>
      <line x1="46" y1="23.5" x2="56" y2="24" stroke="#B7B2D6" stroke-width="0.7" opacity="0.9"/>
      <line x1="46" y1="26" x2="55" y2="27" stroke="#B7B2D6" stroke-width="0.6" opacity="0.8"/>

      <!-- Patas fofas -->
      <ellipse cx="24" cy="53" rx="5" ry="6" fill="#0B0A16"/>
      <ellipse cx="40" cy="53" rx="5" ry="6" fill="#0B0A16"/>

      <!-- Almofadinhas das patas -->
      <circle cx="24" cy="55" r="1.5" fill="#F1A7C5"/>
      <circle cx="22" cy="54" r="0.8" fill="#F1A7C5" opacity="0.7"/>
      <circle cx="26" cy="54" r="0.8" fill="#F1A7C5" opacity="0.7"/>
      <circle cx="40" cy="55" r="1.5" fill="#F1A7C5"/>
      <circle cx="38" cy="54" r="0.8" fill="#F1A7C5" opacity="0.7"/>
      <circle cx="42" cy="54" r="0.8" fill="#F1A7C5" opacity="0.7"/>

      <!-- Coleira mágica -->
      <ellipse cx="32" cy="34" rx="11" ry="2" fill="#C9A7FF"/>
      <circle cx="32" cy="35" r="2.5" fill="#FFE8A3"/>
      <circle cx="32" cy="35" r="1.5" fill="#FFF4D1"/>
      <!-- Detalhe mágico no pingente -->
      <path d="M 31 34.5 L 32 35.5 L 33 34.5" stroke="#E8C77A" stroke-width="0.5" fill="none"/>
    </svg>
  ''';
}
