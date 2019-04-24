shared_examples "reportable" do
  let(:reportable) { create(model_name(described_class)) }

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
      reportable.update(results_enabled: true)
      saved_reportable = described_class.last

      expect(saved_reportable.results_enabled?).to be true
      expect(saved_reportable.results_enabled).to be true

      reportable.update(results_enabled: false)
      saved_reportable = described_class.last

      expect(saved_reportable.results_enabled?).to be false
      expect(saved_reportable.results_enabled).to be false
    end

    it "uses the `has_one` relation instead of the original column" do
      skip "there's no original column" unless reportable.has_attribute?(:results_enabled)

      reportable.update(results_enabled: true)

      expect(reportable.read_attribute(:results_enabled)).to be false
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
      reportable.update(stats_enabled: true)
      saved_reportable = described_class.last

      expect(saved_reportable.stats_enabled?).to be true
      expect(saved_reportable.stats_enabled).to be true

      reportable.update(stats_enabled: false)
      saved_reportable = described_class.last

      expect(saved_reportable.stats_enabled?).to be false
      expect(saved_reportable.stats_enabled).to be false
    end

    it "uses the `has_one` relation instead of the original column" do
      skip "there's no original column" unless reportable.has_attribute?(:stats_enabled)

      reportable.update(stats_enabled: true)

      expect(reportable.read_attribute(:stats_enabled)).to be false
    end
  end
end
