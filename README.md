# Logging using Elasticsearch

_This repository demonstrates how one could collect and centralise logs from a cluster/microservice environment into Elasticsearch._ If you are otherwise looking to get started with logging using Elasticsearch in general, we highly recommend visiting Elastic.co's [Getting Started with Logstash](https://www.elastic.co/guide/en/logstash/current/getting-started-with-logstash.html) before you check this repository out. 

This repository was used as part of a talk at IgniteMT (facebook.com/ignitemt). [The accompanying slides can be found here](https://docs.google.com/presentation/d/1Xmage3fhJCmt7B1o_k-XYGTYRQBCnz7J9nyncLGrEuw/edit?usp=sharing).

## Demo explained

This repository demonstrates a typical scenario where multiple applications push their events to the same Elasticsearch index, which will be ultimately viewed through Kibana. In this demo, we have two applications–`load_balancer` and `entropay`-which are pushing their logs independently.

**elasticsearch_kibana** - takes care of booting up both Elasticsearch and Kibana. Elasticsearch's port 9200 is not exposed to the container, and is only intended to be discoverable to Kibana though the `elastic_kibana_network` docker network, and to the Logstash instances through the `ignitemt` docker network. This would keep Elasticsearch away from direct access.

**entropay** and **load_balancer** - both applications run very similar of each other, and consist of three pieces:
- the applications holding the server logs. For the purpose of this demo, these apps are dummy containers storing their own seperate version of logs.
- Filebeat - accessing the server logs via the `log-files` docker volume.
- Logstash - Receiving events from Filebeat through the `apache_filebeat_logstash_network` docker network and relay then forward to Elasticsearch through the `ignitemt` docker network. 

##Running the demo

Create the `ignitemt` docker network:

```
docker network create ignitemt
```

Run `Elasticsearch` and `Kibana`:

```
docker-compose -f elasticsearch_kibana/docker-compose.yml up -d
```

Run `entropay` to start pushing server logs. This will initiate Filebeat to start pusing log events to Logstash, which will ultimately be relayed to Elasticsearch initiated above:

```
docker-compose -f entropay/docker-compose.yml up -d
```

Run `load_balancer` to start pushing the load balancer logs. This will initiate Filebeat to start pusing log events to Logstash, which will ultimately be relayed to Elasticsearch initiated above:

```
docker-compose -f load_balancer/docker-compose.yml up -d
```

It take a couple of minutes for both applications to push and index all their logs to elasticsearch.