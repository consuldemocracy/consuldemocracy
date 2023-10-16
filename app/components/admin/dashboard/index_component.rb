class Admin::Dashboard::IndexComponent < ApplicationComponent
  include Header

  def title
    t("admin.dashboard.index.title")
  end
end
