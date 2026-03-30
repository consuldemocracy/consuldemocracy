class Admin::Debates::IndexComponent < ApplicationComponent
  include Header

  attr_reader :debates

  def initialize(debates)
    @debates = debates
  end

  def title
    t("admin.debates.index.title")
  end
end
