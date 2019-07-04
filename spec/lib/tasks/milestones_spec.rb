require "rails_helper"

describe "Milestones tasks" do
  describe "#migrate" do
    let :run_rake_task do
      Rake::Task["milestones:migrate"].reenable
      Rake.application.invoke_task "milestones:migrate"
    end

    let!(:investment) { create(:budget_investment) }

    before do
      ActiveRecord::Base.connection.execute(
        "INSERT INTO budget_investment_statuses " +
        "(name, description, hidden_at, created_at, updated_at) " +
        "VALUES ('open', 'Good', NULL, '#{Time.current - 1.day}', '#{Time.current}');"
      )

      status_id = ActiveRecord::Base.connection.execute(
        "SELECT MAX(id) FROM budget_investment_statuses;"
      ).to_a.first["max"]

      milestone_attributes = {
        investment_id:     investment.id,
        title:             "First",
        description:       "Interesting",
        publication_date:  Date.yesterday,
        status_id:         status_id,
        created_at:        Time.current - 1.day,
        updated_at:        Time.current
      }

      ActiveRecord::Base.connection.execute(
        "INSERT INTO budget_investment_milestones " +
        "(#{milestone_attributes.keys.join(", ")}) " +
        "VALUES (#{milestone_attributes.values.map { |value| "'#{value}'"}.join(", ")})"
      )
    end

    it "migrates statuses" do
      run_rake_task

      expect(Milestone::Status.count).to be 1

      status = Milestone::Status.first
      expect(status.name).to eq "open"
      expect(status.description).to eq "Good"
      expect(status.hidden_at).to be nil
      expect(status.created_at.to_date).to eq Date.yesterday
      expect(status.updated_at.to_date).to eq Date.current
    end

    it "migrates milestones" do
      run_rake_task

      expect(Milestone.count).to be 1

      milestone = Milestone.first
      expect(milestone.milestoneable_id).to eq investment.id
      expect(milestone.milestoneable_type).to eq "Budget::Investment"
      expect(milestone.title).to eq "First"
      expect(milestone.description).to eq "Interesting"
      expect(milestone.publication_date).to eq Date.yesterday
      expect(milestone.status_id).to eq Milestone::Status.first.id
      expect(milestone.created_at.to_date).to eq Date.yesterday
      expect(milestone.updated_at.to_date).to eq Date.current
    end

    it "Updates the primary key sequence correctly" do
      run_rake_task
      expect { create(:milestone) }.not_to raise_exception
    end

    context "Milestone has images and documents" do
      let(:milestone_id) do
        ActiveRecord::Base.connection.execute(
          "SELECT MAX(id) FROM budget_investment_milestones;"
        ).to_a.first["max"]
      end

      let!(:image) do
        create(:image, imageable_id: milestone_id).tap do |image|
          image.update_column(:imageable_type, "Budget::Investment::Milestone")
        end
      end

      let!(:document) do
        create(:document, documentable_id: milestone_id).tap do |document|
          document.update_column(:documentable_type, "Budget::Investment::Milestone")
        end
      end

      it "migrates images and documents" do
        run_rake_task

        expect(Milestone.last.image).to eq image
        expect(Milestone.last.documents).to eq [document]
      end
    end

    context "Statuses had been deleted" do
      before do
        ActiveRecord::Base.connection.execute(
          "INSERT INTO budget_investment_statuses " +
          "(name, description, hidden_at, created_at, updated_at) " +
          "VALUES ('deleted', 'Del', NULL, '#{Time.current - 1.day}', '#{Time.current}');"
        )

        ActiveRecord::Base.connection.execute(
          "DELETE FROM budget_investment_statuses WHERE name='deleted'"
        )

        ActiveRecord::Base.connection.execute(
          "INSERT INTO budget_investment_statuses " +
          "(name, description, hidden_at, created_at, updated_at) " +
          "VALUES ('new', 'New', NULL, '#{Time.current - 1.day}', '#{Time.current}');"
        )

        status_id = ActiveRecord::Base.connection.execute(
          "SELECT MAX(id) FROM budget_investment_statuses;"
        ).to_a.first["max"]

        milestone_attributes = {
          investment_id:     investment.id,
          title:             "Last",
          description:       "Different",
          publication_date:  Date.yesterday,
          status_id:         status_id,
          created_at:        Time.current - 1.day,
          updated_at:        Time.current
        }

        ActiveRecord::Base.connection.execute(
          "INSERT INTO budget_investment_milestones " +
          "(#{milestone_attributes.keys.join(", ")}) " +
          "VALUES (#{milestone_attributes.values.map { |value| "'#{value}'"}.join(", ")})"
        )
      end

      it "migrates the status id correctly" do
        run_rake_task

        expect(Milestone.last.status_id).to eq Milestone::Status.last.id
      end
    end
  end
end
