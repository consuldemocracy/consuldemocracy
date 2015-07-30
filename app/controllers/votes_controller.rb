class VotesController < ApplicationController
  before_action :set_debate
  before_action :authenticate_user!
  respond_to :html, :js
  
  def create
    register_vote
    notice = @debate.vote_registered? ? I18n.t("votes.notice_thanks") : I18n.t("votes.notice_already_registered")
    respond_with @debate
  end

  private

    def set_debate
      @debate = Debate.find(params[:debate_id])
    end

    def register_vote
      @debate.vote_by voter: current_user, vote: params[:value]
    end
end
