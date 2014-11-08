###

  routes.coffee
  httpリクエスト用ルーティング設定ファイル

###

module.exports = (app) ->

  # include events
  HomeEvent   = app.get('events').HomeEvent app
  FeedEvent   = app.get('events').FeedEvent app
  PageEvent   = app.get('events').PageEvent app

  # homeEvent Controller
  app.get  '/',                    (req,res,next)-> HomeEvent.index   req,res,next

  # FeedEvent Controller
  app.get  '/api/feed/find',       (req,res,next)-> FeedEvent.findFeed req,res,next
  app.post '/api/feed/subscribe',  (req,res,next)-> FeedEvent.subscribe req,res,next

  # PageEvent Controller
  app.get  '/api/page/list',       (req,res,next)-> PageEvent.getPageList req,res,next
  app.get  '/api/page/stream',     (req,res,next)-> PageEvent.getPageStream req,res,next
  app.get  '/api/page/latest',     (req,res,next)-> PageEvent.getLatestPages req,res,next
  app.get  '/api/page/:id/similar',(req,res,next)-> PageEvent.getSimilarPages req,res,next
  app.get  '/api/page/:id',        (req,res,next)-> PageEvent.getPageWithId req,res,next

  # 404 Not Found
  app.get  '/*',           (req,res,next)-> res.send 404
