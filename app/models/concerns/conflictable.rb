module Conflictable
  extend ActiveSupport::Concern

  def conflictive?
    flags_count > 0 && cached_votes_up / flags_count.to_f < 5
  end
end
