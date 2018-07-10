class Admin::SettingsController < Admin::BaseController
  helper_method :successful_proposal_setting, :successful_proposals, :poll_feature_short_title_setting, :poll_feature_description_setting, :poll_feature_link_setting

  def index
    all_settings = Setting.all.group_by { |s| s.type }
    @settings = all_settings['common']
    @feature_flags = all_settings['feature']
    @banner_styles = all_settings['banner-style']
    @banner_imgs = all_settings['banner-img']
  end

  def update
    @setting = Setting.find(params[:id])
    @setting.update(settings_params)
    redirect_to request.referer, notice: t('admin.settings.flash.updated')
  end

  def update_map
    Setting['map_latitude'] = params[:latitude].to_f
    Setting['map_longitude'] = params[:longitude].to_f
    Setting['map_zoom'] = params[:zoom].to_i
    redirect_to admin_settings_path, notice: t('admin.settings.index.map.flash.update')
  end

  private

  def settings_params
    params.require(:setting).permit(:value)
  end

  def successful_proposal_setting
    Setting.find_by(key: 'proposals.successful_proposal_id')
  end

  def successful_proposals
    Proposal.successful
  end

  def poll_feature_short_title_setting
    Setting.find_by(key: 'proposals.poll_short_title')
  end

  def poll_feature_description_setting
    Setting.find_by(key: 'proposals.poll_description')
  end

  def poll_feature_link_setting
    Setting.find_by(key: 'proposals.poll_link')
  end
end
