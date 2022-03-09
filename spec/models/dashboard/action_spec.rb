require "rails_helper"

describe Dashboard::Action do
  subject do
    build :dashboard_action,
          title: "Take action!",
          description: description,
          day_offset: day_offset,
          required_supports: required_supports,
          request_to_administrators: request_to_administrators,
          action_type: action_type
  end

  let(:description) { Faker::Lorem.sentence }
  let(:day_offset) { 0 }
  let(:required_supports) { 0 }
  let(:request_to_administrators) { true }
  let(:action_type) { "resource" }

  it "is invalid when title is blank" do
    action = build(:dashboard_action, title: "")
    expect(action).not_to be_valid
  end

  it "is invalid when title is too short" do
    action = build(:dashboard_action, title: "abc")
    expect(action).not_to be_valid
  end

  it "is invalid when title is too long" do
    action = build(:dashboard_action, title: "a" * 81)
    expect(action).not_to be_valid
  end

  it "is invalid when day_offset is not defined" do
    action = build(:dashboard_action, day_offset: nil)
    expect(action).not_to be_valid
  end

  it "is invalid when day_offset is negative" do
    action = build(:dashboard_action, day_offset: -1)
    expect(action).not_to be_valid
  end

  it "is invalid when day_offset not an integer" do
    action = build(:dashboard_action, day_offset: 1.23)
    expect(action).not_to be_valid
  end

  it "is invalid when required_supports is nil" do
    action = build(:dashboard_action, required_supports: nil)
    expect(action).not_to be_valid
  end

  it "is invalid when required_supports is negative" do
    action = build(:dashboard_action, required_supports: -1)
    expect(action).not_to be_valid
  end

  it "is invalid when required_supports is not an integer" do
    action = build(:dashboard_action, required_supports: 1.23)
    expect(action).not_to be_valid
  end

  it "is invalid when action_type is nil" do
    action = build(:dashboard_action, action_type: nil)
    expect(action).not_to be_valid
  end

  describe "#active_for?" do
    it "is active when required supports is 0 and day_offset is 0" do
      action = build(:dashboard_action, required_supports: 0, day_offset: 0)
      proposal = build(:proposal)

      expect(action).to be_active_for(proposal)
    end

    it "is active when published after day_offset" do
      action = build(:dashboard_action, required_supports: 0, day_offset: 10)
      proposal = build(:proposal, published_at: Time.current - 10.days)

      expect(action).to be_active_for(proposal)
    end

    it "is active when have enough supports" do
      action = build(:dashboard_action, required_supports: 10, day_offset: 0)
      proposal = build(:proposal, cached_votes_up: 10)

      expect(action).to be_active_for(proposal)
    end

    it "is not active when not enough time published" do
      action = build(:dashboard_action, required_supports: 0, day_offset: 10)
      proposal = build(:proposal, published_at: Time.current - 9.days)

      expect(action).not_to be_active_for(proposal)
    end

    it "is not active when not enough supports" do
      action = build(:dashboard_action, required_supports: 10, day_offset: 0)
      proposal = build(:proposal, cached_votes_up: 9)

      expect(action).not_to be_active_for(proposal)
    end
  end

  describe "#requested_for?" do
    it "is not requested when no administrator task" do
      proposal = create(:proposal)
      action = create(:dashboard_action, :active, :admin_request, :resource)

      expect(action).not_to be_requested_for(proposal)
    end

    it "is requested when administrator task" do
      proposal = create(:proposal)
      action = create(:dashboard_action, :active, :admin_request, :resource)
      executed_action = create(:dashboard_executed_action, proposal: proposal, action: action)
      _task = create(:dashboard_administrator_task, :pending, source: executed_action)

      expect(action).to be_requested_for(proposal)
    end
  end

  describe "#executed_for?" do
    it "is not executed when no administrator task" do
      proposal = create(:proposal)
      action = create(:dashboard_action, :active, :admin_request, :resource)

      expect(action).not_to be_executed_for(proposal)
    end

    it "is not executed when pending administrator task" do
      proposal = create(:proposal)
      action = create(:dashboard_action, :active, :admin_request, :resource)
      executed_action = create(:dashboard_executed_action, proposal: proposal, action: action)
      _task = create(:dashboard_administrator_task, :pending, source: executed_action)

      expect(action).not_to be_executed_for(proposal)
    end

    it "is executed when done administrator task" do
      proposal = create(:proposal)
      action = create(:dashboard_action, :active, :admin_request, :resource)
      executed_action = create(:dashboard_executed_action, proposal: proposal, action: action)
      _task = create(:dashboard_administrator_task, :done, source: executed_action)

      expect(action).to be_executed_for(proposal)
    end
  end

  describe ".active_for" do
    let!(:active_action) { create :dashboard_action, :active, day_offset: 0, required_supports: 0 }
    let!(:inactive_action) { create :dashboard_action, :inactive }
    let!(:not_enough_supports_action) do
      create :dashboard_action, :active, day_offset: 0, required_supports: 10_000
    end

    let!(:future_action) do
      create :dashboard_action, :active, day_offset: 300, required_supports: 0
    end

    let!(:action_published_proposal) do
      create :dashboard_action,
             :active,
             day_offset: 0,
             required_supports: 0,
             published_proposal: true
    end

    let!(:action_for_draft_proposal) do
      create :dashboard_action,
             :active,
             day_offset: 0,
             required_supports: 0,
             published_proposal: false
    end

    let(:proposal) { create :proposal }
    let(:draft_proposal) { create :proposal, :draft }

    it "actions with enough supports or days are active" do
      expect(Dashboard::Action.active_for(proposal)).to include(active_action)
    end

    it "inactive actions are not included" do
      expect(Dashboard::Action.active_for(proposal)).not_to include(inactive_action)
    end

    it "actions without enough supports are not active" do
      expect(Dashboard::Action.active_for(proposal)).not_to include(not_enough_supports_action)
    end

    it "actions planned to be active in the future are not active" do
      expect(Dashboard::Action.active_for(proposal)).not_to include(future_action)
    end

    it "actions with published_proposal: true, are not included on draft proposal" do
      expect(Dashboard::Action.active_for(draft_proposal)).not_to include(action_published_proposal)
    end

    it "actions with published_proposal: true, are included on published proposal" do
      expect(Dashboard::Action.active_for(proposal)).to include(action_published_proposal)
    end

    it "actions with published_proposal: false, are included on draft proposal" do
      expect(Dashboard::Action.active_for(draft_proposal)).to include(action_for_draft_proposal)
    end

    it "actions with published_proposal: false, are included on published proposal" do
      expect(Dashboard::Action.active_for(proposal)).to include(action_for_draft_proposal)
    end
  end

  describe ".course_for" do
    let!(:proposed_action) { create :dashboard_action, :active, required_supports: 0 }
    let!(:inactive_resource) do
      create :dashboard_action, :inactive, :resource, required_supports: 0
    end
    let!(:resource) { create :dashboard_action, :active, :resource, required_supports: 10_000 }
    let!(:achieved_resource) { create :dashboard_action, :active, :resource, required_supports: 0 }
    let(:proposal) { create :proposal }

    it "proposed actions are not part of proposal's course" do
      expect(Dashboard::Action.course_for(proposal)).not_to include(proposed_action)
    end

    it "inactive resources are not part of proposal's course" do
      expect(Dashboard::Action.course_for(proposal)).not_to include(inactive_resource)
    end

    it "achievements are not part of the proposal's course" do
      expect(Dashboard::Action.course_for(proposal)).not_to include(achieved_resource)
    end

    it "active resources are part of proposal's course" do
      expect(Dashboard::Action.course_for(proposal)).to include(resource)
    end
  end

  describe ".detect_new_actions_since" do
    describe "No detect new actions" do
      let!(:action)   { create(:dashboard_action, :proposed_action, :active, day_offset: 1) }
      let!(:resource) { create(:dashboard_action, :resource, :active, day_offset: 1) }

      it "when there are not news actions actived for published proposals" do
        proposal = create(:proposal)
        action.update!(published_proposal: true)
        resource.update!(published_proposal: true)

        expect(Dashboard::Action.detect_new_actions_since(Date.yesterday, proposal)).to eq []
      end

      it "when there are news actions actived for draft_proposal but proposal is published" do
        proposal = create(:proposal)
        action.update!(published_proposal: false, day_offset: 0)
        resource.update!(published_proposal: false, day_offset: 0)

        expect(Dashboard::Action.detect_new_actions_since(Date.yesterday, proposal)).to eq []
      end

      it "when there are not news actions actived for draft proposals" do
        proposal = create(:proposal, :draft)
        action.update!(published_proposal: false)
        resource.update!(published_proposal: false)

        expect(Dashboard::Action.detect_new_actions_since(Date.yesterday, proposal)).to eq []
      end

      it "when there are news actions actived for published_proposal but proposal is draft" do
        proposal = create(:proposal, :draft)
        action.update!(published_proposal: true, day_offset: 0)
        resource.update!(published_proposal: true, day_offset: 0)

        expect(Dashboard::Action.detect_new_actions_since(Date.yesterday, proposal)).to eq []
      end
    end

    describe "Detect new actions when there are news actions actived" do
      context "for published proposals" do
        let!(:proposal) { create(:proposal) }

        let!(:action) do
          create(:dashboard_action, :proposed_action, :active, day_offset: 0, published_proposal: true)
        end

        let!(:resource) do
          create(:dashboard_action, :resource, :active, day_offset: 0, published_proposal: true)
        end

        it "when proposal has been created today and day_offset is valid only for today" do
          expect(Dashboard::Action.detect_new_actions_since(Date.yesterday,
                                                          proposal)).to include(resource.id)
          expect(Dashboard::Action.detect_new_actions_since(Date.yesterday,
                                                          proposal)).to include(action.id)
        end

        it "when proposal has received a new vote today" do
          proposal.update!(created_at: Date.yesterday, published_at: Date.yesterday)
          action.update!(required_supports: 1)
          resource.update!(required_supports: 0)
          create(:vote, voter: proposal.author, votable: proposal)

          expect(Dashboard::Action.detect_new_actions_since(Date.yesterday,
                                                          proposal)).to include(action.id)
          expect(Dashboard::Action.detect_new_actions_since(Date.yesterday,
                                                          proposal)).not_to include(resource.id)
        end
      end

      context "for draft proposals" do
        let!(:proposal) { create(:proposal, :draft) }

        let!(:action) do
          create(:dashboard_action, :proposed_action, :active, day_offset: 0, published_proposal: false)
        end

        let!(:resource) do
          create(:dashboard_action, :resource, :active, day_offset: 0, published_proposal: false)
        end

        it "when day_offset field is valid for today and invalid for yesterday" do
          expect(Dashboard::Action.detect_new_actions_since(Date.yesterday,
                                                          proposal)).to include(resource.id)
          expect(Dashboard::Action.detect_new_actions_since(Date.yesterday,
                                                          proposal)).to include(action.id)
        end

        it "when proposal has received a new vote today" do
          proposal.update!(created_at: Date.yesterday)
          action.update!(required_supports: 1)
          resource.update!(required_supports: 2)
          create(:vote, voter: proposal.author, votable: proposal)

          expect(Dashboard::Action.detect_new_actions_since(Date.yesterday,
                                                          proposal)).to include(action.id)
          expect(Dashboard::Action.detect_new_actions_since(Date.yesterday,
                                                          proposal)).not_to include(resource.id)
        end
      end
    end
  end
end
