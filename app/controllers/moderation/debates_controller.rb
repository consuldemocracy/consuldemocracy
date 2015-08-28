class Moderation::DebatesController < Moderation::BaseController
  before_filter :set_valid_filters, only: :index
  before_filter :parse_filter, only: :index
  before_filter :load_debates, only: :index

  load_and_authorize_resource

  def index
    @debates = @debates.send(@filter)
    @debates = @debates.page(params[:page])
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
      @debates = Debate.accessible_by(current_ability, :hide).flagged.sorted_for_moderation
    end

    def set_valid_filters
      @valid_filters = %w{all pending_flag_review with_ignored_flag}
    end

    def parse_filter
      @filter = params[:filter]
      @filter = 'all' unless @valid_filters.include?(@filter)
    end

end
