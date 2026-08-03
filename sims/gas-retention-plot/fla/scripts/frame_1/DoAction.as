objectsList = [{name:"Mercury",radius:2439.7,density:5.427,escapeSpeed:4.3,temperature:445},{textAngle:180,name:"Venus",radius:6051,density:5.204,escapeSpeed:10.4,temperature:325},{name:"Earth",radius:6376,density:5.5153,escapeSpeed:11.2,temperature:277},{name:"Moon",radius:1737.1,density:3.3464,escapeSpeed:2.4,temperature:277},{name:"Mars",radius:3390,density:3.934,escapeSpeed:5,temperature:225},{name:"Jupiter",radius:69911,density:1.326,escapeSpeed:59.5,temperature:122},{name:"Saturn",radius:58229,density:0.6873,escapeSpeed:35.5,temperature:90},{textAngle:180,name:"Uranus",radius:25363,density:1.318,escapeSpeed:21.3,temperature:63},{name:"Neptune",radius:24624,density:1.638,escapeSpeed:23.5,temperature:50},{textAngle:180,name:"Pluto",radius:1195,density:2.03,escapeSpeed:1.1,temperature:44},{textAngle:180,name:"Titan",radius:2575,density:1.88,escapeSpeed:2.6,temperature:90},{name:"Ganymede",radius:2631,density:1.942,escapeSpeed:2.7,temperature:122},{name:"Triton",radius:1353.4,density:2.05,escapeSpeed:1.5,temperature:50}];
var i = 0;
while(i < objectsList.length)
{
   var o = objectsList[i];
   var mass = o.density * 1000 * Math.pow(o.radius * 1000,3) * 4 * 3.141592653589793 / 3;
   o.escapeSpeed = Math.sqrt(1.3346e-10 * mass / (o.radius * 1000)) / 1000;
   i++;
}
gassesList = [{color:13369599,name:"xenon",symbol:"Xe",mass:131.293},{color:16763904,name:"carbon dioxide",symbol:"CO<sub>2</sub>",mass:44.0095},{color:10506495,name:"oxygen",symbol:"O<sub>2</sub>",mass:31.9988},{color:65484,name:"nitrogen",symbol:"N<sub>2</sub>",mass:28.0134},{color:20735,name:"water",symbol:"H<sub>2</sub>O",mass:18.01528},{color:16711884,name:"ammonia",symbol:"NH<sub>3</sub>",mass:17.03052},{color:13434624,name:"methane",symbol:"CH<sub>4</sub>",mass:16.04246},{color:65280,name:"helium",symbol:"He",mass:4.002602},{color:16711680,name:"hydrogen",symbol:"H<sub>2</sub>",mass:2.01588}];
