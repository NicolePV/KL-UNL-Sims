function onLabelOrbitsChanged()
{
   diagramMC.setShowOrbitLabels(labelOrbitsCheck.getValue());
}
function showElongationAngleChanged()
{
   diagramMC.setShowElongationAngle(showElongationAngleCheck.getValue());
}
function onSnapToEventsChanged()
{
   diagramMC.snapToEvents = snapToEventsCheck.getValue();
}
