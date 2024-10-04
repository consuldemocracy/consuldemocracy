require "rails_helper"

describe Admin::Projects::IndexComponent, controller: Admin::ProjectsController do

  describe "list projects" do
    it "list draft project" do
      project = create(:project, title: "A project")

      render_inline Admin::Projects::IndexComponent.new(Project.all)

      expect(page.find("tr", text: "A project")).to have_content "Draft"
    end
  end

end
