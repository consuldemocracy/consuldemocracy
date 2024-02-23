class Admin::Organizations::TableActionsComponent < ApplicationComponent
  use_helpers :can?
  attr_reader :organization

  def initialize(organization)
    @organization = organization
  end

  private

    def can_verify?
      can? :verify, organization
    end

    def can_reject?
      can? :reject, organization
    end
end
