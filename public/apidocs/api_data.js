define({ api: [
  {
    "type": "GET",
    "url": " /api/page/find",
    "title": "ページの取得",
    "version": "0.2.0",
    "name": "記事オブジェクト取得",
    "description": "<p>特定のページを取得します。</p><p>   指定されたページのオブジェクトを一件だけ取得するAPIです。</p><p>   <code>id</code>か<code>link</code>のどちらかのパラメータは必須です。両方指定した場合、ID優先となります。</p><p>   ランダムなページや、最新のページを1件だけ取得する場合は、   <code>/api/page/list</code> APIを、<code>limit=1</code> などの指定で使用してください。</p><p>   Sample: <a href=\"http://www.stdin.net/api/page/find?id=54518505e0b813906fbffeaf\">http://www.stdin.net/api/page/find?id=54518505e0b813906fbffeaf</a></p>",
    "parameter": {
      "fields": {
        "Parameter": [
          {
            "group": "Parameter",
            "type": "String",
            "field": "id",
            "optional": false,
            "description": "<p>取得するページのObject Id</p>"
          },
          {
            "group": "Parameter",
            "type": "String",
            "field": "link",
            "optional": false,
            "description": "<p>取得するページのPermalink</p>"
          },
          {
            "group": "Parameter",
            "type": "Boolean",
            "field": "populateFeed",
            "optional": false,
            "description": "<p>配信元フィードの情報を含める(default=true)</p>"
          }
        ]
      }
    },
    "success": {
      "fields": {
        "Success 200": [
          {
            "group": "Success 200",
            "type": "JSONObject",
            "field": "json",
            "optional": false,
            "description": "<p>成功時コールバック</p>"
          }
        ]
      },
      "examples": [
        {
          "title": "Success-Response:",
          "content": "  {\n    _id: \"ObjectId(\"54512b79e959d9d2bdc6f50b\")\" // MongoDBのObjectId(Unique)\n    link: \"http://www.ping.pong/article/1.html\" // 記事へのPermalink\n    article: { https://github.com/danmactough/node-feedparser#list-of-article-properties }\n    feed:{\n      url: \"http://www.ping.pong/feed.xml\" // RSS/AtomフィードのURL\n      feed: { https://github.com/danmactough/node-feedparser#list-of-meta-properties }\n    // 以下,記事生成後にジョブキューにより生成\n    keywords: {\"ping\":10,\"pong\":2,\"bang\":5} // 本文中の頻出語\n    isbn: [ \"4150113483\" ]\n  }\n",
          "type": "json"
        }
      ]
    },
    "error": {
      "fields": {
        "Error 4xx": [
          {
            "group": "Error 4xx",
            "field": "PageNotFound",
            "optional": false,
            "description": "<p>(404) 当該ページが存在しないとき</p>"
          },
          {
            "group": "Error 4xx",
            "field": "InternalServerError",
            "optional": false,
            "description": "<p>(500) MongoDBへのクエリ実行が例外をthrowしたとき</p>"
          }
        ]
      }
    },
    "group": "PageEvent_coffee",
    "filename": "events/PageEvent.coffee"
  },
  {
    "type": "GET",
    "url": " /api/page/list",
    "title": "ページリストの取得",
    "version": "0.1.0",
    "name": "記事リスト取得",
    "description": "<p>ページリストの一覧を取得します。</p><p>   <code>sortByPubDate</code>と<code>random</code>を両方とも<code>true</code>にすることは出来ません。   その場合、<code>sortByPubDate</code>が優先されます。</p><p>   また、<code>keywords</code>,<code>body</code>,<code>content</code>パラメータについては、データが入力されていない場合があります。</p><p>   Sample: <a href=\"http://www.stdin.net/api/page/list?limit=1&amp;random=true&amp;sortByPubDate=false\">http://www.stdin.net/api/page/list?limit=1&amp;random=true&amp;sortByPubDate=false</a></p>",
    "parameter": {
      "fields": {
        "Parameter": [
          {
            "group": "Parameter",
            "type": "Number",
            "field": "limit",
            "optional": false,
            "description": "<p>取得する件数(default=100)</p>"
          },
          {
            "group": "Parameter",
            "type": "Boolean",
            "field": "populateFeed",
            "optional": false,
            "description": "<p>配信元フィードの情報を含める(default=true)</p>"
          },
          {
            "group": "Parameter",
            "type": "Boolean",
            "field": "sortByPubDate",
            "optional": false,
            "description": "<p>更新日時逆順でソート(default=true)</p>"
          },
          {
            "group": "Parameter",
            "type": "Boolean",
            "field": "random",
            "optional": false,
            "description": "<p>無作為に記事を抽出する(default=false)</p>"
          }
        ]
      }
    },
    "success": {
      "fields": {
        "Success 200": [
          {
            "group": "Success 200",
            "type": "JSONArray",
            "field": "json",
            "optional": false,
            "description": "<p>成功時コールバック</p>"
          }
        ]
      },
      "examples": [
        {
          "title": "Success-Response:",
          "content": "  [\n    {\n      _id: \"ObjectId(\"54512b79e959d9d2bdc6f50b\")\" // MongoDBのObjectId(Unique)\n      link: \"http://www.ping.pong/article/1.html\" // 記事へのPermalink\n      article: { https://github.com/danmactough/node-feedparser#list-of-article-properties }\n      feed:{\n        url: \"http://www.ping.pong/feed.xml\" // RSS/AtomフィードのURL\n        feed: { https://github.com/danmactough/node-feedparser#list-of-meta-properties }\n      // 以下,記事生成後にジョブキューにより生成\n      keywords: {\"ping\":10,\"pong\":2,\"bang\":5} // 本文中の頻出語\n      isbn: [ \"4150113483\" ]\n    }\n  ,...]\n",
          "type": "json"
        }
      ]
    },
    "error": {
      "fields": {
        "Error 4xx": [
          {
            "group": "Error 4xx",
            "field": "PageNotFound",
            "optional": false,
            "description": "<p>(404) 当該ページが存在しないとき</p>"
          },
          {
            "group": "Error 4xx",
            "field": "InternalServerError",
            "optional": false,
            "description": "<p>(500) MongoDBへのクエリ実行が例外をthrowしたとき</p>"
          }
        ]
      }
    },
    "group": "PageEvent_coffee",
    "filename": "events/PageEvent.coffee"
  }
] });