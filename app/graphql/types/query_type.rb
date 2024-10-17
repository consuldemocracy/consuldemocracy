module Types
  class QueryType < Types::BaseObject
    def self.connection_and_id_fields(name, type)
      connection_field name.to_s.pluralize.to_sym, type, "Returns all #{name.to_s.pluralize}", null: false
      id_field name, type, "Returns #{name.to_s.capitalize}", null: false
    end

    connection_and_id_fields :budget, Types::BudgetType
    connection_and_id_fields :comment, Types::CommentType
    connection_and_id_fields :debate, Types::DebateType
    connection_and_id_fields :geozone, Types::GeozoneType
    connection_and_id_fields :milestone, Types::MilestoneType
    connection_and_id_fields :proposal, Types::ProposalType
    connection_and_id_fields :proposal_notification, Types::ProposalNotificationType
    connection_and_id_fields :tag, Types::TagType
    connection_and_id_fields :user, Types::UserType
    connection_and_id_fields :vote, Types::VoteType

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
