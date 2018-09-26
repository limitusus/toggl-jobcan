# frozen_string_literal: true

module Toggl
  module Jobcan
    # Jobcan client
    class Client
      attr_accessor :credentials
      attr_reader :driver
      attr_reader :toggl

      class JobcanLoginFailure < StandardError; end

      include Toggl::Jobcan::TogglSupport

      JOBCAN_URLS = {
        login: 'https://id.jobcan.jp/users/sign_in',
        attendance_login: 'https://ssl.jobcan.jp/jbcoauth/login',
        attendance: 'https://ssl.jobcan.jp/employee/attendance',
        attendance_modify: 'https://ssl.jobcan.jp/employee/adit/modify/'
      }.freeze

      XPATHS = {
        notice: %(//textarea[@name='notice']),
        load_button: %(//input[@value='表示']),
        submit: %(//input[@type='submit']),
        password_label: %(//label[@for='user_password']),
        flash: %(//p[@class='flash flash__alert'])
      }.freeze

      def initialize(
            credentials: nil,
            options: Selenium::WebDriver::Chrome::Options.new,
            toggl_worktime_config:,
            dryrun: false
          )
        @credentials = credentials
        options.add_argument('--headless')
        @driver = Selenium::WebDriver.for :chrome, options: options
        @toggl = Toggl::Worktime::Driver.new(
          config: Toggl::Worktime::Config.new(path: toggl_worktime_config)
        )
        @dryrun = dryrun
      end

      def login
        @driver.navigate.to JOBCAN_URLS[:login]
        # login if <label for="user_password"> exists
        raise unless may_find_element(:xpath, XPATHS[:password_label])

        send_credentials
        @driver.find_element(:xpath, XPATHS[:submit]).click
        raise JobcanLoginFailure if may_find_element(:xpath, XPATHS[:flash])

        # attendance login
        @driver.navigate.to JOBCAN_URLS[:attendance_login]
        @driver.navigate.to JOBCAN_URLS[:attendance]
      end

      def send_credentials
        [
          ['user_email', :email],
          ['user_password', :password]
        ].each do |id, method|
          element = @driver.find_element(:id, id)
          element.send_keys(@credentials.send(method))
        end
      end

      def navigate_to_attendance_month(year, month)
        @driver.navigate.to JOBCAN_URLS[:attendance]
        # Specify by month
        @driver.find_element(:id, 'search_type_month').click
        selector_year = select_support_for('year')
        selector_year.select_by(:text, year.to_s)
        selector_month = select_support_for('month')
        selector_month.select_by(:text, format('%02d', month))
        # load
        @driver.find_element(:xpath, XPATHS[:load_button]).click
      end

      def navigate_to_attendance_modify_day(date)
        # https://ssl.jobcan.jp/employee/adit/modify?year=2018&month=3&day=14
        query_string = "year=#{date.year}&month=#{date.month}&day=#{date.day}"
        @driver.navigate.to JOBCAN_URLS[:attendance_modify] + '?' + query_string
      end

      def select_support_for(name)
        Selenium::WebDriver::Support::Select.new(
          @driver.find_element(:xpath),
          %(//select[@name='#{name}'])
        )
      end

      def input_day_worktime(date, time_slots)
        time_slots.flatten.each do |timestamp|
          input_stamp = toggl_time_format(date, timestamp)
          puts "  - Input #{input_stamp}"
          navigate_to_attendance_modify_day(date)
          send_timestamp input_stamp
          send_notice
          @driver.find_element(:id, 'insert_button').submit unless @dryrun
        end
      end

      def send_timestamp(timestamp)
        time_elem = @driver.find_element(:id, 'ter_time')
        time_elem.send_keys(timestamp)
      end

      def send_notice
        notice_elem = @driver.find_element(:xpath, XPATHS[:notice])
        notice_elem.clear
        notice_elem.send_keys('.')
      end

      private

      def may_find_element(*args)
        @driver.find_element(*args)
      rescue Selenium::WebDriver::Error::NoSuchElementError
        nil
      end
    end
  end
end
