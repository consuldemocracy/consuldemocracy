class Legislation::DraftVersionsController < Legislation::BaseController
  load_and_authorize_resource :process
  load_and_authorize_resource :draft_version, through: :process

  def index
  end

  def show
    @draft_versions_list = visible_draft_versions
    @draft_version = @draft_versions_list.find(params[:id])
  end

  def changes
    @draft_versions_list = visible_draft_versions
    @draft_version = @draft_versions_list.find(params[:draft_version_id])
  end

  def go_to_version
    version = visible_draft_versions.find(params[:draft_version_id])

    if params[:redirect_action] == "changes"
      redirect_to legislation_process_draft_version_changes_path(@process, version)
    elsif params[:redirect_action] == "annotations"
      redirect_to legislation_process_draft_version_annotations_path(@process, version)
    else
      redirect_to legislation_process_draft_version_path(@process, version)
    end
  end

  private

    def visible_draft_versions
      if current_user&.administrator?
        @process.draft_versions
      else
        @process.draft_versions.published
      end
    end
end
