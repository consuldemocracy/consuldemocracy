class Project < ApplicationRecord

    include PgSearch::Model

    # Configuración para la imagen
    has_attached_file :imagen
    validates_attachment :imagen,
                       content_type: { content_type: /\Aimage\/.*\z/ },
                       size: { less_than: 1.megabyte }

    pg_search_scope :global_search,
                    against: [:title],
                    using: { tsearch: { prefix: true } }

    has_many :page_on_projects
    has_many :pages, through: :page_on_projects

    has_many :debate_on_projects
    has_many :debates, through: :page_on_projects

    has_many :user_on_projects
    has_many :users, through: :user_on_projects

    has_many :proposal_on_projects
    has_many :proposals, through: :proposal_on_projects

    has_many :poll_on_projects
    has_many :polls, through: :poll_on_projects

    attr_accessor :page_elements, :page_ids

    attr_accessor :debate_elements, :debate_ids

    attr_accessor :user_elements, :user_ids

    attr_accessor :proposal_elements, :proposal_ids #new

    attr_accessor :poll_elements, :poll_ids #new

    attr_accessor :delete_page_elements, :delete_page_ids

    attr_accessor :delete_debate_elements, :delete_debate_ids

    attr_accessor :delete_user_elements, :delete_user_ids

    attr_accessor :delete_proposal_elements, :delete_proposal_ids #new

    attr_accessor :delete_poll_elements, :delete_poll_ids #new

    # after_save :save_pages

    def destroy_component
        PageOnProject.where(project_id: self).destroy_all
        DebateOnProject.where(project_id: self).destroy_all
        UserOnProject.where(project_id: self).destroy_all
        ProposalOnProject.where(project_id: self).destroy_all
        PollOnProject.where(project_id: self).destroy_all
    end

    def delete_component(delete_page_elements, delete_debate_elements, delete_user_elements, delete_proposal_elements, delete_poll_elements)

        # Borramos las páginas
        if !delete_page_elements.nil?
            delete_element = PageOnProject.where(project_id: self)
            delete_element.where(site_customization_page_id: delete_page_elements).destroy_all
        end

        # Borramos los debates
        if !delete_debate_elements.nil?
            delete_element = DebateOnProject.where(project_id: self)
            delete_element.where(debate_id: delete_debate_elements).destroy_all
        end

        # Borramos los usuarios
        if !delete_user_elements.nil?
            delete_element = UserOnProject.where(project_id:self)
            delete_element.where(user_id: delete_user_elements).destroy_all
        end

        # Borramos las propuestas
        if !delete_proposal_elements.nil?
            delete_element = ProposalOnProject.where(project_id:self)
            delete_element.where(proposal_id: delete_proposal_elements).destroy_all
        end

        # Borramos las votaciones
        if !delete_poll_elements.nil?
            delete_element = PollOnProject.where(project_id:self)
            delete_element.where(poll_id: delete_poll_elements).destroy_all
        end
    end

    def save_component(page_elements, debate_elements, user_elements, proposal_elements, poll_elements)

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

        # Guardamos las propuestas
        if !proposal_elements.nil?
            proposal_elements.each do |proposal_id|
                ProposalOnProject.find_or_create_by(project_id:self.id, proposal_id: proposal_id)
            end
        end

        # Guardamos las votaciones
        if !poll_elements.nil?
            poll_elements.each do |poll_id|
                PollOnProject.find_or_create_by(project_id: self.id, poll_id: poll_id)
            end
        end
    end

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
