module Admin::ManagesProposalSettings
  extend ActiveSupport::Concern

  included do
    def successful_proposal_setting
      @successful_proposal_setting ||= Setting.find_by(key: "proposals.successful_proposal_id")
    end

    def successful_proposals
      Proposal.successful
    end

    def poll_feature_short_title_setting
      @poll_feature_short_title_setting ||= Setting.find_by(key: "proposals.poll_short_title")
    end

    def poll_feature_description_setting
      @poll_feature_description_setting ||= Setting.find_by(key: "proposals.poll_description")
    end

    def poll_feature_link_setting
      @poll_feature_link_setting ||= Setting.find_by(key: "proposals.poll_link")
    end

    def email_feature_short_title_setting
      @email_feature_short_title_setting ||= Setting.find_by(key: "proposals.email_short_title")
    end

    def email_feature_description_setting
      @email_feature_description_setting ||= Setting.find_by(key: "proposals.email_description")
    end

    def poster_feature_short_title_setting
      @poster_feature_short_title_setting ||= Setting.find_by(key: "proposals.poster_short_title")
    end

    def poster_feature_description_setting
      @poster_feature_description_setting ||= Setting.find_by(key: "proposals.poster_description")
    end
  end
end
