require "rubygems"
require "bundler/setup"
require "minitest/autorun"
require "awesome_print"
require "pry"
require "elasticsearch/index_manager"

def elasticsearch_test_config
  {}
end

def elasticsearch_client
  @elasticsearch_client ||= Elasticsearch::Client.new elasticsearch_test_config
end

def get_mappings
  elasticsearch_client.indices.get_mapping
end
