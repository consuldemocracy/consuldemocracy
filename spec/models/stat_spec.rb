require 'rails_helper'

describe Stat do

  describe "#set_value" do
    it "changes value to received param" do
      s1 = Stat.create namespace: "specs", group: "stats", name: "setting_value", value: 21
      s1.set_value(7)
      s2 = Stat.by_namespace("specs").by_group("stats").where(name: "setting_value").first
      expect(s2.id).to eq(s1.id)
      expect(s2.value).to eq(7)
    end
  end

  describe ".set" do
    it "should save a new Stat if non existent and overwrite otherwise" do
      expect(Stat.by_namespace("testing").by_group("test").where(name: "spec").count).to eq(0)
      Stat.set("testing", "test", "spec", 33)
      s1 = Stat.by_namespace("testing").by_group("test").where(name: "spec").first
      expect(s1.value).to eq(33)

      Stat.set("testing", "test", "spec", 42)
      s2 = Stat.by_namespace("testing").by_group("test").where(name: "spec").first
      expect(s2.id).to eq(s1.id)
      expect(s2.value).to eq(42)
    end
  end

  describe ".named" do
    it "should return a new Stat if non existent" do
      stat = Stat.named("testing", "test", "spec")
      expect(stat).to_not be_persisted
    end

    it "should return existent Stat with same namespace/group/name" do
      s1 = Stat.create namespace: "specs", group: "stats", name: "testing_named_method"
      stat = Stat.named("specs", "stats", "testing_named_method")
      expect(stat).to be_persisted
      expect(stat.id).to eq(s1.id)
    end
  end

  describe ".hash" do
    it "returns all stat values in a namespace in hash format" do
      Stat.create namespace: "specs", group: "g1", name: "A", value: 21
      Stat.create namespace: "specs", group: "g1", name: "B", value: 32
      Stat.create namespace: "specs", group: "g2", name: "random", value: 33

      h = Stat.hash("specs")
      expect(h["g1"]["A"]).to eq(21)
      expect(h["g1"]["B"]).to eq(32)
      expect(h["g2"]["random"]).to eq(33)
    end
  end
end
