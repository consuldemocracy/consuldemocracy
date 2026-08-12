shared_examples "reportable" do
  let(:reportable) { create(model_name(described_class)) }

  describe "scopes" do
    describe ".results_enabled" do
      it "includes records with results enabled" do
        reportable.update!(results_enabled: true)

        expect(described_class.results_enabled).to eq [reportable]
      end

      it "does not include records without results enabled" do
        reportable.update!(results_enabled: false)

        expect(described_class.results_enabled).to be_empty
      end
    end

    describe ".stats_enabled" do
      it "includes records with stats enabled" do
        reportable.update!(stats_enabled: true)

        expect(described_class.stats_enabled).to eq [reportable]
      end

      it "does not include records without stats enabled" do
        reportable.update!(stats_enabled: false)

        expect(described_class.stats_enabled).to be_empty
      end
    end

    describe ".sensemaking_enabled" do
      it "includes records with sensemaking enabled" do
        reportable.update!(sensemaking_enabled: true)

        expect(described_class.sensemaking_enabled).to eq [reportable]
      end

      it "does not include records without sensemaking enabled" do
        reportable.update!(sensemaking_enabled: false)

        expect(described_class.sensemaking_enabled).to be_empty
      end
    end
  end

  describe "#results_enabled" do
    it "can write and read the attribute" do
      reportable.results_enabled = true

      expect(reportable.results_enabled?).to be true
      expect(reportable.results_enabled).to be true

      reportable.results_enabled = false

      expect(reportable.results_enabled?).to be false
      expect(reportable.results_enabled).to be false
    end

    it "can save the value to the database" do
      reportable.update!(results_enabled: true)
      saved_reportable = described_class.last

      expect(saved_reportable.results_enabled?).to be true
      expect(saved_reportable.results_enabled).to be true

      reportable.update!(results_enabled: false)
      saved_reportable = described_class.last

      expect(saved_reportable.results_enabled?).to be false
      expect(saved_reportable.results_enabled).to be false
    end
  end

  describe "#stats_enabled" do
    it "can write and read the attribute" do
      reportable.stats_enabled = true

      expect(reportable.stats_enabled?).to be true
      expect(reportable.stats_enabled).to be true

      reportable.stats_enabled = false

      expect(reportable.stats_enabled?).to be false
      expect(reportable.stats_enabled).to be false
    end

    it "can save the attribute to the database" do
      reportable.update!(stats_enabled: true)
      saved_reportable = described_class.last

      expect(saved_reportable.stats_enabled?).to be true
      expect(saved_reportable.stats_enabled).to be true

      reportable.update!(stats_enabled: false)
      saved_reportable = described_class.last

      expect(saved_reportable.stats_enabled?).to be false
      expect(saved_reportable.stats_enabled).to be false
    end
  end

  describe "#sensemaking_enabled" do
    it "can write and read the attribute" do
      reportable.sensemaking_enabled = true

      expect(reportable.sensemaking_enabled?).to be true
      expect(reportable.sensemaking_enabled).to be true

      reportable.sensemaking_enabled = false

      expect(reportable.sensemaking_enabled?).to be false
      expect(reportable.sensemaking_enabled).to be false
    end

    it "can save the value to the database" do
      reportable.update!(sensemaking_enabled: true)
      saved_reportable = described_class.last

      expect(saved_reportable.sensemaking_enabled?).to be true
      expect(saved_reportable.sensemaking_enabled).to be true

      reportable.update!(sensemaking_enabled: false)
      saved_reportable = described_class.last

      expect(saved_reportable.sensemaking_enabled?).to be false
      expect(saved_reportable.sensemaking_enabled).to be false
    end
  end
end
