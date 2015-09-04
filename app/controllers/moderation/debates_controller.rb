class Moderation::DebatesController < Moderation::BaseController
  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index

  before_action :load_debates, only: :index

  load_and_authorize_resource

  def index
    @debates = @debates.send(@current_filter).page(params[:page])
  end

  def hide
    @debate.hide
  end

  def hide_in_moderation_screen
    @debate.hide
    redirect_to request.query_parameters.merge(action: :index)
  end

  def ignore_flag
    @debate.ignore_flag
    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_debates
      @debates = Debate.accessible_by(current_ability, :hide).flagged.sort_for_moderation
    end

end
