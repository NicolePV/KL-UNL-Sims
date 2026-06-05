  const lSlider = document.getElementById('lRange');
  const lSolar  = document.getElementById('lSolar');
  
  const lNames  = ["Pure Black", "Dark Grey", "Medium-Dark Grey", "Neutral Grey", "Medium-Light Grey ", "Light Grey", "Pure White" ];

  lSlider.addEventListener('input', function() {
    // Map the 0-100 range to 0-6 (7 colors)
    const percentage = this.value / 100;
    const colorIndex = Math.min(Math.floor(percentage * lNames.length), lNames.length - 1);
    const colorName = lNames[colorIndex];

    // Update text and ARIA properties
    //valueDisplay.textContent = "Value: " + colorName;
    lSlider.setAttribute("aria-valuetext", colorName);

    // Set luminosity based on slider position
    const r0 = -4;
    lSolar.value = Math.pow( 10, ( r0 + ( Math.log10(parseFloat(lSolar.max)) - r0 ) * ( parseFloat(lSlider.value) / 100 ) ) ) ;
    newStar(1);
    setTimeout(newStar.bind(null,1), tOff);

  });

