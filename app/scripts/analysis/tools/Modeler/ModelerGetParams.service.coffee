'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class GetParams extends BaseService

  initialize: ->
    @distanceFromMean = 5

  extract: (data, variable) ->
    tmp = []
    for d in data
      tmp.push +d[variable]
    tmp

  getRightBound: (middle,step) ->
    middle + step * @distanceFromMean

  getLeftBound: (middle,step) ->
    middle - step * @distanceFromMean

  sort: (values) ->
    values.sort (a, b) -> a-b

  getVariance: (values, mean) ->
    temp = 0
    numberOfValues = values.length
    while( numberOfValues--)
      temp += Math.pow( (values[numberOfValues ] - mean), 2 )

    return temp / values.length

  getSum: (values) ->
    values.reduce (previousValue, currentValue) -> previousValue + currentValue

  getGaussianFunctionPoints: (std, mean, variance, leftBound, rightBound) ->
    data = []
    for i in [leftBound...rightBound] by 1
      data.push
        x: i
        y:(1 / (std * Math.sqrt(Math.PI * 2))) * Math.exp(-(Math.pow(i - mean, 2) / (2 * variance)))
    console.log(data)
    data

  getMedian = (values)=>
    values.sort  (a,b)=> return a - b
    half = Math.floor values.length/2
    if values.length % 2
      return values[half]
    else
      return (values[half-1] + values[half]) / 2.0


  getMean: (valueSum, numberOfOccurrences) ->
    valueSum / numberOfOccurrences

  getZ: (x, mean, standardDerivation) ->
    (x - mean) / standardDerivation

  getWeightedValues: (values) ->
    weightedValues= {}
    data= []
    lengthValues = values.length
    for i in [0...lengthValues] by 1
      label = values[i].toString()
      if(weightedValues[label])
        weightedValues[label].weight++
      else
        weightedValues[label]={weight :1,value :label}
        data.push(weightedValues[label])
    return data

  getRandomNumber: (min,max) ->
    Math.round((max-min) * Math.random() + min)

  getRandomValueArray: (data) ->
    values = []
    length = data.length
    for i in [1...length]
      values.push data[Math.floor(Math.random() * data.length)]
    return values


  getParams:(data) ->
    data = data.dataPoints
    data = data.map (row) ->
      x: row[0]
      y: row[1]
      z: row[2]

    console.log @extract(data, "x")
    console.log("Within the modeler GetParams")
    sample = @sort(@getRandomValueArray(@extract(data,"x")))
    sum = @getSum(sample)
    min = sample[0]
    max = sample[sample.length - 1]
    mean = @getMean(sum, sample.length)


    median = getMedian(sample)
    console.log("Sample mean: " + mean)
    variance = @getVariance(sample, mean)
    standardDerivation =  Math.sqrt(variance)
    rightBound = @getRightBound(mean, standardDerivation)
    leftBound = @getLeftBound(mean,standardDerivation)
    bottomBound = 0
    topBound = 1 / (standardDerivation * Math.sqrt(Math.PI * 2))
    gaussianCurveData = @getGaussianFunctionPoints(standardDerivation,mean,variance,leftBound,rightBound)
    radiusCoef = 5


    mean = mean.toFixed(2)
    variance = variance.toFixed(2)
    median = median.toFixed(2)
    standardDerivation = standardDerivation.toFixed(2)

    return stats =
      mean: mean
      variance: variance
      median: median
      standardDev: standardDerivation




  drawNormalCurve: (data, width, height, _graph) ->

    toolTipElement = _graph.append('div')
      .attr('class', 'tooltipGauss')
      .attr('position', 'absolute')
      .attr('width', 15)
      .attr('height', 10)

    showToolTip: (value, positionX, positionY) ->
      toolTipElement.style('display', 'block')
      toolTipElement.style('top', positionY+10+"px")
      toolTipElement.style('left', positionX+10+"px")
      toolTipElement.innerHTML = " Z = "+value

    hideToolTip: () ->
      toolTipElement.style('display', 'none')
      toolTipElement.innerHTML = " "

    console.log @extract(data, "x")
    console.log("Within the modeler GetParams")
    sample = @sort(@getRandomValueArray(@extract(data,"x")))
    sum = @getSum(sample)
    min = sample[0]
    max = sample[sample.length - 1]
    mean = @getMean(sum, sample.length)
    variance = @getVariance(sample, mean)
    standardDerivation =  Math.sqrt(variance)
    rightBound = @getRightBound(mean, standardDerivation)
    leftBound = @getLeftBound(mean,standardDerivation)
    bottomBound = 0
    topBound = 1 / (standardDerivation * Math.sqrt(Math.PI * 2))
    gaussianCurveData = @getGaussianFunctionPoints(standardDerivation,mean,variance,leftBound,rightBound)
    radiusCoef = 5

    padding = 50
    xScale = d3.scale.linear().range([0, width]).domain([leftBound, rightBound])
    yScale = d3.scale.linear().range([height-padding, 0]).domain([bottomBound, topBound])

    xAxis = d3.svg.axis().ticks(20)
      .scale(xScale)

    yAxis = d3.svg.axis()
      .scale(yScale)
      .ticks(12)
      .tickPadding(0)
      .orient("right")

    lineGen = d3.svg.line()
      .x (d) -> xScale(d.x)
      .y (d) -> yScale(d.y)
      .interpolate("basis")

    console.log("printing gaussian curve data")
    console.log(gaussianCurveData)


    _graph.append('svg:path')
      .attr('d', lineGen(gaussianCurveData))
      .data([gaussianCurveData])
      .attr('stroke', 'black')
      .attr('stroke-width', 1.5)
      .on('mousemove', (d) -> showToolTip(getZ(xScale.invert(d3.event.x),mean,standardDerivation).toLocaleString(),d3.event.x,d3.event.y))
      .on('mouseout', (d) -> hideToolTip())
      .attr('fill', "none")

    '''
    _graph.append("svg:g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + (height - padding) + ")")
      .call(xAxis)

    _graph.append("svg:g")
      .attr("class", "y axis")
      .attr("transform", "translate(" + (xScale(mean)) + ",0)")
      .call(yAxis)

    # make x y axis thin
    _graph.selectAll('.x.axis path')
      .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
    _graph.selectAll('.y.axis path')
      .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})


    _graph.append("svg:g")
      .append("text")      #text label for the x axis
      .attr("x", width/2 + width/4  )
      .attr("y", 20  )
      .style("text-anchor", "middle")
      .style("fill", "white")

    # rotate text on x axis
    _graph.selectAll('.x.axis text')
      .attr('transform', (d) ->
      'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
      .style('font-size', '16px')

    # make y axis ticks not intersect with x-axis, ticks on x and y axes
    # appear to be the same size
    _graph.selectAll('.y.axis text')
      .attr('transform', (d) ->
      'translate(' + (this.getBBox().height*-2-5) + ',' + (this.getBBox().height-30) + ')')
      .style('font-size', '15.7px')
    '''





  '''
  kernelDensityEstimator: (kernel, x) ->
    (sample) ->
      x.map (x) ->
      {
        x: x
        y: d3.mean(sample, (v) ->
          kernel x - v
        )
      }
  '''

  getMeanByAccessor: (array, f) ->
    s = 0
    n = array.length
    a = undefined
    i = -1
    j = n
    if f == null
      while ++i < n
        if !isNaN(a = number(array[i]))
          s += a
        else
          --j
    else
      while ++i < n
        if !isNaN(a = number(f(array[i], i, array)))
          s += a
        else
          --j
    if j
      return s / j
    return

  toObject: (arr) ->
    rv = {}
    i = 0
    while i < arr.length
      if arr[i] != undefined
        value = ''
        if i == 0
          value = 'x'
        else
          value = 'y'

        rv[value] = arr[i]
      ++i
    rv

  kernelDensityEstimator: (kernel, x) ->
    (sample) ->
      x.map (x) ->

        mean = d3.mean(sample, (v) ->
          kernel(x - v)
        )

        [
          x
          d3.mean(sample, (v) ->
            kernel x - v
          )
        ]

  epanechnikovKernel: (scale) ->
    (u) ->
      if Math.abs(u /= scale) <= 1 then .75 * (1 - (u * u)) / scale else 0
  '''
  epanechnikovKernel: (u) ->
    if u <= 1 and u >= -1
      return .75 * (1 - (u * u))
    0
  '''

  drawKernelDensityEst: (data, width, height, _graph, xAxis, yAxis, yScale, xScale) ->
    console.log("datafrom kde")
    console.log(data)



    bandwith = 7
    console.log @extract(data, "x")
    console.log("Within the modeler GetParams")
    sample = @sort(@getRandomValueArray(@extract(data,"x")))
    sum = @getSum(sample)
    min = sample[0]
    max = sample[sample.length - 1]
    mean = @getMean(sum, sample.length)
    variance = @getVariance(sample, mean)
    standardDerivation =  Math.sqrt(variance)
    rightBound = @getRightBound(mean, standardDerivation)
    leftBound = @getLeftBound(mean,standardDerivation)
    bottomBound = 0
    topBound = 1 / (standardDerivation * Math.sqrt(Math.PI * 2))
    radiusCoef = 5

    padding = 50

    xScale = d3.scale.linear().domain([leftBound, rightBound]).range([0, width])
    console.log(topBound)
    yScale = d3.scale.linear().domain([bottomBound, topBound]).range([height-padding, padding])
    '''

    x = d3.scale.linear().range([0, width]).domain([leftBound, rightBound])

    xAxis = d3.svg.axis().ticks(20)
      .scale(xScale)

    yAxis = d3.svg.axis()
      .scale(yScale)
      .ticks(12)
      .tickPadding(0)
      .orient("right")

    '''
    lineGen = d3.svg.line()
      .x (d) -> xScale(d.x)
      .y (d) -> yScale(d.y)
      .interpolate("basis")


    kde = @kernelDensityEstimator(@epanechnikovKernel(bandwith), xScale.ticks(100));
    console.log("printing kde(data))")
    data = @extract(data, "x")
    #console.log(kde(data))
    kde_data_array = kde(data)
    kde_data_obj = []
    for i in kde_data_array
      pointObj = @toObject(i)
      kde_data_obj.push(pointObj)



    console.log("Kde_line_data")
    console.log(kde_data_obj)

    #console.log("appending graph")
    '''
    _graph.append('svg:path')
      .datum(kde(data))
      .attr('class', 'line')
      .attr('d', lineGen)
      .attr('stroke', 'black')
      .attr('stroke-width', 1.5)
      .attr('fill', "none")
    #mike bostock way
   _graph.append('svg:path')
      .datum(kde(data))
      .attr("class", "line")
      .attr("d", lineGen);

  '''

    #gaussian way
    _graph.append('svg:path')
      .attr('d', lineGen(kde_data_obj))
      .data([kde_data_obj])
      .attr('stroke', 'black')
      .attr('stroke-width', 1.5)
      .attr('fill', "none")