class SDGManagement::HomepageController < SDGManagement::BaseController
  def show
    @phases = SDG::Phase.accessible_by(current_ability).order(:kind)
  end
end
