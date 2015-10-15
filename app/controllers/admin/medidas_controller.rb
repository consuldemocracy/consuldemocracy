class Admin::MedidasController < Admin::BaseController
  has_filters %w{without_confirmed_hide all with_confirmed_hide}, only: :index

  before_action :load_medida, only: [:confirm_hide, :restore]

  def index
    @medidas = Medida.only_hidden.send(@current_filter).order(hidden_at: :desc).page(params[:page])
  end

  def confirm_hide
    @medida.confirm_hide
    redirect_to request.query_parameters.merge(action: :index)
  end

  def restore
    @medida.restore
    @medida.ignore_flag
    Activity.log(current_user, :restore, @medida)
    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_medida
      @medida = Medida.with_hidden.find(params[:id])
    end

end
