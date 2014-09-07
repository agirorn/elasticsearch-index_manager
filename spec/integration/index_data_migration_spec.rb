require_relative "../spec_helper"

describe "Migrate data fromindex to index" do
  after do
    elasticsearch_client.indices.delete index: '_all'
  end

  def timestamp
    @timestamp ||= DateTime.parse('2013-12-11T09:00:30+00:00')
  end

  def manager
    @manager ||= Elasticsearch::IndexManager::Manager.new(timestamp: timestamp)
  end

  def items
    (1..10).collect do |index|
      OpenStruct.new(id: index, title: "Title  #{index}", price:  "50#{index}")
    end
  end

  it "migrates the data" do
    manager.index :products, mappings: {
      master: {
        properties: {
          title: { type: 'string' },
          price: { type: 'string' }
        }
      }
    }

    manager.migrate

    items.each do |item|
      elasticsearch_client.index index: 'products_write',
                                 type: 'master',
                                 id: item.id,
                                 body: {
                                   title: item.title,
                                   price: item.price
                                 }
    end

    @manager = Elasticsearch::IndexManager::Manager.new(
      timestamp: DateTime.parse('2013-12-11T10:00:30+00:00')
    )

    manager.index :products, mappings: {
      master: {
        properties: {
          title: { type: 'string' },
          price: { type: 'integer' }
        }
      }
    }

    manager.migrate

    items.each do |item|
      source = elasticsearch_client.get(
        index: 'products__2013-12-11__10-00-30',
        type: 'master',
        id: item.id
      )["_source"]
      source.must_equal( { "title" => item.title, "price" => item.price } )
    end
  end
end
