require_dependency Rails.root.join("app", "controllers", "application_controller").to_s

class ApplicationController

  private
    def all_active_proposals
     	if params[:search]
    		Proposal.published().not_retired().not_archived().search(params[:search])
    	else
      		Proposal.published().not_retired().not_archived().all
	    end
    end
end
