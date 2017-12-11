'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class MaxwellBoltzman extends BaseService
  @inject 'socrat_analysis_modeler_getParams'
  initialize: () ->
    #@getParams = @socrat_analysis_modeler_getParams
    @calc = @socrat_analysis_modeler_getParams
    @name = 'Maxwell-Boltzman'
    @a = 1


  getName: () ->
    return @name

  pdf: (x, a) ->
    exp = -1* Math.pow(x, 2) / (2* Math.pow(a,2))
    return Math.sqrt(2 / Math.PI) * ((Math.pow(x,2) * Math.pow(Math.E, exp)) / Math.pow(a,3))

  CDF: (x, a) ->
    return @calc.erf(x/(Math.sqrt(2)*2)) - Math.sqrt(2/Math.PI)*x*Math.pow(Math.E,(-1*x*x/(2*a*a)))/a

  getMaxwellBoltzmanDistribution: (leftBound, rightBound, a) ->
    data = []
    for i in [leftBound...rightBound] by .2
      data.push
        x: i
        y: @pdf(i, a)
    data

  getChartData: (params) ->
    curveData = @getMaxwellBoltzmanDistribution(params.xMin, params.xMax, @a)
    return curveData



  getParams: () ->
    params =
      A: @a

  setParams: (newParams) ->
    @a = newParams.stats.A


