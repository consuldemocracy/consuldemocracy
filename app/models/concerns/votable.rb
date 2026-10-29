module Votable
  extend ActiveSupport::Concern

  included do
    acts_as_votable

    def vote_by(...)
      transaction(requires_new: true) { super }
    rescue ActiveRecord::RecordNotUnique
      super
    end
  end
end
