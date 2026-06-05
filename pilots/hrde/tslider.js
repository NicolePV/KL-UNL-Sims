  const tSlider = document.getElementById('tRange');
  const tKelvin = document.getElementById('tKelvin');

  const tNames  = ["Red", "Orange", "Yellow", "Yellow-white", "White-blue", "Ice-blue", "Blue" ];

  tSlider.addEventListener('input', function() {
    // Map the 0-100 range to 0-6 (7 colors)
    const percentage = this.value / 100;
    const colorIndex = Math.min(Math.floor(percentage * tNames.length), tNames.length - 1);
    const colorName  = tNames[colorIndex];

    // Update text and ARIA properties
    //valueDisplay.textContent = "Value: " + colorName;
    tSlider.setAttribute("aria-valuetext", colorName);

    // Set temperature based on slider position
    tKelvin.value = parseFloat(tKelvin.min) + ( parseFloat(tKelvin.max) - parseFloat(tKelvin.min) ) * ( parseFloat(tSlider.value) / 100 );
    newStar(1);
    setTimeout(newStar.bind(null,1), tOff);

  });

