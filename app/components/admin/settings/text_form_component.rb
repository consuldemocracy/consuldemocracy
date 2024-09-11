class Admin::Settings::TextFormComponent < ApplicationComponent
  attr_reader :setting, :tab
  use_helpers :dom_id

  def initialize(setting, tab: nil)
    @setting = setting
    @tab = tab
  end
end
