class Admin::Projects::Phases::NewComponent < ApplicationComponent
  include Header
  attr_reader :project, :project_phase

  def initialize(project, project_phase)
    @project_phase = project_phase
    @project = project
  end

  def title
    t("admin.projects.phases.new.title")
  end
end
