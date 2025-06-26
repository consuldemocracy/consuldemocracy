class Dashboard::ResourcesComponent < ApplicationComponent
  attr_reader :active_resources

  def initialize(active_resources)
    @active_resources = active_resources
  end
end
