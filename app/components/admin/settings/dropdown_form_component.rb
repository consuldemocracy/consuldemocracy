class Admin::Settings::DropdownFormComponent < ApplicationComponent
  attr_reader :setting, :options, :tab, :disabled

  def initialize(setting, options:, tab: nil, disabled: false)
    @setting = setting
    @options = options
    @tab = tab
    @disabled = disabled
  end
end
