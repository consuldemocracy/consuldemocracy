class Admin::Settings::MapFormComponent < ApplicationComponent
  attr_reader :tab
  delegate :include_javascript_in_layout, to: :helpers

  def initialize(tab: nil)
    @tab = tab
  end
end
