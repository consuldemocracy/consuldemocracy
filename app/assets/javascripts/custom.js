// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consul/consul/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consul/consul/blob/master/CUSTOMIZE_ES.md#javascript
//
//

function jsProblemChanged(){
  var selected = $("#select-problem option:selected").text();
  if (selected != 'Blank'){
    document.getElementById("problem-hidden").style.display = "none";
    document.getElementById("problem-display").style.display = "block";
    console.log('Se ha seleccionado crear el problema');
  } else {
    document.getElementById("problem-hidden").style.display = "block";
    document.getElementById("problem-display").style.display = "none";
    console.log('Se ha seleccionado un problema conocido');
  }
}
