class API::Comment

  attr_accessor :comment

  def initialize(id)
    @comment = ::Comment.find(id)
  end

  def self.public_columns
    ["id",
     "commentable_id",
     "commentable_type",
     "body",
     "created_at",
     "cached_votes_total",
     "cached_votes_up",
     "cached_votes_down",
     "ancestry",
     "confidence_score"]
  end

  def public?
    return false if comment.commentable.hidden?
    ["Proposal", "Debate"].include? comment.commentable_type
  end

end

#* COMPROBAR campo "hidden_at". Si está oculto se excluye el comentario del archivo.
#* COMPROBAR campo "commentable_id". Si el elemento del que depende (proposal o debate) no está incluido públicamente por estar oculto u otra razón, no se incluirá el comentario aquí.
#* COMPROBAR campo "commentable_type".Se incluirán los comments con commentable_type tipo “Proposal” o “Debate”