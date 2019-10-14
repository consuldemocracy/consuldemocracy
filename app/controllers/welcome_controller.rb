class WelcomeController < ApplicationController
  skip_authorization_check

  layout "devise", only: [:welcome, :verification]
  before_action :index, :load_pages_in_cover
  before_action :welcome, :load_pages_in_cover

  def index

  end

  def welcome
  end

  def verification
    redirect_to verification_path if signed_in?
  end

  private

  def load_pages_in_cover
    @pages_in_cover = SiteCustomization::Page.with_show_in_cover_flag
  end
end
