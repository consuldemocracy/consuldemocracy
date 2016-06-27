// Chart channels
var investmentData = [
    {
      value: 6000,
      color:"#9CC56A",
      highlight: "#b0de78",
      label: "Viables"
    },
    {
      value: 700,
      color: "#E87461",
      highlight: "#ff7f6e",
      label: "Inviables"
    },
  ];

// Chart sex
var doughnutDataSex = [
    {
      value: 16394,
      color:"#FF6600",
      highlight: "#fc9550",
      label: "Hombres"
    },
    {
      value: 10466,
      color: "#FF9E01",
      highlight: "#fbc56d",
      label: "Mujeres"
    },
  ];


var load_charts = function(){
  var totals = document.getElementById("chart-totals").getContext("2d");
  window.myDoughnut = new Chart(totals).Doughnut(investmentData, {responsive : true});

  var sex = document.getElementById("chart-sex").getContext("2d");
  window.myDoughnut = new Chart(sex).Doughnut(doughnutDataSex, {responsive : true});
};

$(function(){
  $(document).ready(load_charts);
  $(document).on('page:load', load_charts);
  $(document).on('ajax:complete', load_charts);
});
