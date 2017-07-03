class Dashing.Speedometer extends Dashing.Widget

  createChart: (series, suffix, max, color) ->
    container = $(@node).find('.speedometer-container')
    if $(container)[0]
      @chart = new Highcharts.Chart(
        
        chart:
          renderTo: $(container)[0]
          backgroundColor: null
          marginTop: 0
          type: "gauge"
          plotBackgroundColor: null
          plotBackgroundImage: null
          plotBorderWidth: 0
          plotShadow: false


        title:
          text: ''

        pane:
            startAngle: -150
            endAngle: 150
            background: [
                backgroundColor:
                    linearGradient:
                        x1: 0
                        y1: 0
                        x2: 0
                        y2: 1

                    stops: [[0, "#FFF"], [1, "#333"]]

                borderWidth: 0
                outerRadius: "109%"
            ,
                backgroundColor:
                    linearGradient:
                        x1: 0
                        y1: 0
                        x2: 0
                        y2: 1

                    stops: [[0, "#333"], [1, "#FFF"]]

                borderWidth: 1
                outerRadius: "107%"
            , {},
    
                backgroundColor: "#DDD"
                borderWidth: 0
                outerRadius: "105%"
                innerRadius: "103%"
            ]

        yAxis:[
            min: 0
            max: max || 200
            minorTickInterval: "auto"
            minorTickWidth: 1
            minorTickLength: 10
            minorTickPosition: "inside"
            minorTickColor: "#666"
            tickPixelInterval: 30
            tickWidth: 2
            tickPosition: "inside"
            tickLength: 10
            tickColor: "#666"
            labels:
              step: 2
              rotation: "auto"
            
            title:
              text: suffix
            
            plotBands: [
              from: 0
              to: 120
              color: "#55BF3B" # green
            ,
              from: 120
              to: 160
              color: "#DDDF0D" # yellow
            ,
              from: 160
              to: 200
              color: "#DF5353" # red
            ]
        ]

        series: [
            name: "Speed"
            data: series
            tooltip:
                valueSuffix: suffix
        ]


      )

  ready: ->
    @createChart(@get("series"), @get("suffix"), @get("max"), @get("color"))
  
  onData: (data) ->
    @createChart(data.series, data.suffix, data.max, data.color)