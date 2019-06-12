class Admin::DownloadSettingsController < Admin::BaseController
  include DownloadSettingsHelper

  load_and_authorize_resource

  def edit
    permitted =  downloadable_params
    @download_settings = []
    if permitted_models.include? permitted[:resource]
      set_edit(permitted[:resource])
    end
  end

  def update
    permitted =  downloadable_params
    if permitted[:downloadable]
      DownloadSetting.where(name_model: get_model(permitted[:resource]).to_s,
                            config: permitted[:config].to_i).each do |download_setting|
        download_setting.update(downloadable: permitted[:downloadable]
                                                .include?(download_setting.name_field))
      end
    end
    set_edit(permitted[:resource])
    render :edit, resource: permitted[:resource], config: permitted[:config]
  end

  private

    def set_edit(resource)
      @download_resource = {name: resource, config: get_config}
      @download_settings = get_attrs(get_model(resource), get_config)
    end

    def permitted_models
      ["legislation_processes", "debates", "proposals", "budget_investments", "comments"]
    end

    def downloadable_params
      params.permit(:resource,
                    :config,
                    downloadable: [])
    end
end
