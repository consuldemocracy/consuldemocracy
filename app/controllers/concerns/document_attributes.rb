module DocumentAttributes
  extend ActiveSupport::Concern

  def document_attributes
    [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
  end
end
