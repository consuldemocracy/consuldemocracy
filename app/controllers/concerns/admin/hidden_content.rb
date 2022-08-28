module Admin::HiddenContent
  extend ActiveSupport::Concern
  include Search

  included do
    has_filters %w[without_confirmed_hide all with_confirmed_hide], only: :index
  end

  def hidden_content(relation)
    records = relation.only_hidden
    records = records.search(@search_terms) if @search_terms.present?

    records.send(@current_filter).order(hidden_at: :desc).page(params[:page])
  end
end
