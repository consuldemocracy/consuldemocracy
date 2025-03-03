class Shared::CheckAllNoneComponent < ApplicationComponent
  attr_reader :field_name

  def initialize(field_name = nil)
    @field_name = field_name
  end
end
