class Admin::DownloadSettingsController < Admin::BaseController
  before_action :load_resource
  before_action :load_download_settings

  def edit
  end

  def update
    @download_settings.each do |download_setting|
      download_setting.update(downloadable: params[:downloadable].include?(download_setting.field))
    end

    redirect_to edit_admin_download_setting_path(@download_resource)
  end

  private

    def load_resource
      @download_resource = params[:id]
    end

    def load_download_settings
      @download_settings = DownloadSetting.for(@download_resource)
    end
end
