ptolemaic.setOrbitalParameters({scaleFactor:2.5,dR:60,eR:39.5,e:6,a0:327,k0:3.5,A:106.67,P:1.881});
onEnterFrame = function()
{
   time += stepSizeSlider.value;
   ptolemaic.setTime(time);
   sunOrbit.setTime(time);
};
