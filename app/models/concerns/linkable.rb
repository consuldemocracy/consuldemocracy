module Linkable
  extend ActiveSupport::Concern

  included do
    delegate :url_helpers, to: "Rails.application.routes"
  end

  module ClassMethods
    attr_reader :nested_link_params, :nested_link_route

    private

    def nested_linkable_with(*nested_link_params, **route)
      @nested_link_params = nested_link_params
      @nested_link_route = route[:route]
    end
  end

  def url
    host = ActionMailer::Base.default_url_options[:host]
    url_helpers.send(:"#{self.route}_url", *link_params, self, host: host)
  end

  def path
    url_helpers.send(:"#{self.route}_path", *link_params, self)
  end

  def route
    self.class.nested_link_route.presence || self.class.name.parameterize('_')
  end

  def link_params
    self.class.nested_link_params.to_a.flatten.map { |nested_link_param| send(nested_link_param) }
  end
end
