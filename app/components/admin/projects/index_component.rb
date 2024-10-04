class Admin::Projects::IndexComponent < ApplicationComponent
  include Header
  attr_reader :projects

  def initialize(projects)
    @projects = projects
  end

  private

    def title
      t("admin.projects.index.title")
    end
end
