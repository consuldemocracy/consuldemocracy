  class Proposals::MapComponent < ApplicationComponent
  
    attr_reader :heading, :proposals
    delegate :render_map, to: :helpers
    
    def initialize(proposals, heading: nil)
      @proposals = proposals
      Rails.logger.info "Proposals are #{proposals.inspect}"
    end

     def render?
      feature_enabled = feature?(:map)
    end

     def coordinates
      Rails.logger.info "Proposals data: #{proposals.inspect}"
      map_proposals = Proposal.published
      Rails.logger.info "Map Proposals data: #{map_proposals.inspect}"
      MapLocation.proposals_json_data(map_proposals)
    end
    
    def geozones_data
      # Extract unique geozone IDs from the proposals
      geozone_ids = @proposals.map(&:geozone_id).uniq
      geozones = Geozone.where(id: geozone_ids)
      geozones.map do |geozone|
        {
          outline_points: geozone.outline_points,
          color: geozone.color,
          headings: [geozone.name]
       #     link_to heading.name, budget_investments_path(budget, heading_id: heading.id)
       #   end
        }
      end
    end


  end



