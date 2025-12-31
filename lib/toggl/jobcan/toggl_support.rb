# frozen_string_literal: true

module Toggl
  module Jobcan
    # Provides support methods for Toggl
    module TogglSupport
      def fetch_toggl_worktime(dates)
        first_day = dates.sort.first
        last_day = dates.sort.last
        @toggl.merge_multi!(first_day.year, first_day.month, first_day.day, last_day.day)
        @toggl.work_time_map
      end

      def toggl_time_format(date, timestamp)
        same_day = date == timestamp.to_date
        return timestamp.strftime('%H%M') if same_day

        hour = timestamp.hour + 24
        minute = timestamp.min
        format('%02d%02d', hour, minute)
      end
    end
  end
end
