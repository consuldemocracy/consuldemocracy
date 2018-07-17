require 'rails_helper'
require 'rake'

describe 'Communities Rake' do
  before do
    Rake.application.rake_require "tasks/communities"
    Rake::Task.define_task(:environment)
  end

  describe '#associate_community' do

    let :run_rake_task do
      Rake::Task['communities:associate_community'].reenable
      Rake.application.invoke_task 'communities:associate_community'
    end

    context 'Associate community to Proposal' do

      it 'When proposal has not community_id' do
        proposal = create(:proposal)
        proposal.update(community: nil)
        expect(proposal.community).to be_nil

        run_rake_task
        proposal.reload

        expect(proposal.community).to be_present
      end
    end

    context 'Associate community to Budget Investment' do

      it 'When budget investment has not community_id' do
        investment = create(:budget_investment)
        investment.update(community: nil)
        expect(investment.community).to be_nil

        run_rake_task
        investment.reload

        expect(investment.community).to be_present
      end

    end

  end

  describe "#migrate_communitable" do
    let :run_rake_task do
      Rake::Task["communities:migrate_communitable"].reenable
      Rake.application.invoke_task "communities:migrate_communitable"
    end

    context "Associate community to Proposal" do
      let(:proposal) { create(:proposal) }
      let(:community) { proposal.community }

      context "Community has no communitable_id" do
        before { community.update(communitable_id: nil, communitable_type: nil) }

        it "assigns the communitable_id" do
          run_rake_task
          community.reload
          expect(community.communitable_id).to eq proposal.id
          expect(community.communitable_type).to eq "Proposal"
        end
      end

      context "Proposal has no community_id" do
        before { proposal.update_column(:community_id, nil) }

        it "writes a warning with the proposal id" do
          warning = /Proposal(.+)#{proposal.id}(.+)should have an associated/
          expect { run_rake_task }.to output(warning).to_stderr
        end
      end

      context "The proposal community doesn't exist anymore" do
        before { community.destroy }

        it "writes a warning with the proposal id" do
          warning = /community(.+)Proposal(.+)#{proposal.id}(.+)no longer exists/
          expect { run_rake_task }.to output(warning).to_stderr
        end
      end
    end

    context "Associate community to Budget Investment" do
      let(:investment) { create(:budget_investment) }
      let(:community) { investment.community }

      context "Community has no communitable_id" do
        before { community.update(communitable_id: nil, communitable_type: nil) }

        it "assigns the communitable_id" do
          run_rake_task
          community.reload
          expect(community.communitable_id).to eq investment.id
          expect(community.communitable_type).to eq "Budget::Investment"
        end
      end

      context "Investment has no community_id" do
        before { investment.update_column(:community_id, nil) }

        it "writes a warning with the investment id" do
          warning = /Investment(.+)#{investment.id}(.+)should have an associated/
          expect { run_rake_task }.to output(warning).to_stderr
        end
      end

      context "The investment community doesn't exist anymore" do
        before { community.destroy }

        it "writes a warning with the investment id" do
          warning = /community(.+)Investment(.+)#{investment.id}(.+)no longer exists/
          expect { run_rake_task }.to output(warning).to_stderr
        end
      end
    end

  end
end
