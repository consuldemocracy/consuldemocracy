class ProposalsController < ApplicationController
  include Commentable
  include FlagActions

  before_action :parse_search_terms, only: :index
  before_action :parse_tag_filter, only: :index
  before_action :authenticate_user!, except: [:index, :show]

  has_orders %w{hot_score confidence_score created_at most_commented random}, only: :index

  load_and_authorize_resource
  respond_to :html, :js

  def vote
    @proposal.register_vote(current_user, 'yes')
    set_proposal_votes(@proposal)
  end

  private

    def proposal_params
      params.require(:proposal).permit(:title, :question, :summary, :description, :external_url, :video_url, :responsible_name, :tag_list, :terms_of_service, :captcha, :captcha_key)
    end

    def resource_model
      Proposal
    end
end
