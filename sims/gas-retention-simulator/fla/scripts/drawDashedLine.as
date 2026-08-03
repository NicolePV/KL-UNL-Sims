MovieClip.prototype.drawDashedLine = function(startX, startY, endX, endY, dashLength, gapLength)
{
   var dx = endX - startX;
   var dy = endY - startY;
   var length = Math.sqrt(dx * dx + dy * dy);
   var n = Math.round((length - dashLength) / (dashLength + gapLength));
   var f = dashLength / (dashLength + gapLength);
   var mx = dx / (n + f);
   var my = dy / (n + f);
   var lx = f * mx;
   var ly = f * my;
   var i = 0;
   while(i <= n)
   {
      var x = startX + i * mx;
      var y = startY + i * my;
      this.moveTo(x,y);
      this.lineTo(x + lx,y + ly);
      i++;
   }
};
