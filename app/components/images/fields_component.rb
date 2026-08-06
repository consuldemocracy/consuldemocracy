class Images::FieldsComponent < ApplicationComponent
  attr_reader :f, :imageable

  def initialize(f, imageable:)
    @f = f
    @imageable = imageable
  end
end
