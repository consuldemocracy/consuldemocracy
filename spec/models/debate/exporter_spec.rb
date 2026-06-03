require "rails_helper"

describe Debate::Exporter do
  describe "#to_csv" do
    let(:debate) do
      create(:debate, title: "Should Pluto be a planet?",
                      created_at: Time.zone.local(2026, 6, 1, 14, 56, 10))
    end

    context "when the debate has comments" do
      let(:root_comment) do
        create(:comment, commentable: debate,
                         body: "I think it should",
                         created_at: Time.zone.local(2026, 6, 1, 14, 58, 10))
      end
      let(:reply) do
        create(:comment, commentable: debate,
                         body: "I disagree",
                         parent_id: root_comment.id,
                         created_at: Time.zone.local(2026, 6, 1, 14, 59, 10))
      end

      it "generates one row per comment" do
        csv_contents = <<~CSV
          ID,Title,Author,Created at,Comment ID,\
          Comment Author,Comment Content,Comment Parent,Comment Created at
          #{debate.id},#{debate.title},#{debate.author.email},2026-06-01 14:56:10,\
          #{root_comment.id},#{root_comment.author.email},#{root_comment.body},"",2026-06-01 14:58:10
          #{debate.id},#{debate.title},#{debate.author.email},2026-06-01 14:56:10,\
          #{reply.id},#{reply.author.email},#{reply.body},#{root_comment.id},2026-06-01 14:59:10
        CSV

        expect(Debate::Exporter.new([debate]).to_csv).to eq csv_contents
      end
    end
  end
end
