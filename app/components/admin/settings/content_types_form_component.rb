class Admin::Settings::ContentTypesFormComponent < ApplicationComponent
  attr_reader :setting
  delegate :dom_id, to: :helpers

  def initialize(setting)
    @setting = setting
  end
end
