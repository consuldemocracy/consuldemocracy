class MapLocation < ApplicationRecord
  belongs_to :proposal, class_name: "Proposal", touch: true
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
  
  def self.from_settings
    latitude_setting = Setting.find_by(key: "map.latitude")
    longitude_setting = Setting.find_by(key: "map.longitude")
    zoom_setting = Setting.find_by(key: "map.zoom")
    new(
      zoom: zoom_setting,
      latitude: (latitude_setting.value.to_f if latitude_setting&.value.present?),
      longitude: (longitude_setting.value.to_f if longitude_setting&.value.present?)
    )
  end
  
  def self.investments_json_data(investments)
    return [] if investments.none?

    budget_id = investments.first.budget_id

    data = investments.joins(:map_location)
                      .with_fallback_translation
                      .pluck(:id, :title, :latitude, :longitude)
    Rails.logger.info "Proposals data: #{data.inspect}"

    data.map do |values|
      {
        title: values[1],
        link: "/budgets/#{budget_id}/investments/#{values[0]}",
        lat: values[2],
        long: values[3]
      }
    end
  end

  def self.proposals_json_data(proposals)
    return [] if proposals.none?
    Rails.logger.info "Inside proposals_json_data #{proposals.inspect}"

    data = proposals.joins(:map_location)
                    .with_fallback_translation 
                    .pluck(:id, :title, :latitude, :longitude) 
        
    data.map do |values|
      {
        title: values[1],
        link: "/proposals/#{values[0]}", 
        lat: values[2],
        long: values[3]
      }
    end
  end

end
