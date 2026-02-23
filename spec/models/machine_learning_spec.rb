require "rails_helper"

RSpec.describe MachineLearning do
  let(:admin) { create(:administrator).user }
  let(:job) { create(:machine_learning_job, user: admin) }
  let(:ml_service) { MachineLearning.new(job) }
  let!(:proposal) { create(:proposal, title: "Clean the park", description: "It is dirty") }

  describe "#run" do
    context "when script is unknown" do
      it "raises an error and updates job" do
        job.update!(script: "invalid_script")

        expect { ml_service.run }.to raise_error(RuntimeError, /Unknown script/)
        expect(job.reload.error).to match(/Unknown script/)
      end
    end

    context "when a script fails" do
      it "records the error and re-raises" do
        job.update!(script: "proposal_tags")
        allow(MlHelper).to receive(:generate_tags).and_raise(StandardError, "API Timeout")

        expect { ml_service.run }.to raise_error(StandardError, "API Timeout")
        expect(job.reload.error).to eq("API Timeout")
      end
    end
  end

  describe "Core Processing Tasks" do
    before do
      # Ensure data folder is clean for testing file generation logic
      FileUtils.mkdir_p(MachineLearning.data_folder)
      FileUtils.rm_rf(Dir.glob("#{MachineLearning.data_folder}/*"))
    end

    describe "Tagging" do
      it "generates and saves tags for proposals" do
        job.update!(script: "proposal_tags")
        allow(MlHelper).to receive(:generate_tags).and_return(
          {
            "tags" => ["Environment", "Parks"],
            "usage" => { "total_tokens" => 50 }
          }
        )

        ml_service.run

        tag_names = Tagging.where(taggable: proposal, context: "ml_tags")
                           .joins(:tag).pluck("tags.name")
        expect(tag_names).to contain_exactly("Environment", "Parks")
        expect(job.reload.records_processed).to eq(1)
      end
    end

    describe "Comments Summary" do
      it "generates summaries and sentiment for proposals" do
        create(:comment, commentable: proposal, body: "Great idea!")
        job.update!(script: "proposal_summary_comments")

        sentiment_data = { "positive" => 100, "negative" => 0, "neutral" => 0 }
        allow(MlHelper).to receive(:summarize_comments).and_return(
          {
            "summary_markdown" => "Users are supportive.",
            "sentiment" => sentiment_data,
            "usage" => { "total_tokens" => 100 }
          }
        )

        ml_service.run

        summary = MlSummaryComment.find_by(commentable: proposal)
        expect(summary.body).to include("Users are supportive.")
        expect(summary.sentiment_analysis).to eq(sentiment_data)
      end
    end
  end

  describe "Data Integrity" do
    it "clears existing data when force_update is enabled" do
      proposal.set_tag_list_on(:ml_tags, ["OldTag"])
      proposal.save!

      job.update!(script: "proposal_tags", config: { force_update: "1" })
      allow(MlHelper).to receive(:generate_tags).and_return(
        { "tags" => ["NewTag"], "usage" => { "total_tokens" => 10 } }
      )

      ml_service.run

      tags = Tagging.where(context: "ml_tags").joins(:tag).pluck("tags.name")
      expect(tags).to include("NewTag")
      expect(tags).not_to include("OldTag")
    end

    it "does not reprocess fresh records unless forced" do
      proposal.set_tag_list_on(:ml_tags, ["Environment"])
      proposal.save!

      job.update!(script: "proposal_tags", config: { force_update: "0" })

      expect(MlHelper).not_to receive(:generate_tags)
      ml_service.run
    end
  end
end
