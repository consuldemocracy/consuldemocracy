class WelcomeController < ApplicationController
  skip_authorization_check

  layout "devise", only: :welcome

  def index
    current_user ? (redirect_to :highlights) : public_home
  end

  def highlights
    debates = Debate.sort_by_hot_score.page(params[:page]).per(10).for_render
    set_debate_votes(debates)

    proposals = Proposal.sort_by_hot_score.page(params[:page]).per(10).for_render
    set_proposal_votes(proposals)

    @list = (debates.to_a + proposals.to_a).sort{|a, b| b.hot_score <=> a.hot_score}
    @paginator = debates.total_pages > proposals.total_pages ? debates : proposals

    render 'signed_in_home'
  end

  def welcome
  end

  private
    def public_home
      @featured_debates = Debate.sort_by_confidence_score.limit(3).for_render
      set_debate_votes(@featured_debates)

      @featured_proposals = Proposal.sort_by_confidence_score.limit(3).for_render
      set_proposal_votes(@featured_proposals)
    end


end
