class Management::ProposalsController < Management::BaseController
  include HasOrders
  include CommentableActions

  before_action :check_verified_user, except: :print

  before_action :set_proposal, only: :vote
  before_action :parse_search_terms, only: :index

  has_orders %w{hot_score confidence_score created_at most_commented random}, only: [:index, :print]

  def vote
    @proposal.register_vote(current_user, 'yes')
    set_proposal_votes(@proposal)
  end

  def print
    @proposals = Proposal.all.page(params[:page]).for_render.send("sort_by_#{@current_order}")
    set_proposal_votes(@proposal)
  end

  private

    def set_proposal
      @proposal = Proposal.find(params[:id])
    end

    def proposal_params
      params.require(:proposal).permit(:title, :question, :summary, :description, :external_url, :video_url, :responsible_name, :tag_list, :terms_of_service, :captcha, :captcha_key)
    end

    def current_user
      #CHANGE ME
      #Should be user being managed
      User.last
    end

    def resource_model
      Proposal
    end

    def check_verified_user
      unless current_user.level_two_or_three_verified?
        redirect_to management_root_path, alert: 'User is not verified'
      end
    end

    #Duplicated in application_controller. Move to a concenrn.
    def set_proposal_votes(proposals)
      @proposal_votes = current_user ? current_user.proposal_votes(proposals) : {}
    end

end