require_dependency Rails.root.join('app', 'models', 'proposal').to_s

class Proposal

  # GET-104 Supports to likes
  def likes
    get_up_votes.count
  end

  def dislikes
    get_down_votes.count
  end

  def votable_by?(user)
    return false unless user
    return false unless user.level_two_or_three_verified?

    !user.unverified? || user.voted_for?(self)
  end
end