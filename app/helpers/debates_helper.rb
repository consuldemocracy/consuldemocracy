module DebatesHelper

  def has_featured?
    Debate.all.featured.count > 0
  end

end