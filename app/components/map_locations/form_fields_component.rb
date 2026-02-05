class MapLocations::FormFieldsComponent < ApplicationComponent
  attr_reader :form, :map_location
  delegate :render_map, to: :helpers

  def initialize(form, map_location:)
    @form = form
    @map_location = map_location
  end

  def render?
    feature?(:map)
  end

  private

    def label
      t("proposals.form.map_location")
    end

    def help
      t("proposals.form.map_location_instructions")
    end
end
