module CommentsHelper

  def comment_link_text(parent)
    parent.class == Debate ? "Comentar" : "Responder"
  end

  def comment_button_text(parent)
    parent.class == Debate ? "Publicar comentario" : "Publicar respuesta"
  end

end