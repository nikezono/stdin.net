###

  PageEvent.coffee

###

debug      = require("debug")("stdin/events/page")
_          = require 'underscore'
request    = require 'request'
JSONStream = require 'JSONStream'
stream     = require('stream')
ObjectId   = require('mongoose').Types.ObjectId
async      = require 'async'

module.exports.PageEvent = (app) ->
  Page        = app.get("models").Page

  ###

  @api {GET}  /api/page/find ページの取得
  @apiVersion 0.2.0
  @apiName 記事オブジェクト取得
  @apiDescription 特定のページを取得します。

    指定されたページのオブジェクトを一件だけ取得するAPIです。

    `id`か`link`のどちらかのパラメータは必須です。両方指定した場合、ID優先となります。

    ランダムなページや、最新のページを1件だけ取得する場合は、
    `/api/page/list` APIを、`limit=1` などの指定で使用してください。

    Sample: http://www.stdin.net/api/page/find?id=54518505e0b813906fbffeaf

  @apiParam {String} id 取得するページのObject Id
  @apiParam {String} link 取得するページのPermalink
  @apiParam {Boolean} populateFeed 配信元フィードの情報を含める(default=true)

  @apiSuccess {JSONObject} json 成功時コールバック
  @apiSuccessExample {json} Success-Response:
    {
      _id: "ObjectId("54512b79e959d9d2bdc6f50b")" // MongoDBのObjectId(Unique)
      link: "http://www.ping.pong/article/1.html" // 記事へのPermalink
      article: { https://github.com/danmactough/node-feedparser#list-of-article-properties }
      feed:{
        url: "http://www.ping.pong/feed.xml" // RSS/AtomフィードのURL
        feed: { https://github.com/danmactough/node-feedparser#list-of-meta-properties }
      // 以下,記事生成後にジョブキューにより生成
      keywords: {"ping":10,"pong":2,"bang":5} // 本文中の頻出語
    }

  @apiError PageNotFound(404) 当該ページが存在しないとき
  @apiError InternalServerError(500) MongoDBへのクエリ実行が例外をthrowしたとき

  ###

  getPageOne: (req,res,next)->

    return res.send 400 if _.isEmpty(req.query.id) and _.isEmpty(req.query.link)
    # Options
    # 実行順
    options = req.query
    options.populateFeed =  if options.populateFeed is 'false' then false else  true # Feedの情報を取得する

    promise = Page
    if options.id
      promise = promise.findOne(_id:new ObjectId(options.id))
    else
      promise = promise.findOne(link:options.link)
    promise = promise.select '-r -__v'
    promise = promise.populate('feed','-pages -links') if options.populateFeed
    isFounded = false
    promise = promise.stream()
    .on 'error', (err) ->
      app.emit 'error',err
      return res.send 500
    .on 'data', (doc)->
      isFounded = true
      return res.json doc
    .on 'close',->
      return res.status(404).end() if not isFounded

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
    options.limit = if not isNaN(options.limit) then options.limit else 100 # Limit:件数制限

    promise = Page
    promise = promise.find() if not options.random
    promise = promise.findRandom() if options.random
    promise = promise.sort(pubDate:-1) if options.sortByPubDate
    promise = promise.select '-r -__v'
    promise = promise.populate('feed','-pages -links') if options.populateFeed
    promise = promise.limit(options.limit)
    promise = promise.find(pubDate:"$lte":new Date()) #現在より先の記事をフィルタ
    index = 0
    promise = promise.stream()
    .on 'error', (err) ->
      app.emit 'error',err
      return res.send 500
    .on 'data', (doc)->
      res.write "[" if index is 0
      res.write "," if index > 0
      res.write JSON.stringify(doc)
      index++
    .on 'close',->
      if index > 0
        res.write "]"
        return res.end()
      return res.send 404

  ###

  @todo 同じIPアドレスからのStreaming接続数を制限する
  @todo RFC勧告をチェックして、従う
  @note HTML5 Server Sent Events使う?
  @api {GET}  /api/page/stream ページストリーム
  @apiVersion 0.3.0
  @apiName 記事リスト取得
  @apiDescription ページ更新のストリームを取得します。

    HTTPコネクションをcloseせずに、新着データを送信し続けます。

    `waitForAnalyze`パラメータを設定しなければ、たいていの場合、
    `keywords`などのフィールドは空です。

    参考URL:

      * http://ajaxpatterns.org/HTTP_Streaming


    Sample: http://www.stdin.net/api/page/stream

  @apiParam {Boolean} populateFeed 配信元フィードの情報を含める(default=true)
  @apiParam {Boolean} waitForAnalyze データの後処理が終わってから配信してもらう(default=true)

  @apiSuccess {JSONArray} json 成功時コールバック
  @apiSuccessExample {json} Success-Response:
      {
        _id: "ObjectId("54512b79e959d9d2bdc6f50b")" // MongoDBのObjectId(Unique)
        link: "http://www.ping.pong/article/1.html" // 記事へのPermalink
        article: { https://github.com/danmactough/node-feedparser#list-of-article-properties }
        feed:{
          url: "http://www.ping.pong/feed.xml" // RSS/AtomフィードのURL
          feed: { https://github.com/danmactough/node-feedparser#list-of-meta-properties }
        // 以下,記事生成後にジョブキューにより生成
        keywords: {"ping":10,"pong":2,"bang":5} // 本文中の頻出語
      }
    ,...

  @apiError InternalServerError(500) ありえるかな

  ###
  getPageStream: (req,res,next)->

    # Options
    options = req.query
    options.populateFeed =  if options.populateFeed is 'false' then false else  true # Feedの情報を取得する
    options.waitForAnalyze = if options.waitForAnalyze is 'false' then false else true # 後処理を待つ

    res.status(200)
    res.set
      "Content-Type":"application/json"
      'Connection':'close'
      "transfer-encoding":"chunked"
      "Cache-Control":"no-cache"

    findOneWithIdAndWriteResponse = (pageId)->
      promise = Page.findOne(_id:pageId)
      promise = promise.select '-r -__v'
      promise = promise.populate('feed','-pages -links') if options.populateFeed
      promise.exec (err,page)->
        return app.emit 'error',err if err
        res.write JSON.stringify(page).replace('\n','')
        res.write '\n'

    if options.waitForAnalyze
      app.on 'new page analyzed',(pageId)->
        findOneWithIdAndWriteResponse pageId

    else
      app.on 'new page',(pageId)->
        findOneWithIdAndWriteResponse pageId

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
