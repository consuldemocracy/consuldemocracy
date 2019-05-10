module Communitable
  extend ActiveSupport::Concern

  included do
    belongs_to :community
    before_create :associate_community
  end

  def associate_community
    community = Community.create
    self.community_id = community.id
  end

end
