class Admin::DebatesController < Admin::BaseController

  def index
    @debates = Debate.only_hidden
  end

  def show
    @debate = Debate.with_hidden.find(params[:id])
  end

  def restore
    @debate = Debate.with_hidden.find(params[:id])
    @debate.restore
    redirect_to admin_debates_path, notice: t('admin.debates.restore.success')
  end
end