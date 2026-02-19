class Proposals::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  attr_reader :proposal, :url
  delegate :suggest_data, :geozone_select_options, :invisible_captcha, to: :helpers

  def initialize(proposal, url:)
    @proposal = proposal
    @url = url
  end

  private

    def categories
      Tag.category.order(:name)
    end

    def map_location
      proposal.map_location || MapLocation.new(proposal: Proposal.new)
    end
end
