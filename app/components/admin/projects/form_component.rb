class Admin::Projects::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  include Header
  attr_reader :project, :action

  def initialize(project, action)
    @project = project
    @action = action
  end

  def title
    project.title
  end
end
