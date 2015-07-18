class VotesController < ApplicationController
  before_action :set_debate
  before_action :authenticate_user!

  def create
    register_vote
    notice = @debate.vote_registered? ? "Gracias por votar." : "Tu voto ya ha sido registrado."
    redirect_to @debate, notice: notice
  end

  private

    def set_debate
      @debate = Debate.find(params[:debate_id])
    end  

    def register_vote
      @debate.vote_by voter: current_user, vote: params[:value]
    end
end
