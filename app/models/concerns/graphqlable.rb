module Graphqlable
  extend ActiveSupport::Concern

  def public_created_at
    created_at.change(min: 0)
  end
end
