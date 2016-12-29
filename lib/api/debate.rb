class API::Debate

  attr_accessor :debate

  def initialize(id)
    @debate = ::Debate.find(id)
  end

  def self.public_columns
    ["id",
     "title",
     "description",
     "created_at",
     "cached_votes_total",
     "cached_votes_up",
     "cached_votes_down",
     "comments_count",
     "hot_score",
     "confidence_score"]
  end

  def public_attributes
    return [] unless public?

    debate.attributes.values_at(*API::Debate.public_columns)
  end

  def public?
    debate.hidden? ? false : true
  end

end

#* COMPROBAR campo "hidden_at". Si está oculto se excluye el debate del archivo.