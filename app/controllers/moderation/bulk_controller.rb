class Moderation::BulkController < Moderation::BaseController

  def index
    @debates = Debate.sort_for_moderation.page(params[:page]).per(100).includes(:author)
  end

  def hide
    debates = Debate.where(id: params[:debate_ids])
    if params[:commit] == t('moderation.bulk.index.hide_debates')
      debates.each(&:hide)
    elsif params[:commit] == t('moderation.bulk.index.block_authors')
      debates.includes(:author).map(&:author).uniq.each(&:block)
    end

    redirect_to action: :index
  end

end
