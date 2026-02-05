class Admin::Settings::ContentTypesFormComponent < ApplicationComponent
  attr_reader :setting, :tab
  delegate :dom_id, to: :helpers

  def initialize(setting, tab: nil)
    @setting = setting
    @tab = tab
  end
end
