class API::Tagging

  attr_accessor :tagging

  def initialize(id)
    @tagging = ::Tagging.find(id)
  end

  def self.public_columns
    ["tag_id",
     "taggable_id",
     "taggable_type"]
  end

  def public?
    return false unless ["Proposal", "Debate"].include? (tagging.taggable_type)
    return false if tagging.taggable.hidden?
    return false unless API::Tag.new(tagging.tag_id).public?
    return true
  end

end

# * COMPROBAR campo "taggable_type".Se incluirán los taggings con taggable_type tipo “Proposal” o “Debate”.
# * COMPROBAR campo "taggable_id". Si el elemento del que depende (proposal o debate) no está incluido públicamente por estar oculto u otra razón, no se incluirá el comentario aquí.
# * COMPROBAR campo “tag_id”. Se incluyen sólo las tags que se incluyan en la anterior tabla tags.