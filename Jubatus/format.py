#!/usr/bin/env python
# -*- coding: utf-8 -*-

# jubatusのデータを初期化するスクリプト

import jubatus

save_id = "stdin.net"

client = jubatus.Classifier("127.0.0.1",9200,"stdin.net")
client.save(save_id)
client.load(save_id)
