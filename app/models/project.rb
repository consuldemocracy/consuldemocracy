class Project < ApplicationRecord

    include PgSearch::Model
  
    pg_search_scope :global_search,
                    against: [:title],
                    using: { tsearch: { prefix: true } }

    has_many :page_on_projects
    has_many :pages, through: :page_on_projects

    has_many :debate_on_projects
    has_many :debates, through: :page_on_projects

    has_many :user_on_projects
    has_many :users, through: :user_on_projects

    attr_accessor :page_elements, :pages_ids

    attr_accessor :debate_elements, :debate_ids

    attr_accessor :user_elements, :user_ids

    # after_save :save_pages

    def destroy_component
        PageOnProject.where(project_id: self).destroy_all
        DebateOnProject.where(project_id: self).destroy_all
        UserOnProject.where(project_id: self).destroy_all
    end

    # def save_pages(page_elements)
    #     if !page_elements.nil?
    #         page_elements.each do |page_id|
    #             PageOnProject.find_or_create_by(project_id: self.id, site_customization_page_id: page_id)
    #         end
    #     end
    # end

    def save_component(page_elements, debate_elements, user_elements)

        #Guardamos las páginas
        if !page_elements.nil?
            page_elements.each do |page_id|
                PageOnProject.find_or_create_by(project_id: self.id, site_customization_page_id: page_id)
            end
        end

        # Guardamos los debates
        if !debate_elements.nil?
            debate_elements.each do |debate_id|
                DebateOnProject.find_or_create_by(project_id: self.id, debate_id: debate_id)
            end
        end

        # Guardamos los usuarios
        if !user_elements.nil?
            user_elements.each do |user_id|
                UserOnProject.find_or_create_by(project_id: self.id, user_id: user_id)
            end
        end
        
    end

    # def save_users(user_elements)
    #     # Guardamos los usuarios
    #     if !user_elements.nil?
    #         user_elements.each do |user_id|
    #             UserOnProject.find_or_create_by(project_id: self.id, user_id: user_id)
    #         end
    #     end
    # end

    def self.search(search)
        if search
            projects = Project.where("title ilike ?", "%#{search}%")
            if projects.nil? || projects.empty?
                projects = Project.all
            else
                projects
            end
        else
            projects = Project.all
        end
        projects
    end
end
