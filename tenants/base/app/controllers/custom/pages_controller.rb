require_dependency Rails.root.join("app", "controllers", "pages_controller").to_s

class PagesController
  feature_flag :raad, if: lambda { params[:id] == "raad/index" }
end
