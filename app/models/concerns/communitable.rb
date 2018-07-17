module Communitable
  extend ActiveSupport::Concern

  included do
    has_one :community, as: :communitable
    before_create :associate_community
  end

  def associate_community
    community = Community.create
    self.community = community

    # TODO: remove once databases migrate to communitable columns.
    self.community_id = community.id
  end

end
