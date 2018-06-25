require_dependency Rails.root.join('app', 'models', 'proposal').to_s

class Proposal < ActiveRecord::Base

    protected

    def set_responsible_name
      if author
        if author.document_number?
          self.responsible_name = author.document_number
        elsif self.responsible_name.blank?
          self.responsible_name = author.name
        end
      end
    end

end
