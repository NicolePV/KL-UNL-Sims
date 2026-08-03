function setSphereOrientation(newTheta, newPhi)
{
   sphere.setThetaAndPhi(newTheta,newPhi);
   var sp = {};
   sphere.CtoS(centerPoint,sp);
   sphere._x = 325 - sp.x;
   sphere._y = 240 - sp.y;
   drawPatch();
}
function drawPatch()
{
   var mc = sphere.spherePatch;
   mc.clear();
   mc.lineStyle(1,16711680,0);
   mc.beginFill(7179196,60);
   var minStep = sphere.arc1._minStep;
   var cos = Math.cos;
   var sin = Math.sin;
   var ax = cos(sphere.arc1._gS);
   var ay = sin(sphere.arc1._gS);
   var c = sphere.arc1._c;
   mc.moveTo(c.v0 * ax + c.v1 * ay + c.v2,c.v3 * ax + c.v4 * ay + c.v5);
   var k = 1;
   while(k <= 4)
   {
      var thisArc = sphere["arc" + k];
      var c = thisArc._c;
      var g1 = thisArc._gS;
      var g2 = thisArc._gE;
      if(g2 < g1)
      {
         g2 += 6.283185307179586;
      }
      var arc = g2 - g1;
      if(arc == 0)
      {
         arc = 6.283185307179586;
      }
      var n = Math.ceil(arc / minStep);
      var step = arc / n;
      var halfStep = step / 2;
      var cRad = 1 / cos(halfStep);
      var aAngle = g1 + step;
      var cAngle = aAngle - halfStep;
      var i = 0;
      while(i < n)
      {
         var ax = cos(aAngle);
         var ay = sin(aAngle);
         var cx = cRad * cos(cAngle);
         var cy = cRad * sin(cAngle);
         mc.curveTo(c.v0 * cx + c.v1 * cy + c.v2,c.v3 * cx + c.v4 * cy + c.v5,c.v0 * ax + c.v1 * ay + c.v2,c.v3 * ax + c.v4 * ay + c.v5);
         aAngle += step;
         cAngle += step;
         i++;
      }
      k++;
   }
   mc.endFill();
}
sphere.createEmptyMovieClip("spherePatch",-10);
centerPoint = {};
sphere.parsePointInput({ra:12.5,dec:55,r:0.5},centerPoint);
