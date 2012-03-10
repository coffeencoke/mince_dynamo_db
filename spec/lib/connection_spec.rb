require_relative '../../lib/mince_dynamo_db/connection'

describe MinceDynamoDb::Connection do
  subject { described_class.instance }

  let(:connection) { mock 'an amazon dynamo db object' }
  let(:access_key_id) { mock 'access key id provided by amazon'}
  let(:secret_access_key) { mock 'secret access key provided by amazon'}
  let(:aws_config) { mock 'aws config object', secret_access_key: secret_access_key, access_key_id: access_key_id }

  before do
    AWS.stub(config: aws_config)
  end

  it 'has a dynamo db connection' do
    AWS::DynamoDB.should_receive(:new).with(access_key_id: access_key_id, secret_access_key: secret_access_key).and_return(connection)

    subject.connection.should == connection
  end
end