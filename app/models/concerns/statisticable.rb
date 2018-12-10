module Statisticable
  extend ActiveSupport::Concern

  included do
    attr_reader :resource

    def initialize(resource)
      @resource = resource
    end

    def generate
      stats_methods.map { |stat_name| [stat_name, send(stat_name)] }.to_h
    end
  end
end
