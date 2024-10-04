class Admin::Projects::Phases::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  include Header
  attr_reader :project, :project_phase, :action

  def initialize(project, project_phase, action)
    @project_phase = project_phase
    @project = project
    @action = action
  end

  def title
    @project_phase.short_title
  end
end
