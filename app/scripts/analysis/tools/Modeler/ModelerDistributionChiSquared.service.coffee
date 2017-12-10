'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class ChiSqr extends BaseService
  @inject 'socrat_analysis_modeler_getParams'
  initialize: () ->
#    @getParams = @socrat_analysis_modeler_getParams

    @name = 'ChiSquared'
    @k = 2

  getName: () ->
    return @name

  pdf: (k, x) ->
    return 1/(Math.pow(2, k/2)*@gammaFn(k/2))* Math.pow(x,(k/2-1))*Math.exp(-1*x/2)

  factorial: (x) ->
    t = 1
    while x > 1
      t *= x--
    t

  gammaFn: (x) ->
    console.log("In te chisquared service!!!!!!!!!!")
    return @factorial(x-1)

  #pdf function
  getChiSquaredDistribution: (leftBound, rightBound, k) ->
    data = []
    for i in [leftBound...rightBound] by 0.2
      data.push
        x: i
        y: @pdf(k, i)
    console.log(data)
    data

  # CDF function
  # need to know how to compute the sum from k=0 to k= infinity
  # lower incomplete gamma function

  getChartData: (params) ->
#    if params.stats.k == undefined
#      params.stats.k = 2

    curveData = @getChiSquaredDistribution(params.xMin, params.xMax, @k)
    console.log(curveData)

    return curveData


  getParams: () ->
    params =
      mean: @k

  setParams: (newParams) ->
    @k = newParams.stats.mean