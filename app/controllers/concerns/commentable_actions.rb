module CommentableActions
  extend ActiveSupport::Concern
  include Polymorphic
  include Search

  def edit
  end

  private

    def load_categories
      @categories = Tag.category.order(:name)
    end

    def search_and_filter(resources)
      resources = if @current_order == "recommendations" && current_user.present?
                    resources.recommendations(current_user)
                  else
                    resources.for_render
                  end
      resources = resources.search(@search_terms) if @search_terms.present?
      resources = resources.filter_by(@advanced_search_terms)

      resources.page(params[:page]).send("sort_by_#{@current_order}")
    end
end
