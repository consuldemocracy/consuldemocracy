class Admin::Settings::MapFormComponent < ApplicationComponent
  attr_reader :tab

  def initialize(tab: nil)
    @tab = tab
  end
end
