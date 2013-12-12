require "rubygems"
require "bundler/setup"
require "minitest/autorun"

def elasticsearch_test_config
  {}
end

def elasticsearch_client
  @elasticsearch_client ||= Elasticsearch::Client.new elasticsearch_test_config
end


