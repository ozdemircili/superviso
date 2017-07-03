class Dashing.Gauge extends Dashing.Widget

  createChart: (series, suffix, max, color) ->
    container = $(@node).find('.gauge-container')
    if $(container)[0]
      @chart = new Highcharts.Chart(
        
        chart:
          renderTo: $(container)[0]
          backgroundColor: null
          marginTop: 0
          type: "gauge"
          alignTicks: false
          plotBackgroundColor: null
          plotBackgroundImage: null
          plotBorderWidth: 0
          plotShadow: false


        title:
          text: ''

        pane:
            startAngle: -150
            endAngle: 150

        yAxis:[
            min: 0
            max: max || 100
            lineColor: '#339'
            tickColor: '#339'
            minorTickColor: '#339'
            offset: -25
            lineWidth: 2
            labels:
                distance: -20,
                rotation: 'auto'
            tickLength: 5
            minorTickLength: 5
            endOnTick: false
        ]

        series: [
            name: "Speed"
            data: series
            dataLabels:
                formatter: ->
                    return "<span style=\"color:#339\">" + @y + " "+suffix+"</span><br/>"

                backgroundColor:
                    linearGradient:
                        x1: 0
                        y1: 0
                        x2: 0
                        y2: 1

                    stops: [[0, "#DDD"], [1, "#FFF"]]

            tooltip:
                valueSuffix: " km/h"
        ]


      )

  ready: ->
    @createChart(@get("series"), @get("suffix"), @get("max"), @get("color"))
  
  onData: (data) ->
    @createChart(data.series, data.suffix, data.max, data.color)
