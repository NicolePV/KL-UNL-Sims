if(!this.isStandalone && this._object._sys != 1)
{
   this._object.setPosition({x:0,y:0,z:0,system:"celestial"});
   this._object.visible = true;
   this._sphere.updateObjects();
}
this.stop();
