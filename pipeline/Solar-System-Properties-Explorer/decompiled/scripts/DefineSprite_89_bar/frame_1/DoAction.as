myBar.onRollOver = function()
{
   myBar.myColor._visible = false;
   value._visible = true;
};
myBar.onRelease = myBar.onReleaseOutside = myBar.onRollOut = function()
{
   myBar.myColor._visible = true;
   value._visible = false;
};
