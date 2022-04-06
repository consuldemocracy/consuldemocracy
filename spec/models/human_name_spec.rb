require "rails_helper"

describe HumanName do
  describe "#human_name" do
    it "uses the title when available" do
      model = Class.new do
        include HumanName

        def title
          "I am fire"
        end
      end

      expect(model.new.human_name).to eq "I am fire"
    end

    it "uses the name when available" do
      model = Class.new do
        include HumanName

        def name
          "Be like water"
        end
      end

      expect(model.new.human_name).to eq "Be like water"
    end

    it "uses the subject when available" do
      model = Class.new do
        include HumanName

        def subject
          "20% off on fire and water"
        end
      end

      expect(model.new.human_name).to eq "20% off on fire and water"
    end

    it "prioritizes title over name and subject" do
      model = Class.new do
        include HumanName

        def title
          "I am fire"
        end

        def name
          "Be like water"
        end

        def subject
          "20% off on fire and water"
        end
      end

      expect(model.new.human_name).to eq "I am fire"
    end

    it "prioritizes name over subject" do
      model = Class.new do
        include HumanName

        def name
          "Be like water"
        end

        def subject
          "20% off on fire and water"
        end
      end

      expect(model.new.human_name).to eq "Be like water"
    end

    it "raises an exception when no methods are defined" do
      model = Class.new do
        include HumanName
      end

      expect { model.new.human_name }.to raise_error RuntimeError
    end
  end
end
