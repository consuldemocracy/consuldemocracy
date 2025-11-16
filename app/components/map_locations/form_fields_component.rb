class MapLocations::FormFieldsComponent < ApplicationComponent
  attr_reader :form, :map_location, :label, :help
  use_helpers :render_map

  def initialize(form, map_location:, label:, help:)
    @form = form
    @map_location = map_location
    @label = label
    @help = help
  end

  def render?
    feature?(:map)
  end
end
