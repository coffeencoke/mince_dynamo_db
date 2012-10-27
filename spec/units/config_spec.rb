require_relative '../../lib/dynamo_db/config'

describe Mince::DynamoDb::Config do
  let(:secret_access_key) { mock }
  let(:access_key_id) { mock }

  before do
    AWS.config(access_key_id: access_key_id, secret_access_key: secret_access_key)
  end

  it 'uses "id" as the primary key for the database' do
    described_class.primary_key.should == :id
  end

  it "has the credentials for using Amazon's Dynamo DB service" do
    described_class.secret_access_key.should == secret_access_key
    described_class.access_key_id.should == access_key_id
  end
end
