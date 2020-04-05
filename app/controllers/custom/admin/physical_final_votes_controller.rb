class Admin::PhysicalFinalVotesController < Admin::BaseController
  def index
    @physical_final_votes = PhysicalFinalVote.all
  end

  def new
    @physical_final_vote = PhysicalFinalVote.new
  end

  def create
    @physical_final_vote = PhysicalFinalVote.new(physical_final_vote_params)
    if Budget::Investment.where(id: physical_final_vote_params[:signable_id]).present?
      if @physical_final_vote.save
        redirect_to [:admin, @physical_final_vote], notice: I18n.t("flash.actions.create.physical_final_vote")
      else
        render :new
      end
    else
      redirect_to new_admin_physical_final_vote_path, flash: { error: t("admin.physical_final_votes.new.error") }
    end
  end

  def show
    @physical_final_vote = PhysicalFinalVote.find(params[:id])
  end

  def destroy
    @physical_final_vote = PhysicalFinalVote.find(params[:id])

    @physical_final_vote.destroy if @physical_final_vote.present?

    redirect_to admin_physical_final_votes_path, notice: t("admin.physical_final_votes.flash.destroyed")
  end

  private

    def physical_final_vote_params
      params.require(:physical_final_vote).permit(:signable_type, :signable_id, :total_votes, :booth)
    end
end
