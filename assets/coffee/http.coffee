window.httpApiWrapper =

  # 最新記事取得
  getLatestArticles:(callback)->
    $.getJSON "/api/page/latest?limit=20"
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
