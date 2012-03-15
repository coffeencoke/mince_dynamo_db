require_relative '../../lib/mince_dynamo_db/data_store'

describe MinceDynamoDb::DataStore do
  subject { described_class.instance }

  let(:db) { mock 'dynamo db connection', tables: { collection_name => collection } }
  let(:mince_dynamo_db_connection) { mock 'mince dynamo db connection', connection: db }
  let(:collection) { mock 'some collection', items: items}
  let(:collection_name) { 'some_collection_name'}
  let(:primary_key) { mock 'primary key'}
  let(:mock_id) { mock 'id' }
  let(:data) { { :_id => mock_id}}
  let(:return_data) { mock 'return data' }
  let(:items) { mock 'items' }

  before do
    MinceDynamoDb::Connection.stub(:instance => mince_dynamo_db_connection)
  end

  it 'uses the correct collection' do
    subject.collection(collection_name).should == collection
  end

  it 'has a primary key identifier' do
    described_class.primary_key_identifier.should == 'id'
  end

  describe "Generating a primary key" do
    let(:unique_id) { '123456789012345' }
    let(:time) { mock 'time' }
    let(:salt) { mock 'salt' }

    before do
      Time.stub_chain('current.utc' => time)
    end

    it 'should create a reasonably unique id' do
      Digest::SHA256.should_receive(:hexdigest).with("#{time}#{salt}").and_return(unique_id)
      shorter_id = unique_id.to_s[0..6]

      described_class.generate_unique_id(salt).should == shorter_id
    end
  end

  it 'can write to the collection' do
    items.should_receive(:create).with(data).and_return(return_data)

    subject.add(collection_name, data).should == return_data
  end

  it 'can read from the collection' do
    subject.find_all(collection_name).should == items
  end

  it 'can replace a record' do
    items.should_receive(:put).with(data)

    subject.replace(collection_name, data)
  end

  it 'can get one document' do
    field = "stuff"
    value = "more stuff"

    items.should_receive(:at).with(value).and_return(return_data)
    
    subject.find(collection_name, field, value).should == return_data
  end

  it 'can clear the data store' do
    collection_1 = mock 'collection 1', name: 'collection 1'
    collection_2 = mock 'collection 2', name: 'collection 2'
    collections = [collection_1, collection_2]

    db.stub(:tables => collections)

    collections.each do |t|
      t.should_receive(:delete)
      db.tables.should_receive(:create).with(t.name, 10, 5, hash_key: { id: :string })
    end
    
    subject.clear
  end

  it 'can get all records of a specific key value' do
    items.should_receive(:where).with("key" => "value").and_return(return_data)

    subject.get_all_for_key_with_value(collection_name, "key", "value").should == return_data
  end

  it 'can get a record of a specific key value' do
    items.should_receive(:where).with({"key" => "value"}).and_return([return_data])

    subject.get_for_key_with_value(collection_name, "key", "value").should == return_data
  end

  it 'can get all records where a value includes any of a set of values' do
    filter = mock 'filter', in: return_data
    items.should_receive(:where).with(:key1).and_return(filter)
    filter.should_receive(:in).with([1,2,4]).and_return(return_data)

    subject.containing_any(collection_name, "key1", [1,2,4]).should == return_data
  end

  it 'can get all records where the array includes a value' do
    filter = mock 'filter', containse: return_data
    items.should_receive(:where).with(:key).and_return(filter)
    filter.should_receive(:contains).with('value').and_return(return_data)

    subject.array_contains(collection_name, "key", "value").should == return_data
  end

  it 'can push a value to an array for a specific record' do
    attributes = mock 'attributes'
    item = mock 'item', attributes: attributes

    items.should_receive(:where).with(:key => "value").and_return([item])
    attributes.should_receive(:add).with(:array_key => ["value_to_push"]).and_return(return_data)

    subject.push_to_array(collection_name, :key, "value", :array_key, "value_to_push").should == return_data
  end

  it 'can remove a value from an array for a specific record' do
    attributes = mock 'attributes'
    item = mock 'item', attributes: attributes

    items.should_receive(:where).with(:key => "value").and_return([item])
    attributes.should_receive(:delete).with(:array_key => ["value_to_remove"]).and_return(return_data)

    subject.remove_from_array(collection_name, :key, "value", :array_key, "value_to_remove").should == return_data
  end
end
