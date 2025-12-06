class Images::FieldsComponent < ApplicationComponent
  attr_reader :f, :imageable, :suggested_images_content

  def initialize(f, imageable:, suggested_images_content: nil)
    @f = f
    @imageable = imageable
    @suggested_images_content = suggested_images_content
  end
end
