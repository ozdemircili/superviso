class Dashing.Area extends Dashing.Widget

  createChart: (series, color) ->
    container = $(@node).find('.area-container')
    if $(container)[0]
      @chart = new Highcharts.Chart(
        
        chart:
          renderTo: $(container)[0]
          backgroundColor: null
          marginTop: 0
          type: "area"

        series: series

        title:
          text: ''

        tooltip:
          pointFormat: '{series.name} Total: <b>{point.y}</b>'

        xAxis:
          type: 'datetime'

        plotOptions:
          spline:
            lineWidth: 4
            states:
              hover:
                lineWidth: 5
            marker:
              enabled: false
            pointInterval: 3600000

        navigation:
          buttonOptions:
            verticalAlign: 'top'
            y: -15
            theme:
              'stroke-width': 1
              stroke: color
              r: 0
              fill: color
              states:
                hover:
                  fill: color
                select:
                  fill: color

        series: series
      )

  ready: ->
    @createChart(@get("series"), @get("color"))
  
  onData: (data) ->
    @createChart(data.series, data.color)
