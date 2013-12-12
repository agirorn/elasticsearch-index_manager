require_relative "../spec_helper"
require 'active_support/core_ext/hash'

describe "Creating index" do
  after do
    elasticsearch_client.indices.delete index: '_all'
  end

  def timestamp
    @timestamp ||= DateTime.parse('2013-12-11T09:00:30+00:00')
  end

  def manager
    @manager ||= Elasticsearch::IndexManager::Manager.new timestamp: timestamp
  end

  it "creating simple index" do
    manager.index :products, mappings: { document: { properties: { title_x: { type: 'string' } } } }
    expected_mappings = { "products__2013-12-11__09-00-30" => { "document" => { "properties" => { "title_x" => { "type" => "string" } } } } }

    manager.migrate
    get_mappings.must_equal( expected_mappings )
  end

  it "migrates splitt config" do
    manager.index :products, mappings: { document: { properties: { title_x: { type: 'string' } } } }
    manager.index :products, mappings: { document: { properties: { name: { type: 'string' } } } }

    expected_mappings = { "products__2013-12-11__09-00-30" => { "document" => { "properties" => { "title_x" => { "type" => "string" }, "name"    => { "type" => "string" } } } } }

    manager.migrate
    get_mappings.must_equal( expected_mappings )
  end

  it "dose not migrate stail indices" do
    mappings = { document: { properties: { title_x: { type: 'string' } } } }
    manager.index :products, mappings: mappings
    manager.migrate
    get_mappings.keys.first.must_equal( "products__2013-12-11__09-00-30" )

    @manager = Elasticsearch::IndexManager::Manager.new timestamp: DateTime.parse('2013-12-11T10:00:30+00:00')

    manager.index :products, mappings: mappings
    manager.migrate
    get_mappings.keys.first.must_equal( "products__2013-12-11__09-00-30" )
  end

  it "migrates index when mappings change" do
    manager.index :products, mappings: { document: { properties: { title_x: { type: 'string' } } } }
    expected_mappings = { "products__2013-12-11__09-00-30" => { "document" => { "properties" => { "title_x" => { "type" => "string" } } } } }

    manager.migrate
    get_mappings.must_equal( expected_mappings )

    # resetting the manager as an instance runing
    @manager = Elasticsearch::IndexManager::Manager.new timestamp: DateTime.parse('2013-12-11T10:00:30+00:00')

    manager.index :products, mappings: { document: { properties: { title_x: { type: 'string' }, name: { type: 'string' } } } }
    expected_mappings = { "products__2013-12-11__10-00-30" => { "document" => { "properties" => { "title_x" => { "type" => "string" }, "name"    => { "type" => "string" } } } } }

    manager.migrate
    get_mappings.must_equal( expected_mappings )
  end

  it "migrates simple analysis" do
    manager.index :products, settings: { analysis: { filter: { ngram: { type: 'ngram', min_gram: 3, max_gram: 25 } }, analyzer: { ngram: { type: 'custom', tokenizer: 'whitespace', filter: ['lowercase', 'stop', 'ngram'] } } } }

    expected_settings = { "products__2013-12-11__09-00-30" => { "settings" => { "index.analysis.filter.ngram.type" => "ngram", "index.analysis.filter.ngram.min_gram" => "3", "index.analysis.filter.ngram.max_gram" => "25", "index.analysis.analyzer.ngram.type" => "custom", "index.analysis.analyzer.ngram.tokenizer" => "whitespace", "index.analysis.analyzer.ngram.filter.0" => "lowercase", "index.analysis.analyzer.ngram.filter.1" => "stop", "index.analysis.analyzer.ngram.filter.2" => "ngram", "index.number_of_shards" => "5", "index.number_of_replicas" => "1" } } }

    manager.migrate
    actual_settings = clean_up_settings elasticsearch_client.indices.get_settings
    actual_settings.must_equal(  expected_settings )
  end

  it "migrates analysis when analysis changes" do
    manager.index :products, settings: { analysis: { filter: { ngram: { type: 'ngram', min_gram: 3, max_gram: 25 } }, analyzer: { ngram: { type: 'custom', tokenizer: 'whitespace', filter: ['lowercase', 'stop', 'ngram'] } } } }

    expected_settings = { "products__2013-12-11__09-00-30" => { "settings" => { "index.analysis.filter.ngram.type" => "ngram", "index.analysis.filter.ngram.min_gram" => "3", "index.analysis.filter.ngram.max_gram" => "25", "index.analysis.analyzer.ngram.type" => "custom", "index.analysis.analyzer.ngram.tokenizer" => "whitespace", "index.analysis.analyzer.ngram.filter.0" => "lowercase", "index.analysis.analyzer.ngram.filter.1" => "stop", "index.analysis.analyzer.ngram.filter.2" => "ngram", "index.number_of_shards" => "5", "index.number_of_replicas" => "1" } } }

    manager.migrate
    actual_settings = clean_up_settings elasticsearch_client.indices.get_settings

    actual_settings.must_equal( expected_settings )

    # resetting the manager as an instance runing
    @manager = Elasticsearch::IndexManager::Manager.new timestamp: DateTime.parse('2013-12-11T10:00:30+00:00')

    manager.index :products, settings: { analysis: { filter: { ngram: { type: 'nGram', min_gram: 3, max_gram: 25 } }, analyzer: { ngram: { type: 'custom', tokenizer: 'whitespace', filter: ['lowercase', 'stop', 'ngram'] }, ngram_search: { type: 'custom', tokenizer: 'whitespace', filter: ['lowercase', 'stop'] } } } }
    expected_settings = { "products__2013-12-11__10-00-30" => { "settings" => { "index.analysis.filter.ngram.type" => "nGram", "index.analysis.filter.ngram.min_gram" => "3", "index.analysis.filter.ngram.max_gram" => "25", "index.analysis.analyzer.ngram.type" => "custom", "index.analysis.analyzer.ngram.tokenizer" => "whitespace", "index.analysis.analyzer.ngram.filter.0" => "lowercase", "index.analysis.analyzer.ngram.filter.1" => "stop", "index.analysis.analyzer.ngram.filter.2" => "ngram", "index.analysis.analyzer.ngram.type" => "custom", "index.analysis.analyzer.ngram_search.type" => "custom", "index.analysis.analyzer.ngram_search.tokenizer" => "whitespace", "index.analysis.analyzer.ngram_search.filter.0" => "lowercase", "index.analysis.analyzer.ngram_search.filter.1" => "stop", "index.number_of_shards" => "5", "index.number_of_replicas" => "1" } } }

    manager.migrate
    actual_settings = clean_up_settings elasticsearch_client.indices.get_settings
    actual_settings.must_equal(  expected_settings )
  end

  private

  def clean_up_settings(indices)
    indices.keys.each do |index|
      settings = indices[index]["settings"]
      settings.delete("index.version.created")
      settings.delete("index.uuid")
    end
    indices
  end
end
