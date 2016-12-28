class API::Proposal

  def self.public_columns
    ["id",
     "title",
     "description",
     "author_id",
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
    return [] unless public?

    attrs = attributes
    attrs["author_id"] = public_author_id

    attrs.values_at(*Proposal.public_columns)
  end

  def public_author_id
    author.public_activity? ? author.id  : nil
  end

  def public?
    return false if hidden?
    return false unless ["Derechos Humanos", nil].include?(proceeding)
    return true
  end

end