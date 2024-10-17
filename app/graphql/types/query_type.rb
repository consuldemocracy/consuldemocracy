module Types
  class QueryType < Types::BaseObject
    field :budgets, Types::BudgetType.connection_type, "Returns all budgets", null: false
    object_by_id_field :budget, Types::BudgetType, "Returns budget for ID", null: false

    field :comments, Types::CommentType.connection_type, "Returns all comments", null: false
    object_by_id_field :comment, Types::CommentType, "Returns comment for ID", null: false

    field :debates, Types::DebateType.connection_type, "Returns all debates", null: false
    object_by_id_field :debate, Types::DebateType, "Returns debate for ID", null: false

    field :geozones, Types::GeozoneType.connection_type, "Returns all geozones", null: false
    object_by_id_field :geozone, Types::GeozoneType, "Returns geozone for ID", null: false

    field :milestones, Types::MilestoneType.connection_type, "Returns all milestones", null: false
    object_by_id_field :milestone, Types::MilestoneType, "Returns milestone for ID", null: false

    field :proposals, Types::ProposalType.connection_type, "Returns all proposals", null: false
    object_by_id_field :proposal, Types::ProposalType, "Returns proposal for ID", null: false

    field :proposal_notifications,
          Types::ProposalNotificationType.connection_type,
          "Returns all proposal notifications",
          null: false

    object_by_id_field :proposal_notification,
          Types::ProposalNotificationType,
          "Returns proposal notification for ID",
          null: false

    field :tags, Types::TagType.connection_type, "Returns all tags", null: false
    object_by_id_field :tag, Types::TagType, "Returns tag for ID", null: false

    field :users, Types::UserType.connection_type, "Returns all users", null: false
    object_by_id_field :user, Types::UserType, "Returns user for ID", null: false

    field :votes, Types::VoteType.connection_type, "Returns all votes", null: false
    object_by_id_field :vote, Types::VoteType, "Returns vote for ID", null: false

    def budgets
      Budget.public_for_api
    end

    def budget(id:)
      budgets.find(id)
    end

    def comments
      Comment.public_for_api
    end

    def comment(id:)
      comments.find(id)
    end

    def debates
      Debate.public_for_api
    end

    def debate(id:)
      debates.find(id)
    end

    def geozones
      Geozone.public_for_api
    end

    def geozone(id:)
      geozones.find(id)
    end

    def milestones
      Milestone.public_for_api
    end

    def milestone(id:)
      milestones.find(id)
    end

    def proposals
      Proposal.public_for_api
    end

    def proposal(id:)
      proposals.find(id)
    end

    def proposal_notifications
      ProposalNotification.public_for_api
    end

    def proposal_notification(id:)
      proposal_notifications.find(id)
    end

    def tags
      Tag.public_for_api
    end

    def tag(id:)
      tags.find(id)
    end

    def users
      User.public_for_api
    end

    def user(id:)
      users.find(id)
    end

    def votes
      Vote.public_for_api
    end

    def vote(id:)
      votes.find(id)
    end
  end
end
