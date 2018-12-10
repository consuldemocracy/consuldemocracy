module Statisticable
  extend ActiveSupport::Concern

  included do
    attr_reader :resource

    def initialize(resource)
      @resource = resource
    end

    def generate
      self.class.stats_methods.map { |stat_name| [stat_name, send(stat_name)] }.to_h
    end

    private

      def calculate_percentage(fraction, total)
        percent = fraction / total.to_f
        percent.nan? ? 0.0 : (percent * 100).round(3)
      end
  end

  class_methods do
    def stats_cache(*method_names)
      method_names.each do |method_name|
        alias_method :"raw_#{method_name}", method_name

        define_method method_name do
          stats_cache(method_name) { send(:"raw_#{method_name}") }
        end
      end
    end
  end
end
