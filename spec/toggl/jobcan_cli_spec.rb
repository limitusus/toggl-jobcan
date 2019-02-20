# frozen_string_literal: true

RSpec.describe Toggl::Jobcan::Cli do
  let(:cli_class) { Toggl::Jobcan::Cli }

  before do
    class JobcanMock
      class WebDriverMock
        def quit; end
      end

      def login; end

      def driver
        WebDriverMock.new
      end
    end
  end

  describe '#version' do
    it 'prints version with --version' do
      [
        ['version'],
        ['--version'],
        ['-v']
      ].each do |opts|
        expect(
          capture(:stdout) do
            cli_class.start(opts)
          end
        ).to match(/^Version \d/)
      end
    end
  end

  describe 'non-commands' do
    describe '#show_target_days' do
      it 'shows target days' do
        days = %w[
          20060102
          20060104
          20060105
          20060106
        ]
        expected_days = %w[
          2006-01-02
          2006-01-04
          2006-01-05
          2006-01-06
        ]
        expected_days_expr = expected_days.map do |d|
          "  - #{d}\n"
        end.join('')
        expect(
          capture(:stdout) do
            cli_class.start(['--days', *days])
          end
        ).to eq 'Target days:' + "\n" + expected_days_expr
      end
    end

    describe '#parse_args' do
      it 'raises NoDayGivenError when date is not passed' do
        expect do
          cli_class.start([])
        end.to raise_error Toggl::Jobcan::NoDayGivenError
      end
    end

    describe '#register_days' do
      let(:cli) { cli_class.new }
      let(:args) { [] }

      before do
        # Suppress warnings for testing
        class WrapIO < StringIO
          WARN_BEGIN_WITH = '[WARNING] Attempted to create command'
          def puts(str)
            super unless str.start_with?(WARN_BEGIN_WITH)
          end
        end
        $stdout = WrapIO.new
        allow_any_instance_of(cli_class).to receive(:jobcan) do
          JobcanMock.new
        end
        allow_any_instance_of(cli_class).to receive(:register_day) do |_cli, a|
          args.append(a)
        end
      end

      after do
        $stdout = STDOUT
      end

      it 'tries to register for given days' do
        days = %w[
          20060102
          20060104
          20060105
          20060106
        ]
        days_date = [
          Date.new(2006, 1, 2),
          Date.new(2006, 1, 4),
          Date.new(2006, 1, 5),
          Date.new(2006, 1, 6)
        ]
        cli_class.start(['main'] + days)
        expect(args).to eq days_date
      end
    end
  end
end
