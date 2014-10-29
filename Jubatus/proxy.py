#!/usr/bin/env python
# -*- coding:utf-8

from flask import Flask,request

import sys
from jubatus.common import Datum
import msgpackrpc
import jubatus
import json
import time

app = Flask(__name__)

@app.route("/set",methods=["POST"])
def set():

    data = request.json
    datum_seed = {}
    datum_seed["text"] = data["text"]
    datum = Datum(datum_seed)

    unixtime = time.time()
    try:

        # JUBATUS CLIENT
        client = jubatus.NearestNeighbor("127.0.0.1",9200,"stdin.net")

        # Classifier
        jubaresponse = client.set_row(data["id"],datum)
        client.save("stdin.net")

    except(msgpackrpc.error.RPCError, jubatus.common.client.InterfaceMismatch) as e:
        print e
        sys.stdout.flush()
        return "500"
    finally:
        client.get_client().close()

    unixtime = time.time() - unixtime
    print "Jubatus DataSet end. msec=%d" % unixtime
    sys.stdout.flush()

    return "200"


@app.route("/neighbor",methods=['GET'])
def neighbor():

    # PARSE
    data = request.json
    query_id = data["id"]

    unixtime = time.time()
    try:

        # JUBATUS CLIENT
        client = jubatus.NearestNeighbor("127.0.0.1",9200,"stdin.net")

        # Classifier
        jubaresponse = client.neighbor_row_from_id(query_id,100)
        jubaresponse.sort(key=lambda x:x.score,reverse=True)

    except(msgpackrpc.error.RPCError, jubatus.common.client.InterfaceMismatch) as e:
        print e
        sys.stdout.flush()
        return "500"
    finally:
        client.get_client().close()

    unixtime = time.time() - unixtime
    print "Jubatus NearestNeighbor end. msec=%d" % unixtime
    sys.stdout.flush()

    resArray = []
    for record in jubaresponse:
        value = record.id.decode('utf-8')
        score = record.score

        print u'record %s, score %f' % (value,score)
        sys.stdout.flush()

        resHash = {
                "id":value,
                "score":score
            }
        resArray.append(resHash)
        if len(resArray) >= 100:
            break

    return json.dumps(resArray)

client = jubatus.NearestNeighbor("127.0.0.1",9200,"stdin.net")
client.load("stdin.net")
app.run(port=4001,debug=True)
