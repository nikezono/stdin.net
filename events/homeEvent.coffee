###

  HomeEvent.coffee

###

module.exports.HomeEvent = (app) ->

  index: (req,res,next)->
    res.render "index"

