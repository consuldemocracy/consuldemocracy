// Chart sex total stats
var doughnutDataStats = [
  {
    value: 18944,
    color:"#FF6600",
    highlight: "#fc9550",
    label: "Hombres"
  },
  {
    value: 12686,
    color: "#FF9E01",
    highlight: "#fbc56d",
    label: "Mujeres"
  },
];

var load_stats_charts = function(){
  var stats = document.getElementById("stats").getContext("2d");
  window.myDoughnut = new Chart(stats).Doughnut(doughnutDataStats, {responsive : true});
};

$(function(){
  $(document).ready(load_stats_charts);
  $(document).on('page:load', load_stats_charts);
  $(document).on('ajax:complete', load_stats_charts);
});
