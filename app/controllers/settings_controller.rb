class SettingsController < ApplicationController
  #skip_authorization_check

  def proposal
    authorize! :read, Setting
    settings = Setting.all.group_by { |setting| setting.type }
    proposal_settings = settings["proposals"]
    render json: proposal_settings
  end
end
