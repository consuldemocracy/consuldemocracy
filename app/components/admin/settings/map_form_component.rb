class Admin::Settings::MapFormComponent < ApplicationComponent
  attr_reader :tab
  use_helpers :include_javascript_in_layout

  def initialize(tab: nil)
    @tab = tab
  end
end
