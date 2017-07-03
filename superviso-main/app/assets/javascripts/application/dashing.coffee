window.initDashing = (dashboard_id, pusher_channel) ->
  console.log("Yeah! The dashboard has started!")
  Dashing.on 'ready', ->
    Dashing.widget_margins ||= [5, 5]
    Dashing.widget_base_dimensions ||= [300, 360]
    Dashing.numColumns ||= 4
  
    contentWidth = (Dashing.widget_base_dimensions[0] + Dashing.widget_margins[0] * 2) * Dashing.numColumns
    window.dashingSubscribe(pusher_channel)

    Batman.setImmediate ->
      $('.gridster').width(contentWidth)
      $('.gridster ul:first').gridster
        widget_margins: Dashing.widget_margins
        widget_base_dimensions: Dashing.widget_base_dimensions
        avoid_overlapped_widgets: true #!Dashing.customGridsterLayout
        draggable:
          stop: -> 
            persistWidgets(dashboard_id, Dashing.getWidgetPositions())
            #Dashing.showGridsterInstructions
          start: -> Dashing.currentWidgetPositions = Dashing.getWidgetPositions()
