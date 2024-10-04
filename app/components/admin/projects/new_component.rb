class Admin::Projects::NewComponent < ApplicationComponent
  include Header
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def title
    t("admin.projects.new.title")
  end
end
