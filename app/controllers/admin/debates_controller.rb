class Admin::DebatesController < Admin::BaseController
  has_filters %w{all with_confirmed_hide}, only: :index

  before_filter :load_debate, only: [:confirm_hide, :restore]

  def index
    @debates = Debate.only_hidden.send(@current_filter).page(params[:page])
  end

  def confirm_hide
    @debate.confirm_hide
    redirect_to request.query_parameters.merge(action: :index)
  end

  def restore
    @debate.restore
    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_debate
      @debate = Debate.with_hidden.find(params[:id])
    end

end
