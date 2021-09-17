class Admin::PhysicalFinalVotesController < Admin::BaseController
  PER_PAGE = 10
  def index
    @physical_final_votes = physical_final_votes.page(params[:page]).per(PER_PAGE)
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
      def physical_final_votes
		physical_final_votes = PhysicalFinalVote.scoped_filter(params, @current_filter).order_filter(params)
		physical_final_votes = Kaminari.paginate_array(physical_final_votes) if physical_final_votes.is_a?(Array)
		physical_final_votes
                             #.sort_by_random(session[:random_seed])
        #if @current_order == "random"
        #  @budget.investments.apply_filters_and_search(@budget, params, @current_filter)
        #                     .sort_by_random(session[:random_seed])
        #else
        #  @budget.investments.apply_filters_and_search(@budget, params, @current_filter)
        #                     .send("sort_by_#{@current_order}")
        #end
      end
    def physical_final_vote_params
      params.require(:physical_final_vote).permit(:signable_type, :signable_id, :total_votes, :booth)
    end
end
