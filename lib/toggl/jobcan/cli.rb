# frozen_string_literal: true

require 'thor'
require 'optparse'
require 'ferrum'

module Toggl
  module Jobcan
    # CLI provider
    class Cli < Thor
      def self.exit_on_failure?
        true
      end

      package_name 'toggl-jobcan'
      default_command :main

      DEFAULT_JOBCAN_CREDENTIAL_FILE_PATH = "#{Dir.home}/.jobcan".freeze
      DEFAULT_TOGGL_WORKTIME_CONFIG_FILE_PATH = "#{Dir.home}/.toggl_worktime".freeze

      desc(
        '[options] DATE [DATE...]',
        'Register worktime in Toggl into Jobcan for the given dates ' \
        '("toggl-jobcan help main" for detailed usage)'
      )
      method_option(
        :tw_config,
        type: :string, aliases: '-c',
        default: DEFAULT_TOGGL_WORKTIME_CONFIG_FILE_PATH,
        banner: 'CONFIG', required: false,
        desc: 'configuration file for toggl_worktime'
      )
      method_option(
        :jc_credential,
        type: :string, aliases: '-r',
        default: DEFAULT_JOBCAN_CREDENTIAL_FILE_PATH,
        banner: 'CREDENTIAL', required: false,
        desc: 'credentials file for Jobcan'
      )
      method_option(
        :days,
        type: :boolean,
        default: false,
        desc: 'print days and exit'
      )
      method_option :dryrun, type: :boolean
      def main(*args)
        parse_args(args)
        puts '*** DRYRUN MODE ***' if options[:dryrun]

        show_target_days
        return if options[:days]

        prepare_jobcan

        puts 'Driver ready'
        register_days

        jobcan.driver.quit
        puts 'All Input finished'
      end

      map %w[--version -v] => :version
      desc 'version', 'Show version.'
      def version
        puts "Version #{Toggl::Jobcan::VERSION}"
      end

      no_commands do # rubocop:disable Metrics/BlockLength
        def initialize(*args)
          super
          @target_days = []
        end

        def parse_args(args)
          @target_days = args.map do |s|
            raise RangeError, "Invalid format #{s}" unless s.match?(/\d{8}/)

            Date.parse(s)
          end
          raise NoDayGivenError if @target_days.empty?
        end

        def prepare_jobcan
          @jc_credentials = Toggl::Jobcan::Credentials.new(
            path: options[:jc_credential]
          )
          jobcan.login
        end

        def jobcan
          @jobcan ||= Toggl::Jobcan::Client.new(
            credentials: @jc_credentials,
            toggl_worktime_config: options[:tw_config],
            dryrun: options[:dryrun]
          )
          @jobcan
        end

        def show_target_days
          puts 'Target days:'
          @target_days.each do |date|
            puts "  - #{date.strftime('%F')}"
          end
        end

        # To collect time entries in an API call, target days must be in a single month
        def validate_days_in_a_month
          day = @target_days.first
          y = day.year
          m = day.month
          return if @target_days.all? { |d| (d.year == y) && (d.month == m) }

          raise DifferentYearMonthError, "Different year/month=#{d.year}/#{d.month}"
        end

        def register_days
          validate_days_in_a_month
          working_times_map = jobcan.fetch_toggl_worktime(@target_days)
          @target_days.each do |date|
            register_day(working_times_map, date)
          end
        end

        def register_day(working_times_map, date)
          puts "Input date: #{date}"
          working_times = working_times_map[date.day]&.flatten
          if working_times.nil? || working_times.any?(&:nil?)
            puts 'Includes nil data: skip'
            return
          end
          jobcan.navigate_to_attendance_modify_day(date)
          jobcan.input_day_worktime(date, working_times)
          sleep 1
          puts "  - Finish: #{date}; Total time: #{jobcan.toggl.total_time(day: date.day)}"
        end
      end
    end

    class NoDayGivenError < StandardError; end
    class DifferentYearMonthError < StandardError; end
  end
end
