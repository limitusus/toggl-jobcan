# frozen_string_literal: true

module Toggl
  module Jobcan
    # Jobcan client
    class Client
      attr_accessor :credentials
      attr_reader :driver, :toggl

      class JobcanLoginFailure < StandardError; end

      include Toggl::Jobcan::TogglSupport

      JOBCAN_URLS = {
        login: 'https://id.jobcan.jp/users/sign_in',
        attendance_login: 'https://ssl.jobcan.jp/jbcoauth/login',
        attendance: 'https://ssl.jobcan.jp/employee/attendance',
        attendance_modify: 'https://ssl.jobcan.jp/employee/adit/modify/'
      }.freeze

      XPATHS = {
        load_button: %(//input[@value='表示']),
        submit: %(//input[@type='submit']),
        flash: %(//p[@class='flash flash__alert'])
      }.freeze

      def initialize(
        toggl_worktime_config:, credentials: nil,
        options: {},
        dryrun: false
      )
        @credentials = credentials
        @driver = Ferrum::Browser.new(headless: true, **options)
        @toggl = Toggl::Worktime::Driver.new(
          config: Toggl::Worktime::Config.new(path: toggl_worktime_config)
        )
        @dryrun = dryrun
      end

      def login
        @driver.goto JOBCAN_URLS[:login]
        send_credentials
        @driver.at_xpath(XPATHS[:submit]).click
        raise JobcanLoginFailure if @driver.at_xpath(XPATHS[:flash])

        # attendance login
        @driver.goto JOBCAN_URLS[:attendance_login]
        @driver.goto JOBCAN_URLS[:attendance]
      end

      def send_credentials
        [
          ['user_email', :email],
          ['user_password', :password]
        ].each do |id, method|
          element = @driver.at_css("##{id}")
          element.focus.type(@credentials.send(method))
        end
      end

      def navigate_to_attendance_month(year, month)
        @driver.goto JOBCAN_URLS[:attendance]
        # Specify by month
        @driver.at_css('#search_type_month').click
        @driver.at_xpath(%(//select[@name='year'])).select(year.to_s, by: :text)
        @driver.at_xpath(%(//select[@name='month'])).select(format('%02d', month), by: :text)
        # load
        @driver.at_xpath(XPATHS[:load_button]).click
      end

      def navigate_to_attendance_modify_day(date)
        # https://ssl.jobcan.jp/employee/adit/modify?year=2018&month=3&day=14
        query_string = "year=#{date.year}&month=#{date.month}&day=#{date.day}"
        @driver.goto "#{JOBCAN_URLS[:attendance_modify]}?#{query_string}"
      end

      def input_day_worktime(date, time_slots)
        time_slots.flatten.each do |timestamp|
          input_stamp = toggl_time_format(date, timestamp)
          puts "  - Input #{input_stamp}"
          navigate_to_attendance_modify_day(date)
          send_timestamp input_stamp
          @driver.at_css('#insert_button').click unless @dryrun
        end
      end

      def send_timestamp(timestamp)
        time_elem = @driver.at_css('#ter_time')
        time_elem.focus.type(timestamp)
      end
    end
  end
end
