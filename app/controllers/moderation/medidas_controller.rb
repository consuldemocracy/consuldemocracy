class Moderation::MedidasController < Moderation::BaseController
  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index
  has_orders %w{flags created_at}, only: :index

  before_action :load_medidas, only: [:index, :moderate]

  load_and_authorize_resource

  def index
    @medidas = @medidas.send(@current_filter)
                       .send("sort_by_#{@current_order}")
                       .page(params[:page])
                       .per(50)
  end

  def hide
    hide_medida @medida
  end

  def moderate
    @medidas = @medidas.where(id: params[:medida_ids])

    if params[:hide_medidas].present?
      @medidas.accessible_by(current_ability, :hide).each {|medida| hide_medida medida}

    elsif params[:ignore_flags].present?
      @medidas.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)

    elsif params[:block_authors].present?
      author_ids = @medidas.pluck(:author_id).uniq
      User.where(id: author_ids).accessible_by(current_ability, :block).each {|user| block_user user}
    end

    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_medidas
      @medidas = Medida.accessible_by(current_ability, :moderate)
    end

    def hide_medida(medida)
      medida.hide
      Activity.log(current_user, :hide, medida)
    end

    def block_user(user)
      user.block
      Activity.log(current_user, :block, user)
    end

end
