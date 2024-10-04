class Admin::Projects::Phases::EditComponent < ApplicationComponent
  include Header
  attr_reader :project, :project_phase

  def initialize(project, project_phase)
    @project_phase = project_phase
    @project = project
  end

  def title
    @project_phase.short_title
  end
end
