class Admin::BudgetHeadings::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :heading, :path, :action, :geozones

  def initialize(heading, path:, action:, geozones: [])
    @heading = heading
    @path = path
    @action = action
    @geozones = geozones
  end

  private

    def budget
      heading.budget
    end

    def single_heading?
      helpers.respond_to?(:single_heading?) && helpers.single_heading?
    end

    def geozone_options
      Geozone.all.map { |geozone| [geozone.name, geozone.id] }
    end
end
