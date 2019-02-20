# frozen_string_literal: true

RSpec.describe Toggl::Jobcan::Credentials do
  let(:config) { 'spec/testdata/sample_config.yaml' }

  it 'can be initialized' do
    o = Toggl::Jobcan::Credentials.new(path: config)
    expect(o).to be_a Toggl::Jobcan::Credentials
  end

  it 'can load config' do
    o = Toggl::Jobcan::Credentials.new(path: config)
    expect(o.email).to eq 'alice@example.com'
    expect(o.password).to eq 'pa55w0rd'
  end
end
