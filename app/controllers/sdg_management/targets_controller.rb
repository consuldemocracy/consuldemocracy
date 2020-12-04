class SDGManagement::TargetsController < SDGManagement::BaseController
  Target = ::SDG::Target

  def index
    @targets = Target.all.sort
  end
end
