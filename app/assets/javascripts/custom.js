// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consul/consul/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consul/consul/blob/master/CUSTOMIZE_ES.md#javascript
//
//

function jsProblemChanged(){
  var selected = $("#select-problem option:selected").val();
  if (selected != ''){
    document.getElementById("problem-hidden").style.display = "none";
    document.getElementById("problem-display").style.display = "block";
    console.log(selected);
  } else {
    document.getElementById("problem-hidden").style.display = "block";
    document.getElementById("problem-display").style.display = "none";
    console.log(selected);
  }
}
