# frozen_string_literal: true

require 'date'

RSpec.describe Toggl::Jobcan::TogglSupport do
  module TSTestClass
    include Toggl::Jobcan::TogglSupport

    module_function :toggl_time_format
  end

  it 'returns the given time if the date is same' do
    date = Date.new(2006, 1, 2)
    time = Time.local(2006, 1, 2, 15, 4, 5, 0)
    expected_date = '1504'
    toggl_time = TSTestClass.toggl_time_format(date, time)
    expect(toggl_time).to eq expected_date
  end

  it 'returns +24h time if the date is different' do
    date = Date.new(2006, 1, 2)
    time = Time.local(2006, 1, 3, 3, 4, 5, 0)
    expected_date = '2704'
    toggl_time = TSTestClass.toggl_time_format(date, time)
    expect(toggl_time).to eq expected_date
  end
end
