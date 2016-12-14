class Legislation::DraftVersionsController < Legislation::BaseController
  load_and_authorize_resource :process
  load_and_authorize_resource :draft_version, through: :process

  def index
  end

  def show
  end

  def changes
    @draft_version = @process.draft_versions.find(params[:draft_version_id])
  end
end
