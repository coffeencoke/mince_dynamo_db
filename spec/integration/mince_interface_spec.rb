require_relative '../../lib/mince_dynamo_db'
require 'mince/shared_examples/interface_example'

describe 'Mince Interface with DynamoDb' do
  pending 'need to write a setup and teardown to create the db and tables needed' do
  before do
    AWS.config(
      :use_ssl => false,
      :mince_dynamo_db_endpoint => 'localhost',
      :access_key_id => "xxx",
      :secret_access_key => "xxx"
    )
    Mince::Config.interface = MinceDynamoDb::Interface
  end

  it_behaves_like 'a mince interface'
end
end
