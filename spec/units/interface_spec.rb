require_relative '../../lib/mince_dynamo_db/interface'

describe MinceDynamoDb::Interface do
  let(:db) { mock 'dynamo db connection', tables: { collection_name => collection } }
  let(:mince_dynamo_db_connection) { mock 'mince dynamo db connection', connection: db }
  let(:collection) { mock 'some collection', items: items, schema_loaded?: true }
  let(:collections) { mock }
  let(:collection_name) { 'some_collection_name'}
  let(:primary_key) { mock 'primary key'}
  let(:mock_id) { mock 'id' }
  let(:data) { { :_id => mock_id, time_field: mock('time field')}}
  let(:sanitized_data) { mock 'sanitized data' }
  let(:sanitized_time) { mock 'sanitized time' }
  let(:sanitized_id) { mock 'sanitized id' }
  let(:return_data) { mock 'return data', attributes: attributes }
  let(:attributes) { mock 'attributes' }
  let(:items) { mock 'items' }

  before do
    MinceDynamoDb::DataStore.stub(:items).with(collection_name).and_return(items)
    MinceDynamoDb::DataStore.stub(:collection).with(collection_name).and_return(collection)
    MinceDynamoDb::DataStore.stub(collections: collections, db: db)
    MinceDynamoDb::DataSanitizer.stub(:prepare_hash_for_storage).with(data).and_return(sanitized_data)
  end

  it 'can create a collection' do
    collections.should_receive(:create).with(collection_name, 10, 5)
    described_class.create_collection(collection_name)

    collections.should_receive(:create).with(collection_name, 100, 50)
    described_class.create_collection(collection_name, 100, 50)
  end

  it 'can update a field with a value' do
    primary_key_value = mock("id of record")
    field_name = mock 'field name'
    new_value = mock 'new value'
    items.stub(:where).with(described_class.primary_key_identifier.to_s => primary_key_value).and_return([return_data])

    attributes.should_receive(:set).with(field_name => new_value)

    described_class.update_field_with_value(collection_name, primary_key_value, field_name, new_value)
  end

  it 'can delete a field from a collection' do
    pending
    primary_key_value = mock("id of record")
    field_name = mock 'field name'
    new_value = mock 'new value'
    items.stub(:where).with(described_class.primary_key_identifier.to_s => primary_key_value).and_return([return_data])

    attributes.should_receive(:set).with(field_name => new_value)

    described_class.delete_field(collection_name, field_name)
  end

  it 'can delete a collection'
  it 'can increment a field by a specific amount'

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
    items.should_receive(:create).with(sanitized_data).and_return(return_data)

    described_class.add(collection_name, data).should == return_data
  end

  it 'can read from the collection' do
    item_attributes = mock 'attributes for an item'
    item = mock 'item', attributes: item_attributes
    items.should_receive(:select).and_return([item])

    described_class.find_all(collection_name).should == [item_attributes]
  end

  it 'can replace a record' do
    items.should_receive(:put).with(sanitized_data)

    described_class.replace(collection_name, data)
  end

  it 'can get one document' do
    field = "stuff"
    value = "more stuff"

    items.should_receive(:where).with(field => value).and_return([return_data])
    
    described_class.find(collection_name, field, value).should == attributes
  end

  it 'can delete a record that matches a criteria' do
    params = mock 'params'
    items.should_receive(:where).with(params).and_return([return_data])
    return_data.should_receive(:delete)
    
    described_class.delete_by_params(collection_name, params)
  end

  it 'can clear the data store' do
    item = mock 'item', delete: nil
    item2 = mock 'item 2', delete: nil
    collection_1 = mock 'collection 1', name: 'collection 1', schema_loaded?: true, items: [item]
    collection_2 = mock 'collection 2', name: 'collection 2', schema_loaded?: true, items: [item2]
    collections = [collection_1, collection_2]

    db.stub(:tables => collections)

    item.should_receive(:delete)
    item2.should_receive(:delete)
    
    described_class.clear
  end

  it 'can get all records of a specific key value' do
    items.should_receive(:where).with("key" => "value").and_return([return_data])

    described_class.get_all_for_key_with_value(collection_name, "key", "value").should == [attributes]
  end

  it 'can get a record of a specific key value' do
    items.should_receive(:where).with({"key" => "value"}).and_return([return_data])

    described_class.get_for_key_with_value(collection_name, "key", "value").should == attributes
  end

  it 'can get all records where a value includes any of a set of values' do
    filter = mock 'filter', in: return_data
    items.should_receive(:where).with(:key1).and_return(filter)
    filter.should_receive(:in).with([1,2,4]).and_return([return_data])

    described_class.containing_any(collection_name, "key1", [1,2,4]).should == [attributes]
  end

  it 'can get all records where the array includes a value' do
    filter = mock 'filter', contains: return_data
    items.should_receive(:where).with(:key).and_return(filter)
    filter.should_receive(:contains).with('value').and_return([return_data])

    described_class.array_contains(collection_name, "key", "value").should == [attributes]
  end

  it 'can push a value to an array for a specific record' do
    value_to_push = mock 'value to push to the record'
    sanitized_value_to_push = mock 'sanitized value to push to the record'
    MinceDynamoDb::DataSanitizer.stub(:prepare_field_for_storage).with(value_to_push).and_return(sanitized_value_to_push)
    items.should_receive(:where).with("key" => "value").and_return([return_data])
    attributes.should_receive(:add).with(:array_key => [sanitized_value_to_push])

    described_class.push_to_array(collection_name, :key, "value", :array_key, value_to_push)
  end

  it 'can remove a value from an array for a specific record' do
    items.should_receive(:where).with("key" => "value").and_return([return_data])
    attributes.should_receive(:delete).with(:array_key => ["value_to_remove"])

    described_class.remove_from_array(collection_name, :key, "value", :array_key, "value_to_remove")
  end
end
