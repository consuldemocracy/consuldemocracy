require_dependency Rails.root.join('app', 'models', 'comment').to_s

class Comment
  validates_inclusion_of :commentable_type, in: ["Debate", "Proposal", "Budget::Investment", "Poll::Question", "Legislation::Question", "Legislation::Annotation", "ConsulAssemblies::Meeting"]

end
