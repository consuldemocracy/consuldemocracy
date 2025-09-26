class Admin::Settings::DropdownSettingComponent < ApplicationComponent
  attr_reader :setting, :options, :blank_option, :tab, :hint

  def initialize(setting, options:, blank_option: nil, tab: nil, hint: nil, onchange: nil)
    @setting = setting
    @options = options
    @blank_option = blank_option
    @tab = tab
    @hint = hint
  end

  def onchange
    "this.form.submit();"
  end
end
