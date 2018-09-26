# frozen_string_literal: true

require 'yaml'

module Toggl
  module Jobcan
    # Jobcan credentials manager
    class Credentials
      attr_accessor :email
      attr_accessor :password

      ATTRS = %i[email password].freeze

      def initialize(args)
        attr_set(args) if args.key?(:email)
        c = self.class.load_config(args[:path])
        attr_set(c)
      end

      class << self
        def load_config(path)
          YAML.safe_load(File.open(path).read).transform_keys(&:to_sym)
        end
      end

      private

      def attr_set(hash)
        ATTRS.each { |k| send((k.to_s + '=').to_sym, hash[k]) }
      end
    end
  end
end
