class Pages::Help::SectionComponent < ApplicationComponent
  attr_reader :section, :image_path

  def initialize(section, image_path = nil)
    @section = section
    @image_path = image_path
  end
end
