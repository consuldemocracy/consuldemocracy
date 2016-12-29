class API::Vote

  attr_accessor :vote

  def initialize(id)
    @vote = ::Vote.find(id)
  end

  def self.public_columns
    ["votable_id",
     "votable_type",
     "vote_flag",
     "created_at"]
  end

  def public_attributes
    vote.attributes.values_at(*API::Vote.public_columns)
  end

  def public?
    return false unless ["Proposal", "Debate", "Comment"].include? vote.votable_type
    return false if vote.votable.hidden?
    return true
  end

end

# * COMPROBAR campo "votable_type”. Se incluye el apoyo si se corresponde con uno de estos: "Comment", "Proposal", "Debate".
# * COMPROBAR campo "votable_id". Si el elemento del que depende no está incluido públicamente por estar oculto u otra razón, no se incluirá el apoyo aquí.
