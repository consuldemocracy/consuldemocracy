// Chart gender
var doughnutDataGender = [
    {
      value: 23038,
      color:"#FF6600",
      highlight: "#fc9550",
      label: "Hombres"
    },
    {
      value: 22244,
      color: "#FF9E01",
      highlight: "#fbc56d",
      label: "Mujeres"
    },
  ];


var load_charts = function(){
  var sex = document.getElementById("sps-chart-gender").getContext("2d");
  window.myDoughnut = new Chart(sex).Doughnut(doughnutDataGender, {responsive : true});
};

$(function(){
  $(document).ready(load_charts);
  $(document).on('page:load', load_charts);
  $(document).on('ajax:complete', load_charts);
});
