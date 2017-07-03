/*
 * dashing_pusher.js
 * Copyright (C) 2013 diego <diego@diego-ThinkPad-W530>
 *
 * Distributed under terms of the MIT license.
 */

function dashingSubscribe(channel_name){

  var channel = pusher.subscribe(channel_name);
  channel.bind('pusher:subscription_succeeded', function() {
    console.log("Connection Succeded");
    channel.bind("update", function(data){
      console.log(data)
      Dashing.lastEvents[data.id] = data
      if(Dashing.widgets[data.id]!=undefined && Dashing.widgets[data.id].length > 0){
        $.each(Dashing.widgets[data.id], function(index, widget){
          widget.receiveData(data)
        });
      }
    })
  });
}

