module Admin::HiddenContent
  extend ActiveSupport::Concern

  included do
    has_filters %w[without_confirmed_hide all with_confirmed_hide], only: :index
  end

  def hidden_content(relation)
    relation.only_hidden.send(@current_filter).order(hidden_at: :desc).page(params[:page])
  end
end
