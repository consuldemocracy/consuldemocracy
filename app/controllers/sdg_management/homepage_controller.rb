class SDGManagement::HomepageController < SDGManagement::BaseController
  def show
    @phases = SDG::Phase.accessible_by(current_ability).order(:kind)
    @card = WebSection.find_by!(name: "sdg").header
  end
end
