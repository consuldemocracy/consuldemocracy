# frozen_string_literal: true

require "rails_helper"

describe Sensemaker::ScriptRegistry do
  node_script_ids = %w[
    health_check_runner.ts
    categorization_runner.ts
    advanced_runner.ts
    runner.ts
    sensemaking-report-ui
  ].freeze

  describe ".all" do
    it "includes all Node script ids" do
      expect(Sensemaker::ScriptRegistry.all).to include(*node_script_ids)
    end

    it "is a superset of the :node backend scripts" do
      node = Sensemaker::ScriptRegistry.for_backend(:node)
      expect(Sensemaker::ScriptRegistry.all).to include(*node)

      extras = Sensemaker::ScriptRegistry.all - node
      if extras.any?
        expect(Sensemaker::ScriptRegistry.all.size).to be > node.size
      end
    end
  end

  describe ".known?" do
    it "returns true for registered scripts" do
      expect(Sensemaker::ScriptRegistry.known?("categorization_runner.ts")).to be true
    end

    it "returns false for unknown scripts" do
      expect(Sensemaker::ScriptRegistry.known?("unknown_runner.ts")).to be false
    end
  end

  describe ".for_backend" do
    it "returns Node scripts for :node" do
      node = Sensemaker::ScriptRegistry.for_backend(:node)
      expect(node).to include(*node_script_ids)
      expect(node).to all(
        satisfy { |id| Sensemaker::ScriptRegistry.backend_for(id) == :node }
      )
    end

    it "returns empty array for unregistered backend" do
      expect(Sensemaker::ScriptRegistry.for_backend(:unknown)).to eq([])
    end
  end

  describe ".user_selectable" do
    it "excludes internal prep-chain scripts" do
      expect(Sensemaker::ScriptRegistry.user_selectable).not_to include("advanced_runner.ts")
    end

    it "includes user-facing scripts" do
      expect(Sensemaker::ScriptRegistry.user_selectable).to include(
        "health_check_runner.ts",
        "categorization_runner.ts",
        "runner.ts",
        "sensemaking-report-ui"
      )
    end
  end

  describe ".publishable" do
    it "includes Node publishable scripts" do
      expect(Sensemaker::ScriptRegistry.publishable).to include(
        "runner.ts",
        "sensemaking-report-ui"
      )
    end
  end

  describe ".backend_for" do
    it "returns :node for Node scripts" do
      expect(Sensemaker::ScriptRegistry.backend_for("categorization_runner.ts")).to eq(:node)
    end

    it "returns nil for unknown scripts" do
      expect(Sensemaker::ScriptRegistry.backend_for("unknown")).to be(nil)
    end
  end

  describe ".logical_name" do
    it "returns logical names for scripts" do
      expect(Sensemaker::ScriptRegistry.logical_name("categorization_runner.ts")).to eq(:categorize)
      expect(Sensemaker::ScriptRegistry.logical_name("sensemaking-report-ui")).to eq(:report)
    end
  end

  describe ".prep_steps" do
    it "returns direct prep step for advanced_runner.ts" do
      expect(Sensemaker::ScriptRegistry.prep_steps("advanced_runner.ts")).to eq(["categorization_runner.ts"])
    end

    it "returns direct prep step for sensemaking-report-ui" do
      expect(Sensemaker::ScriptRegistry.prep_steps("sensemaking-report-ui")).to eq(["advanced_runner.ts"])
    end

    it "returns empty array for scripts with no prep" do
      expect(Sensemaker::ScriptRegistry.prep_steps("categorization_runner.ts")).to eq([])
    end

    it "returns empty array for unknown scripts" do
      expect(Sensemaker::ScriptRegistry.prep_steps("unknown")).to eq([])
    end
  end

  describe ".i18n_key" do
    it "returns stable locale keys" do
      expect(Sensemaker::ScriptRegistry.i18n_key("categorization_runner.ts"))
        .to eq("categorization_runner_ts")
      expect(Sensemaker::ScriptRegistry.i18n_key("sensemaking-report-ui")).to eq("sensemaking_report_ui")
    end
  end

  describe ".artefact_config" do
    let(:job) { build(:sensemaker_job, id: 42) }

    it "returns config hash for known scripts" do
      config = Sensemaker::ScriptRegistry.artefact_config("categorization_runner.ts")
      expect(config[:output_basename].call(job)).to eq("categorization-output.csv")
    end

    it "returns nil for unknown scripts" do
      expect(Sensemaker::ScriptRegistry.artefact_config("unknown")).to be(nil)
    end
  end

  describe ".scripts_for_logical_name" do
    it "includes script ids for a logical name" do
      expect(Sensemaker::ScriptRegistry.scripts_for_logical_name(:report))
        .to include("sensemaking-report-ui")
      expect(Sensemaker::ScriptRegistry.scripts_for_logical_name(:summary))
        .to include("runner.ts")
    end
  end

  describe ".output_flag" do
    it "returns :output_basename for multi-output scripts" do
      expect(Sensemaker::ScriptRegistry.output_flag("advanced_runner.ts")).to eq(:output_basename)
      expect(Sensemaker::ScriptRegistry.output_flag("runner.ts")).to eq(:output_basename)
    end

    it "returns :output_file for single-output scripts" do
      expect(Sensemaker::ScriptRegistry.output_flag("categorization_runner.ts")).to eq(:output_file)
      expect(Sensemaker::ScriptRegistry.output_flag("sensemaking-report-ui")).to eq(:output_file)
      expect(Sensemaker::ScriptRegistry.output_flag("health_check_runner.ts")).to eq(:output_file)
    end

    it "returns nil for unknown scripts" do
      expect(Sensemaker::ScriptRegistry.output_flag("unknown")).to be(nil)
    end
  end

  describe ".requires_input?" do
    it "returns false for health check" do
      expect(Sensemaker::ScriptRegistry.requires_input?("health_check_runner.ts")).to be false
    end

    it "returns true for scripts that need input" do
      expect(Sensemaker::ScriptRegistry.requires_input?("categorization_runner.ts")).to be true
      expect(Sensemaker::ScriptRegistry.requires_input?("sensemaking-report-ui")).to be true
    end
  end
end
