require "rails_helper"

describe Budget::Investment::Exporter do
  describe "#to_csv" do
    let(:budget) { create(:budget) }
    let(:investment) do
      create(:budget_investment, budget: budget,
                                 title: "Le Investment",
                                 created_at: Time.zone.local(2026, 6, 1, 14, 56, 10))
    end

    context "when the investment has comments" do
      let(:root_comment) do
        create(:budget_investment_comment, commentable: investment,
                                           body: "I think it should",
                                           created_at: Time.zone.local(2026, 6, 1, 14, 58, 10))
      end
      let(:reply) do
        create(:budget_investment_comment, commentable: investment,
                                           body: "I disagree",
                                           parent_id: root_comment.id,
                                           created_at: Time.zone.local(2026, 6, 1, 14, 59, 10))
      end

      it "generates one row per comment" do
        csv_contents = <<~CSV
          ID,Title,Supports,Administrator,Valuator,Valuation Group,Scope of operation,\
          Feasibility,Val. Fin.,Selected,Show to valuators,Author username,Created at,\
          Comment ID,Comment Author,Comment Content,Comment Parent,Comment Created at
          #{investment.id},#{investment.title},#{investment.total_votes},No admin assigned,\
          -,-,#{investment.heading.name},Undecided,No,No,No,#{investment.author.username},\
          2026-06-01 14:56:10,#{root_comment.id},\
          #{root_comment.author.email},#{root_comment.body},"",2026-06-01 14:58:10
          #{investment.id},#{investment.title},#{investment.total_votes},No admin assigned,\
          -,-,#{investment.heading.name},Undecided,No,No,No,#{investment.author.username},\
          2026-06-01 14:56:10,#{reply.id},\
          #{reply.author.email},#{reply.body},#{root_comment.id},2026-06-01 14:59:10
        CSV

        expect(Budget::Investment::Exporter.new([investment]).to_csv).to eq csv_contents
      end
    end
  end
end
