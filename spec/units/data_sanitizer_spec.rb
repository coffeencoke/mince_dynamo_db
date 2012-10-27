require_relative '../../lib/dynamo_db/data_sanitizer'

require 'date'

describe Mince::DynamoDb::DataSanitizer do
  it 'converts a Time object to a string' do
    value = Time.now

    described_class.prepare_field_for_storage(value).should == value.to_s
    described_class.prepare_hash_for_storage({ field: value }).should == { field: value.to_s }
  end

  it 'does not convert a float' do
    value = 3.2

    described_class.prepare_field_for_storage(value).should == value
    described_class.prepare_hash_for_storage({ field: value }).should == { field: value }
  end

  it 'does not convert a string' do
    value = 'string'

    described_class.prepare_field_for_storage(value).should == value
    described_class.prepare_hash_for_storage({ field: value }).should == { field: value }
  end

  it 'does not convert an integer' do
    value = 1

    described_class.prepare_field_for_storage(value).should == value
    described_class.prepare_hash_for_storage({ field: value }).should == { field: value }    
  end

  it 'converts a Date object to a string' do
    value = Date.today

    described_class.prepare_field_for_storage(value).should == value.to_s
    described_class.prepare_hash_for_storage({ field: value }).should == { field: value.to_s }        
  end
end
