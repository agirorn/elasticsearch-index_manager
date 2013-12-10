# Elasticsearch::IndexManager

Elasticsearch IndexMangaer is an automation tool for managing indices on an Elasticsearch server.
It creates indexes or changing their mapping with zero downtime. Following the guidlines from the Elasticsearch team. "[changing mapping with zero downtime](http://www.elasticsearch.org/blog/changing-mapping-with-zero-downtime/)"

## Installation

Add this line to your application's Gemfile:

    gem 'elasticsearch-index_manager', :git => 'git@github.com/elasticsearch-index_manager.git'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elasticsearch-index_manager

## Usage

## Getting started
```sh
$ cd project-directory
$ rake esi:init
```

This vill create the `config/elasticsearch_index.rb` and`config/elasticsearch.yml`

## The elasticsearch.yml file stores how to connect to your elastisearch server.

```yaml
development:
  host: localhost
  port: 9200

test: &test
  host: localhost
  port: 9500

production:
  host: production.example.com
  port: 9200
```

## Example elasticsearch.rb file
In this file you can define all the indices elasticsearch.
The API is the same as [elasticsearch-ruby gem](https://github.com/elasticsearch/elasticsearch-ruby/tree/master/elasticsearch-api)

```ruby
index :items,
      mappings: {
        document: {
          properties: {
            title_x: { type: 'string' }
          }
        }
      }

index :products,
      mappings: {
        document: {
          properties: {
            name: { type: 'string' }
          }
        }
      }

```



## The final result is this
```sh
$ curl http://localhost:9200/_settings?pretty
```

```JSON
{
  "products__2013-12-09__18-21-44" : {
    "settings" : {
      "index.number_of_shards" : "5",
      "index.number_of_replicas" : "1",
      "index.version.created" : "900799",
      "index.uuid" : "_ObkPzb0QBWWS2r6fSFORQ"
    }
  }
}
```

```sh
$ curl http://localhost:9200/_mapping?pretty
```

```JSON
{
  "products__2013-12-09__18-21-44" : {
    "document" : {
      "properties" : {
        "name" :  { "type" : "string" },
        "title" : { "type" : "string" }
      }
    }
  }
}
```

```sh
$ curl http://localhost:9200/_aliases?pretty
```

```JSON
{
  "products__2013-12-10__13-57-26" : {
    "aliases" : {
      "products_write" : { },
      "products" : { }
    }
  }
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
