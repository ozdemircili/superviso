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
//= require pusher
//= require dashing
//= require ./application/dashing
//= require_tree ./application/dashing
//= require ./application/highcharts
//= require ./application/highcharts-more
//= require dashing.gridster
//= require dashing_pusher
//= require default_widgets
//= require_tree ./dashing/widgets
window.persistWidgets = function(){};
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
