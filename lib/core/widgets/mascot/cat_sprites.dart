enum CatPose {
  sitNeutral,
  sitHappy,
  sitAngry,
  sitBlink,
  sitTailLeft,
  sitTailRight,
  lieRelaxed,
  sleep,
}

class MysticCatSprites {
  static String getSvg(CatPose pose) {
    // --- Configuration ---
    // Colors
    const cBody = "#202020";
    const cEyeWhite = "#FFD700";
    const cPupil = "#000000";
    const cCape = "#6a0dad";
    const cCheek = "#ffb6c1";
    
    // --- Paths (Copied from React Component) ---
    // Tails
    const tailSitNeutral = "M320 380 C 370 380, 440 320, 430 250 C 425 230, 405 230, 410 250";
    const tailSitLeft    = "M320 380 C 350 380, 420 350, 410 260 C 405 240, 390 240, 395 260";
    const tailSitRight   = "M320 380 C 380 380, 480 350, 460 280 C 450 250, 430 250, 440 280";
    const tailAngry      = "M320 380 C 370 380, 420 320, 420 260 C 420 240, 400 240, 400 260";
    const tailLying      = "M350 420 C 420 420, 460 380, 450 340 C 445 320, 425 320, 430 340";

    // Capes
    const capeSit = "M 190 290 Q 130 360 120 450 L 380 450 Q 370 360 310 290 Z";
    const capeLie = "M 150 400 Q 250 350 350 400 L 370 450 L 130 450 Z";

    // --- Logic Selection ---
    String tailPath;
    String capePath;
    String bodyShape; // rect or ellipse definition
    String headTransform;
    String paws;
    String collar;
    String faceContent;
    String sleepPendant = ""; // Layered on top

    // Defaults
    capePath = capeSit;
    bodyShape = '<ellipse cx="250" cy="380" rx="90" ry="80" fill="$cBody" />';
    headTransform = "translate(0, 0)";
    paws = '<g><ellipse cx="210" cy="450" rx="25" ry="15" fill="$cBody" /><ellipse cx="290" cy="450" rx="25" ry="15" fill="$cBody" /></g>';
    
    // Collar Standard
    collar = '''
      <g>
        <path d="M 200 290 Q 250 320 300 290" stroke="$cCape" stroke-width="20" fill="none" stroke-linecap="round" />
        <path d="M 250 300 A 14 14 0 1 1 242 325 A 11 11 0 1 0 250 300" fill="$cEyeWhite" transform="translate(0, 5) rotate(-10, 250, 315)" />
      </g>
    ''';

    // Eyes Standard (Neutral/Happy/Tail)
    final eyeStandard = '''
      <g>
        <ellipse cx="210" cy="220" rx="25" ry="30" fill="$cEyeWhite" />
        <ellipse cx="210" cy="220" rx="9" ry="21" fill="$cPupil" />
        <ellipse cx="290" cy="220" rx="25" ry="30" fill="$cEyeWhite" />
        <ellipse cx="290" cy="220" rx="9" ry="21" fill="$cPupil" />
        <circle cx="218" cy="210" r="5" fill="white" opacity="0.6"/>
        <circle cx="298" cy="210" r="5" fill="white" opacity="0.6"/>
      </g>
    ''';

    // Mouth Standard (W shape) - Used for Happy
    final mouthStandard = '''
      <g>
        <path d="M250 265 Q 240 280 230 270" stroke="#666" stroke-width="3" fill="none" stroke-linecap="round" />
        <path d="M250 265 Q 260 280 270 270" stroke="#666" stroke-width="3" fill="none" stroke-linecap="round" />
      </g>
    ''';

    // Mouth Cute (:3 shape) - Used for Neutral
    final mouthCute = '''
      <g transform="translate(0, 5)">
         <path d="M 235 265 Q 250 265 250 275 Q 250 265 265 265" stroke="#666" stroke-width="3" fill="none" stroke-linecap="round" />
      </g>
    ''';

    switch (pose) {
      case CatPose.sitNeutral:
        tailPath = tailSitNeutral;
        faceContent = eyeStandard + mouthCute;
        break;
      
      case CatPose.sitHappy:
        tailPath = tailSitNeutral;
        faceContent = eyeStandard + mouthStandard;
        break;

      case CatPose.sitTailLeft:
        tailPath = tailSitLeft;
        faceContent = eyeStandard + mouthCute;
        break;

      case CatPose.sitTailRight:
        tailPath = tailSitRight;
        faceContent = eyeStandard + mouthCute;
        break;

      case CatPose.sitBlink:
        tailPath = tailSitNeutral;
        faceContent = '''
          <g stroke="#202020" stroke-width="4" fill="none" stroke-linecap="round">
             <path d="M 185 220 Q 210 235 235 220" />
             <path d="M 265 220 Q 290 235 315 220" />
          </g>
        ''' + mouthCute;
        break;

      case CatPose.sitAngry:
        tailPath = tailAngry;
        faceContent = '''
         <g>
            <ellipse cx="210" cy="220" rx="25" ry="30" fill="$cEyeWhite" />
            <ellipse cx="210" cy="220" rx="8" ry="20" fill="$cPupil" />
            <ellipse cx="290" cy="220" rx="25" ry="30" fill="$cEyeWhite" />
            <ellipse cx="290" cy="220" rx="8" ry="20" fill="$cPupil" />
            <circle cx="218" cy="210" r="5" fill="white" opacity="0.6"/>
            <circle cx="298" cy="210" r="5" fill="white" opacity="0.6"/>
            <path d="M 170 200 L 250 225 L 250 180 L 170 180 Z" fill="#202020" /> 
            <path d="M 330 200 L 250 225 L 250 180 L 330 180 Z" fill="#202020" />
         </g>
         <path d="M 235 280 Q 250 265 265 280" stroke="#666" stroke-width="3" fill="none" stroke-linecap="round" />
        ''';
        break;

      case CatPose.lieRelaxed:
        tailPath = tailLying;
        capePath = capeLie;
        bodyShape = '<ellipse cx="250" cy="410" rx="110" ry="60" fill="$cBody" />';
        headTransform = "translate(0, 70)";
        paws = '<g><ellipse cx="200" cy="450" rx="30" ry="15" fill="$cBody" /><ellipse cx="300" cy="450" rx="30" ry="15" fill="$cBody" /></g>';
        // Narrow collar logic
        collar = '''
          <g> 
            <path d="M 195 385 Q 250 420 305 385" stroke="$cCape" stroke-width="18" fill="none" stroke-linecap="round" />
            <path d="M 250 405 A 12 12 0 1 1 245 425 A 10 10 0 1 0 250 405" fill="$cEyeWhite" transform="translate(-2, 5)" />
          </g>
        ''';
        faceContent = eyeStandard + mouthStandard;
        break;

      case CatPose.sleep:
        tailPath = tailLying;
        capePath = capeLie;
        bodyShape = '<ellipse cx="250" cy="410" rx="110" ry="60" fill="$cBody" />';
        headTransform = "translate(0, 130)";
        paws = '<g><ellipse cx="200" cy="450" rx="30" ry="15" fill="$cBody" /><ellipse cx="300" cy="450" rx="30" ry="15" fill="$cBody" /></g>';
        collar = ""; // Hidden under chin
        // Pendant on top layer
        sleepPendant = '''
         <g transform="translate(0, 5)">
            <path d="M 220 445 Q 250 455 280 445" stroke="$cCape" stroke-width="12" fill="none" stroke-linecap="round" />
            <path d="M 250 445 A 12 12 0 1 1 245 465 A 10 10 0 1 0 250 445" fill="$cEyeWhite" transform="translate(-2, 0)" />
         </g>
        ''';
        faceContent = '''
          <g stroke="#202020" stroke-width="4" fill="none" stroke-linecap="round">
             <path d="M 185 220 Q 210 235 235 220" />
             <path d="M 265 220 Q 290 235 315 220" />
          </g>
          ''' + mouthCute;
        break;
    }

    return '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <!-- TAIL -->
  <path d="$tailPath" fill="none" stroke="#202020" stroke-width="35" stroke-linecap="round" />

  <!-- CAPE BACK -->
  <path d="$capePath" fill="$cCape" />
  
  <!-- BODY -->
  $bodyShape

  <!-- PAWS -->
  $paws

  <!-- COLLAR (Standard Layer) -->
  $collar

  <!-- HEAD GROUP -->
  <g transform="$headTransform">
    <!-- Head Shape -->
    <ellipse cx="250" cy="220" rx="100" ry="85" fill="$cBody" />

    <!-- Ears -->
    <path d="M170 180 L 160 100 L 220 150 Z" fill="$cBody" />
    <path d="M175 170 L 170 120 L 205 155 Z" fill="$cCheek" />
    <path d="M330 180 L 340 100 L 280 150 Z" fill="$cBody" />
    <path d="M325 170 L 330 120 L 295 155 Z" fill="$cCheek" />

    <!-- Face -->
    $faceContent
    <ellipse cx="250" cy="260" rx="8" ry="5" fill="$cCheek" />

    <!-- Whiskers -->
    <g stroke="#888" stroke-width="2" opacity="0.6">
        <line x1="180" y1="260" x2="140" y2="250" />
        <line x1="180" y1="270" x2="140" y2="275" />
        <line x1="320" y1="260" x2="360" y2="250" />
        <line x1="320" y1="270" x2="360" y2="275" />
    </g>
  </g>

  <!-- SLEEP PENDANT (Top Layer) -->
  $sleepPendant
</svg>
    ''';
  }
}
