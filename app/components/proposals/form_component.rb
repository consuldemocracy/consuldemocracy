class Proposals::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :proposal, :url
  use_helpers :current_user, :suggest_data, :geozone_select_options

  def initialize(proposal, url:)
    @proposal = proposal
    @url = url
  end

  private

    def categories
      Tag.category.order(:name)
    end
end
