require_relative '../../lib/mince_dynamo_db/data_store'

describe MinceDynamoDb::DataStore do
  subject { described_class.instance }

  let(:db) { mock 'dynamo db connection', tables: { table_name => table } }
  let(:mince_dynamo_db_connection) { mock 'mince dynamo db connection', connection: db }
  let(:table) { mock 'some collection', items: items}
  let(:table_name) { 'some_collection_name'}
  let(:primary_key) { mock 'primary key'}
  let(:mock_id) { mock 'id' }
  let(:data) { { :_id => mock_id}}
  let(:return_data) { mock 'return data' }
  let(:items) { mock 'items' }

  before do
    MinceDynamoDb::Connection.stub(:instance => mince_dynamo_db_connection)
  end

  it 'uses the correct collection' do
    subject.collection(table_name).should == table
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

    subject.add(table_name, data).should == return_data
  end

  it 'can read from the collection' do
    collection.should_receive(:find).and_return(return_data)

    subject.find_all(collection_name).should == return_data
  end

  it 'can replace a record' do
    collection.should_receive(:update).with({"_id" => data[:_id]}, data)

    subject.replace(collection_name, data)
  end

  it 'can get one document' do
    field = "stuff"
    value = "more stuff"

    collection.should_receive(:find_one).with(field => value).and_return(return_data)

    subject.find(collection_name, field, value).should == return_data
  end

  it 'can clear the data store' do
    collection_names = %w(collection_1 collection_2 system_profiles)
    db.stub(:collection_names => collection_names)

    db.should_receive(:drop_collection).with('collection_1')
    db.should_receive(:drop_collection).with('collection_2')

    subject.clear
  end

  it 'can get all records of a specific key value' do
    collection.should_receive(:find).with({"key" => "value"}).and_return(return_data)

    subject.get_all_for_key_with_value(collection_name, "key", "value").should == return_data
  end

  it 'can get a record of a specific key value' do
    collection.should_receive(:find).with({"key" => "value"}).and_return([return_data])

    subject.get_for_key_with_value(collection_name, "key", "value").should == return_data
  end

  it 'can get all records where a value includes any of a set of values' do
    collection.should_receive(:find).with({"key1" => { "$in" => [1,2,4]} }).and_return(return_data)

    subject.containing_any(collection_name, "key1", [1,2,4]).should == return_data
  end

  it 'can get all records where the array includes a value' do
    collection.should_receive(:find).with({"key" => "value"}).and_return(return_data)

    subject.array_contains(collection_name, "key", "value").should == return_data
  end

  it 'can push a value to an array for a specific record' do
    collection.should_receive(:update).with({"key" => "value"}, { '$push' => { "array_key" => "value_to_push"}}).and_return(return_data)

    subject.push_to_array(collection_name, :key, "value", :array_key, "value_to_push").should == return_data
  end

  it 'can remove a value from an array for a specific record' do
    collection.should_receive(:update).with({"key" => "value"}, { '$pull' => { "array_key" => "value_to_remove"}}).and_return(return_data)

    subject.remove_from_array(collection_name, :key, "value", :array_key, "value_to_remove").should == return_data
  end
end