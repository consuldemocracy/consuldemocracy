// Chart sex preselection
var doughnutDataPreselect = [
  {
    value: 4562,
    color:"#FF6600",
    highlight: "#fc9550",
    label: "Hombres"
  },
  {
    value: 3028,
    color: "#FF9E01",
    highlight: "#fbc56d",
    label: "Mujeres"
  },
];

var load_preselection_charts = function(){
  var preselect = document.getElementById("preselection").getContext("2d");
  window.myDoughnut = new Chart(preselect).Doughnut(doughnutDataPreselect, {responsive : true});
};

$(function(){
  $(document).ready(load_preselection_charts);
  $(document).on('page:load', load_preselection_charts);
  $(document).on('ajax:complete', load_preselection_charts);
});
