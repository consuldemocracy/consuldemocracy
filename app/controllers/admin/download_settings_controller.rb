class Admin::DownloadSettingsController < Admin::BaseController
  load_and_authorize_resource

  def edit
    permitted = downloadable_params
    @download_settings = []
    if permitted_models.include? permitted[:resource]
      set_edit(permitted[:resource])
    end
  end

  def update
    permitted = downloadable_params
    if permitted[:downloadable]
      @download_settings.each do |download_setting|
        download_setting.update(downloadable: permitted[:downloadable]
                                                .include?(download_setting.field))
      end
    end
    set_edit(permitted[:resource])
    render :edit, resource: permitted[:resource]
  end

  private

    def set_edit(resource)
      @download_resource = resource
      @download_settings = DownloadSetting.for(resource)
    end

    def permitted_models
      ["legislation_processes", "debates", "proposals", "budget_investments", "comments"]
    end

    def downloadable_params
      params.permit(:resource, downloadable: [])
    end
end
