class Admin::Dashboard::Actions::FormComponent < ApplicationComponent
  attr_reader :dashboard_action, :url_action

  def initialize(dashboard_action, url_action:)
    @dashboard_action = dashboard_action
    @url_action = url_action
  end
end
