module ImageAttributes
  extend ActiveSupport::Concern

  def image_attributes
    [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
  end
end
