require "rails_helper"

describe Proposal::Exporter do
  describe "#to_csv" do
    let(:proposal) do
      create(:proposal, title: "Make Pluto a planet again",
                        summary: "summary 1",
                        created_at: Time.zone.local(2026, 6, 1, 14, 56, 10))
    end

    context "when the proposal has comments" do
      let(:root_comment) do
        create(:comment, commentable: proposal,
                         body: "I think it should",
                         created_at: Time.zone.local(2026, 6, 1, 14, 58, 10))
      end
      let(:reply) do
        create(:comment, commentable: proposal,
                         body: "I disagree",
                         parent_id: root_comment.id,
                         created_at: Time.zone.local(2026, 6, 1, 14, 59, 10))
      end

      it "generates one row per comment" do
        csv_contents = <<~CSV
          ID,Proposal,Author,Summary,Created at,Comment ID,\
          Comment Author,Comment Content,Comment Parent,Comment Created at
          #{proposal.id},#{proposal.title},#{proposal.author.email},#{proposal.summary},\
          2026-06-01 14:56:10,\
          #{root_comment.id},#{root_comment.author.email},#{root_comment.body},"",2026-06-01 14:58:10
          #{proposal.id},#{proposal.title},#{proposal.author.email},#{proposal.summary},\
          2026-06-01 14:56:10,\
          #{reply.id},#{reply.author.email},#{reply.body},#{root_comment.id},2026-06-01 14:59:10
        CSV

        expect(Proposal::Exporter.new([proposal]).to_csv).to eq csv_contents
      end
    end
  end
end
