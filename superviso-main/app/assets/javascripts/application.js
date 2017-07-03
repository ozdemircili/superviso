// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require application/sparkline
//= require application/highcharts
//= require application/highcharts-more
//= require zeroclipboard
//= require pusher
//= require twitter/bootstrap
// require dashing
//= require_tree ./application
// require jquery_ujs
//= require dashing
//= require dashing_pusher
//= require dashing.gridster
//= require default_widgets
//= require_tree ./dashing/widgets
//

Pusher.log = function(message) {
    if (window.console && window.console.log) {
          window.console.log(message);
            }
};
window.pusher = new Pusher("765ec374ae0a69f4ce44", {
  authEndpoint: '/pusher/auth',
  authTransport: 'ajax',
  enabledTransports: ["ws"],
  disableStats: true,
  wsHost: 'push.superviso.com',
  wsPort: '8080'
});

window.persistWidgets = function(dashboard_id, widgetPosition){
  var index, widget, widgets, _i, _len, _results;
  console.log(dashboard_id, widgetPosition)
  widgets = $(".dashing-widget");
  _result = []
  for (index = _i = 0, _len = widgets.length; _i < _len; index = ++_i) {
    widget = widgets[index];
    console.log($(widget).data("widgetid"))
    _result.push({id: $(widget).data("widgetid"), col: $(widget).data("col"), row: $(widget).data("row")})
    console.log(_result)
  }
  $.ajax( {
    url: currentDashboardUrl,
    method: 'PUT',
    dataType: 'json',
    contentType: 'application/json',
    data: JSON.stringify({dashboard: {widgets_attributes: _result }})
  })
}

$(document).ready(function(){
  new ZeroClipboard($("#copy-link-to-clipboard"))
  $("a#unconfirmed-warning").popover({placement: "bottom", container: "body"})
  $('.sparkline').sparkline([1,4,6,6,8,5,3,5],  {type: "bar", height: "30px", width:"100px", barWidth: "5px", barSpacing: "2px", zeroAxis: false});
  $("#add-widget-button").on("click", function(){
    $("#add-widget-modal").modal()
  }) 
  $("#thumbs > a").on("click", function(){
    $("#add-widget-modal").modal('hide')
  })
})
