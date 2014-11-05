window.httpApiWrapper =

  # 購読できるフィード/ストリームの検索
  findFeed:(url,callback)->
    $.getJSON "/api/feed/find",
      url:url
    .success (data)->
      callback null,data
    .error (err)->
      callback err,null

  # 最新記事取得
  getLatestArticles:(callback)->
    $.getJSON "/api/page/latest?limit=150"
    .success (data)->
      callback null,data
    .error (err)->
      callback err,null

  # オプション付き
  getPageList:(options,callback)->
    $.getJSON "/api/page/list",options
    .success (data)->
      callback null,data
    .error (err)->
      callback err,null

