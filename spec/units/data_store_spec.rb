require_relative '../../lib/dynamo_db/data_store'

describe Mince::DynamoDb::DataStore do
  let(:db) { mock 'db connection', tables: collections }
  let(:collections) { { collection_name => collection }  }
  let(:collection) { mock 'some collection', items: items, schema_loaded?: true }
  let(:collection_name) { 'some_collection_name'}
  let(:items) { mock 'items' }

  before do
    described_class.instance.db = db # do this each time because it's a singleton
  end

  describe 'when getting a collection' do
    context 'when the schema has not been loaded' do
      before do
        collection.stub(schema_loaded?: false, hash_key: nil)
      end

      it 'loads the schema' do
        collection.should_receive(:hash_key)

        described_class.collection(collection_name)
      end

      it 'returns the collection' do
        described_class.collection(collection_name).should == collection
      end
    end

    context 'when the schema has been loaded' do
      it 'does not load the schema' do
        collection.should_not_receive(:hash_key)

        described_class.collection(collection_name)
      end

      it 'returns the collection' do
        described_class.collection(collection_name).should == collection
      end
    end
  end

  it 'can get the items for a given collection' do
    described_class.items(collection_name).should == items
  end

  it 'can return the db' do
    described_class.db.should == db
  end

  it 'can get all collections' do
    described_class.collections.should == collections
  end
end
