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

  def go_to_version
    version = @process.draft_versions.find(params[:draft_version_id])

    if params[:redirect_action] == 'changes'
      redirect_to legislation_process_draft_version_changes_path(@process, version)
    else
      redirect_to legislation_process_draft_version_path(@process, version)
    end
  end
end
