class MapLocation < ApplicationRecord
  belongs_to :proposal, touch: true
  belongs_to :investment, class_name: "Budget::Investment", touch: true

  validates :longitude, :latitude, :zoom, presence: true, numericality: true

  def available?
    latitude.present? && longitude.present? && zoom.present?
  end

  def json_data
    {
      investment_id: investment_id,
      proposal_id: proposal_id,
      lat: latitude,
      long: longitude
    }
  end

  def self.from_heading(heading)
    new(
      zoom: Budget::Heading::OSM_DISTRICT_LEVEL_ZOOM,
      latitude: (heading.latitude.to_f if heading.latitude.present?),
      longitude: (heading.longitude.to_f if heading.longitude.present?)
    )
  end

  def self.investments_json_data(investments)
    return [] unless investments.any?

    budget_id = investments.first.budget_id

    data = investments.joins(:map_location)
                      .with_fallback_translation
                      .pluck(:id, :title, :latitude, :longitude)

    data.map do |values|
      {
        title: values[1],
        link: "/budgets/#{budget_id}/investments/#{values[0]}",
        lat: values[2],
        long: values[3]
      }
    end
  end
end
