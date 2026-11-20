class UserDeduplicator
  attr_reader :user, :duplicate_user

  def initialize(user, duplicate_user)
    @user = user
    @duplicate_user = duplicate_user
  end

  def deduplicate
    ActiveRecord::Base.transaction do
      take_votes
      take_debates
      take_proposals_data
      take_budgets_data
      take_signatures_data
      take_legislation_data
      take_polls_data
      take_comments
      take_attachments
      take_direct_messages
      take_activities
      take_audits
      take_follows
      take_topics
      take_related_contents
      take_flags
      take_dashboard_tasks
      take_failed_census_calls
      take_notifications
      take_visits
      take_identities
      take_organization
      take_lock
      take_roles

      data_log = "id: #{duplicate_user.id} - #{Time.current.strftime("%Y-%m-%d %H:%M:%S")}"
      user.update_column(:former_users_data_log, "#{user.former_users_data_log} | #{data_log}")

      duplicate_user.delete
    end
  end

  private

    def take_votes
      user.take_votes_from(duplicate_user, log: false)
    end

    def take_debates
      Debate.with_hidden.where(author_id: duplicate_user.id).update_all(author_id: user.id)
    end

    def take_proposals_data
      Proposal.with_hidden.where(author_id: duplicate_user.id).update_all(author_id: user.id)
      ProposalNotification.with_hidden.where(author_id: duplicate_user.id).update_all(author_id: user.id)
    end

    def take_budgets_data
      Budget::Investment.with_hidden.where(author_id: duplicate_user.id).update_all(author_id: user.id)
      Budget::ReclassifiedVote.where(user_id: duplicate_user.id).update_all(user_id: user.id)
    end

    def take_signatures_data
      Signature.where(user_id: duplicate_user.id).update_all(user_id: user.id)
      SignatureSheet.where(author_id: duplicate_user.id).update_all(author_id: user.id)
    end

    def take_legislation_data
      Legislation::Annotation.with_hidden.where(author_id: duplicate_user.id).update_all(author_id: user.id)
      Legislation::Answer.with_hidden.where(user_id: duplicate_user.id).update_all(user_id: user.id)
      Legislation::Proposal.with_hidden.where(author_id: duplicate_user.id).update_all(author_id: user.id)
      Legislation::Question.with_hidden.where(author_id: duplicate_user.id).update_all(author_id: user.id)
    end

    def take_polls_data
      Poll.with_hidden.where(author_id: duplicate_user.id).update_all(author_id: user.id)
      Poll::Answer.where(author_id: duplicate_user.id).find_each do |poll_answer|
        ActiveRecord::Base.transaction(requires_new: true) do
          poll_answer.update_column(:author_id, user.id)
        end
      rescue ActiveRecord::RecordNotUnique
        poll_answer.delete
      end
      Poll::PartialResult.where(author_id: duplicate_user.id).update_all(author_id: user.id)
      Poll::Question.with_hidden.where(author_id: duplicate_user.id).update_all(author_id: user.id)
      Poll::Recount.where(author_id: duplicate_user.id).update_all(author_id: user.id)
    end

    def take_comments
      Comment.with_hidden.where(user_id: duplicate_user.id).update_all(user_id: user.id)
    end

    def take_attachments
      Document.where(user_id: duplicate_user.id).update_all(user_id: user.id)
      Image.where(user_id: duplicate_user.id).update_all(user_id: user.id)
    end

    def take_direct_messages
      DirectMessage.where(sender_id: duplicate_user.id).update_all(sender_id: user.id)
      DirectMessage.where(receiver_id: duplicate_user.id).update_all(receiver_id: user.id)
    end

    def take_activities
      Activity.where(user_id: duplicate_user.id).update_all(user_id: user.id)
      Activity.where(actionable_type: "User", actionable_id: duplicate_user.id)
              .update_all(actionable_id: user.id)
    end

    def take_audits
      Audit.where(user_id: duplicate_user.id, user_type: "User").update_all(user_id: user.id)
      Audit.where(auditable_type: "User", auditable_id: duplicate_user.id)
           .update_all(auditable_id: user.id)
    end

    def take_follows
      Follow.where(followable_type: "User", followable_id: duplicate_user.id)
            .update_all(followable_id: user.id)
      Follow.where(user_id: duplicate_user.id).update_all(user_id: user.id)
    end

    def take_topics
      Topic.with_hidden.where(author_id: duplicate_user.id).update_all(author_id: user.id)
    end

    def take_related_contents
      RelatedContent.with_hidden.where(author_id: duplicate_user.id).update_all(author_id: user.id)
      RelatedContentScore.where(user_id: duplicate_user.id).find_each do |score|
        ActiveRecord::Base.transaction(requires_new: true) do
          score.update_column(:user_id, user.id)
        end
      rescue ActiveRecord::RecordNotUnique
        related_content = score.related_content
        related_content.class.decrement_counter(:related_content_scores_count, related_content.id)
        score.delete
      end
    end

    def take_flags
      Flag.where(user_id: duplicate_user.id).update_all(user_id: user.id)
    end

    def take_dashboard_tasks
      Dashboard::AdministratorTask.where(user_id: duplicate_user.id).update_all(user_id: user.id)
    end

    def take_failed_census_calls
      FailedCensusCall.where(user_id: duplicate_user.id).update_all(user_id: user.id)
      User.reset_counters(user.id, :failed_census_calls)
    end

    def take_notifications
      Notification.where(user_id: duplicate_user.id).update_all(user_id: user.id)
      User.reset_counters(user.id, :notifications)
    end

    def take_visits
      Visit.where(user_id: duplicate_user.id).update_all(user_id: user.id)
    end

    def take_identities
      Identity.where(user_id: duplicate_user.id).find_each do |identity|
        if Identity.exists?(user_id: user.id, provider: identity.provider, uid: identity.uid)
          identity.delete
        else
          identity.update_column(:user_id, user.id)
        end
      end
    end

    def take_organization
      duplicate_organization = Organization.find_by(user_id: duplicate_user.id)

      if duplicate_organization
        if Organization.exists?(user_id: user.id)
          duplicate_organization.delete
        else
          duplicate_organization.update_column(:user_id, user.id)
        end
      end
    end

    def take_lock
      duplicate_lock = Lock.find_by(user_id: duplicate_user.id)

      if duplicate_lock
        if Lock.exists?(user_id: user.id)
          duplicate_lock.delete
        else
          duplicate_lock.update_column(:user_id, user.id)
        end
      end
    end

    def take_roles
      [Administrator, Valuator, Moderator, Manager, SDG::Manager, Poll::Officer].each do |role_class|
        duplicate_role = role_class.find_by(user_id: duplicate_user.id)
        next if duplicate_role.nil?

        role = role_class.find_by(user_id: user.id)

        if role
          RoleDeduplicator.new(role, duplicate_role).deduplicate
        else
          duplicate_role.update_column(:user_id, user.id)
        end
      end
    end
end
