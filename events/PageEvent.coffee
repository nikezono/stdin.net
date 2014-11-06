###

  PageEvent.coffee

###

debug = require("debug")("stdin/events/page")
_     = require 'underscore'
request = require 'request'
async = require 'async'

module.exports.PageEvent = (app) ->
  Page        = app.get("models").Page

  ###

  @api {GET}  /api/page/list ページリストの取得
  @apiVersion 0.1.0
  @apiName 記事リスト取得
  @apiDescription ページリストの一覧を取得します。

    `sortByPubDate`と`random`を両方とも`true`にすることは出来ません。
    その場合、`sortByPubDate`が優先されます。

    また、`keywords`,`body`,`content`パラメータについては、データが入力されていない場合があります。

    Sample: http://www.stdin.net/api/page/list?limit=1&random=true&sortByPubDate=false

  @apiParam {Number} limit 取得する件数(default=100)
  @apiParam {Boolean} populateFeed 配信元フィードの情報を含める(default=true)
  @apiParam {Boolean} sortByPubDate 更新日時逆順でソート(default=true)
  @apiParam {Boolean} random 無作為に記事を抽出する(default=false)

  @apiSuccess {JSONArray} json 成功時コールバック
  @apiSuccessExample {json} Success-Response:
    [
      {
        _id: "ObjectId("54512b79e959d9d2bdc6f50b")" // MongoDBのObjectId(Unique)
        link: "http://www.ping.pong/article/1.html" // 記事へのPermalink
        article: { https://github.com/danmactough/node-feedparser#list-of-article-properties }
        feed:{
          url: "http://www.ping.pong/feed.xml" // RSS/AtomフィードのURL
          feed: { https://github.com/danmactough/node-feedparser#list-of-meta-properties }
        // 以下,記事生成後にジョブキューにより生成
        keywords: {"ping":10,"pong":2,"bang":5} // 本文中の頻出語
        body: "<html><body><p>hoge</p></body></html>" // URLの参照先全文
        content: "hoge" // 本文抽出されたテキスト
      }
    ,...]

  @apiError PageNotFound(404) 当該ページが存在しないとき
  @apiError InternalServerError(500) MongoDBへのクエリ実行が例外をthrowしたとき

  ###
  getPageList: (req,res,next)->

    # Options
    # 実行順
    options = req.query
    options.random = if options.random is 'true' then true else  false # ランダムに出す
    options.populateFeed =  if options.populateFeed is 'false' then false else  true # Feedの情報を取得する
    options.sortByPubDate =  if options.sortByPubDate is 'false' then false else  true # PubDateでソートする
    options.limit ||= 100 # Limit:件数制限

    promise = Page
    promise = promise.find() if not options.random
    promise = promise.findRandom() if options.random
    promise = promise.find('article.pubDate':"$lte":new Date()).sort('article.pubDate':-1) if options.sortByPubDate
    promise = promise.populate('feed') if options.populateFeed
    promise = promise.limit(options.limit)
    promise = promise.exec (err,pages)->
      if err
        app.emit 'error', err
        return res.send 500
      return res.send 404 if not pages or _.isEmpty pages
      return res.json pages

  # GET /api/page/stream
  # 追加される度に流していくhttpStream
  # @todo 実装
  getPageStream: (req,res,next)->

    # Options
    options = req.query
    res.send []

  # GET /api/page/latest
  getLatestPages: (req,res,next)->

    req.query.random = false
    req.query.sortByPubDate = true
    @getPageList req,res,next # @note リダイレクトのほうがいい？


  getSimilarPages: (req,res,next)->

    id = req.params.id
    return res.send 400 if not id

    # @todo 実装
    return res.json []


