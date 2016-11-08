// Chart channels
var doughnutData = [
  {
    value: 19124,
    color:"#00ad51",
    highlight: "#66ce97",
    label: "Web"
  },
  {
    value: 7605,
    color: "#007dc3",
    highlight: "#66b1db",
    label: "010"
  },
  {
    value: 232,
    color: "#ffdc08",
    highlight: "#ffea6b",
    label: "Papel"
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
  var channels = document.getElementById("chart-channels").getContext("2d");
  window.myDoughnut = new Chart(channels).Doughnut(doughnutData, {responsive : true});

  var sex = document.getElementById("chart-sex").getContext("2d");
  window.myDoughnut = new Chart(sex).Doughnut(doughnutDataSex, {responsive : true});
};

$(function(){
  $(document).ready(load_charts);
  $(document).on('page:load', load_charts);
  $(document).on('ajax:complete', load_charts);
});
