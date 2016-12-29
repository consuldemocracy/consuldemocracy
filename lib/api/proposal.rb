class API::Proposal

  attr_accessor :proposal

  def initialize(id)
    @proposal = ::Proposal.find(id)
  end

  def self.public_columns
    ["id",
     "title",
     "description",
     "external_url",
     "cached_votes_up",
     "comments_count",
     "hot_score",
     "confidence_score",
     "created_at",
     "summary",
     "video_url",
     "geozone_id",
     "retired_at",
     "retired_reason",
     "retired_explanation",
     "proceeding",
     "sub_proceeding"]
  end

  def public_attributes
    proposal.attributes.values_at(*API::Proposal.public_columns)
  end

  def public?
    return false if proposal.hidden?
    return false unless ["Derechos Humanos", nil].include?(proposal.proceeding)
    return true
  end

end