require "rails_helper"

describe CsvExporter do
  describe "comment reading order" do
    factories = [
      :budget_investment,
      :debate,
      :proposal
    ]
    let(:factory) { factories.sample }
    let(:exporter_class) do
      case factory
      when :proposal
        Proposal::Exporter
      when :debate
        Debate::Exporter
      when :budget_investment
        Budget::Investment::Exporter
      end
    end
    let(:resource) { create(factory) }

    it "orders comments in tree order instead of global chronological order" do
      first_root = create(:comment, commentable: resource,
                                    body: "First thread",
                                    created_at: Time.zone.local(2026, 6, 1, 15, 0, 0))
      second_root = create(:comment, commentable: resource,
                                     body: "Second thread",
                                     created_at: Time.zone.local(2026, 6, 1, 15, 5, 0))
      reply = create(:comment, commentable: resource,
                               body: "Reply to first",
                               parent_id: first_root.id,
                               created_at: Time.zone.local(2026, 6, 1, 15, 10, 0))
      second_reply = create(:comment, commentable: resource,
                                      body: "Another reply to first",
                                      parent_id: first_root.id,
                                      created_at: Time.zone.local(2026, 6, 1, 15, 11, 0))
      nested_reply = create(:comment, commentable: resource,
                                      body: "Reply to first reply",
                                      parent_id: reply.id,
                                      created_at: Time.zone.local(2026, 6, 1, 15, 15, 0))

      csv = exporter_class.new([resource]).to_csv
      rows = CSV.parse(csv, headers: true)

      expect(rows.by_col["Comment Content"]).to eq [
        first_root.body,
        reply.body,
        nested_reply.body,
        second_reply.body,
        second_root.body
      ]
    end
  end
end
