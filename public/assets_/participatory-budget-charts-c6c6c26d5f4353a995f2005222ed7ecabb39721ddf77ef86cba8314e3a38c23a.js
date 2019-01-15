// Chart sex
var load_charts = function(){
  var sex = document.getElementById("sps-chart-sex").getContext("2d");

  var doughnutDataSex = [
    {
      value: $("#sps-chart-sex").data('malescount'),
      color:"#FF6600",
      highlight: "#fc9550",
      label: $("#sps-chart-sex").data('maleslabel')
    },
    {
      value: $("#sps-chart-sex").data('femalescount'),
      color: "#FF9E01",
      highlight: "#fbc56d",
      label: $("#sps-chart-sex").data('femaleslabel')
    },
  ];

  window.myDoughnut = new Chart(sex).Doughnut(doughnutDataSex, {responsive : true});
};

$(function(){
  $(document).ready(load_charts);
  $(document).on('page:load', load_charts);
  $(document).on('ajax:complete', load_charts);
});
