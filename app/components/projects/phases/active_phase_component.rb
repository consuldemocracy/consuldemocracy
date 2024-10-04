class Projects::Phases::ActivePhaseComponent < ApplicationComponent
  include Header
  use_helpers :wysiwyg, :auto_link_already_sanitized_html
  attr_reader :project_phase

  def initialize(project_phase)
    @project_phase = project_phase
    @project = project_phase.project
  end

  private
  
    def title
       @project_phase.title
    end
end
