class Project < ApplicationRecord
    has_many :page_on_projects
    has_many :pages, through: :page_on_projects

    attr_accessor :page_elements, :pages_ids

    # after_save :save_pages

    def destroy_component
        PageOnProject.where(project_id: self).destroy_all
    end

    def save_pages(page_elements)
        page_elements.each do |page_id|
            PageOnProject.find_or_create_by(project_id: self.id, site_customization_page_id: page_id)
        end
    end
end
