class Projects::ShowComponent < ApplicationComponent
  include Header
  use_helpers :wysiwyg, :auto_link_already_sanitized_html
  attr_reader :project

  def initialize(project, active_phase)
    @project = project
    @active_phase = active_phase
  end

  private
  
	def format_date(date)
	l(date, format: "%d %b %Y") if date
	end

    def title
       @project.title
    end
end
