class MedidasController < ApplicationController
  include CommentableActions
  include FlagActions

  before_action :parse_search_terms, only: :index
  before_action :parse_tag_filter, only: :index
  before_action :authenticate_user!, except: [:index, :show]

  has_orders %w{hot_score confidence_score created_at most_commented random}, only: :index

  load_and_authorize_resource
  respond_to :html, :js

  def vote
    @medida.register_vote(current_user, params[:value])
    set_medida_votes(@medida)
  end

  private

    def medida_params
      params.require(:medida).permit(:title, :description, :tag_list, :terms_of_service, :captcha, :captcha_key)
    end

    def resource_model
      Medida
    end

end
