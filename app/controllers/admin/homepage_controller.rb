class Admin::HomepageController < Admin::BaseController

  def show
  end

  private

  def load_settings
    settings = /feature.homepage.widgets/
    @settings = Setting.select {|setting| setting.key =~ /#{settings}/ }
  end
end