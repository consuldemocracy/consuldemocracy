class Admin::SiteCustomization::Pages::IndexComponent < ApplicationComponent
  attr_reader :pages

  def initialize(pages)
    @pages = pages
  end
end
