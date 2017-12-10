'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class LaplaceDist extends BaseService
  @inject 'socrat_analysis_modeler_getParams'
  initialize: () ->
    #@getParams = @socrat_analysis_modeler_getParams

    @name = 'Laplace'
    @LaplaceMean = 0
    @LaplaceScale = 1

  getName: () ->
    return @name

  pdf: (u, b, x) ->
    return (1 / (2*b))*Math.exp(-(Math.abs(x-u)/b))


  getLaplaceDistribution: (leftBound, rightBound, u, b) ->
    data = []
    for i in [leftBound...rightBound] by .2
      data.push
        x: i
        y: @pdf(u, b, i)
    console.log(data)
    data

  CDF: (u, b, x)->
    if x < u
      return 1/(2*b)*Math.exp((x-u)/b)
    else if x >= u
      return 1 - 1/(2*b)*Math.exp((x-u)/b)

  getChartData: (params) ->
    curveData = @getLaplaceDistribution(params.xMin, params.xMax, @LaplaceMean , @LaplaceScale)
    return curveData


  getParams: () ->
    params =
      mean: @LaplaceMean
      scale: @LaplaceScale



  setParams: (newParams) ->
    @LaplaceMean = newParams.stats.mean
    @LaplaceScale = newParams.stats.scale