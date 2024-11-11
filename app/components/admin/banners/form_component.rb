class Admin::Banners::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :banner

  def initialize(banner)
    @banner = banner
  end

  private

    def sections
      WebSection.all
    end
end
