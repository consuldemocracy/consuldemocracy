class Moderation::DebatesController < Moderation::BaseController
  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index
  has_orders %w{flags created_at}, only: :index

  before_action :load_debates, only: [:index, :moderate]

  load_and_authorize_resource

  def index
    @debates = @debates.send(@current_filter)
                       .send("sort_by_#{@current_order}")
                       .page(params[:page])
                       .per(50)
  end

  def hide
    hide_debate @debate
  end

  def moderate
    @debates = @debates.where(id: params[:debate_ids])

    if params[:hide_debates].present?
      @debates.accessible_by(current_ability, :hide).each {|debate| hide_debate debate}

    elsif params[:ignore_flags].present?
      @debates.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)

    elsif params[:block_authors].present?
      author_ids = @debates.pluck(:author_id).uniq
      User.where(id: author_ids).accessible_by(current_ability, :block).each(&:block)
    end

    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_debates
      @debates = Debate.accessible_by(current_ability, :moderate)
    end

    def hide_debate(debate)
      debate.hide
      Activity.log(current_user, :hide, debate)
    end

end
