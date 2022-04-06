require "rails_helper"

describe SignatureSheetsHelper do
  describe "#required_fields_to_verify_text_help by default" do
    it "returns text help by default" do
      text = "Write the numbers separated by semicolons (;)"
      expect(required_fields_to_verify_text_help).to eq(text)
    end
  end

  describe "#required_fields_to_verify_text_help with remote_census active", :remote_census do
    it "returns text help when date_of_birth and postal_code are not required" do
      Setting["remote_census.request.date_of_birth"] = nil
      Setting["remote_census.request.postal_code"] = nil

      text_help_1 = "To verify a user, your application needs: Document number"
      text_help_2 = "Required fields for each user must be separated by commas and each user must be separated by semicolons."
      text_example = "Example: 12345678Z; 87654321Y"

      expect(required_fields_to_verify_text_help).to include(text_help_1)
      expect(required_fields_to_verify_text_help).to include(text_help_2)
      expect(example_text_help).to include(text_example)
    end

    it "returns text help when date_of_birth is required" do
      Setting["remote_census.request.postal_code"] = nil

      text_help_1 = "To verify a user, your application needs: Document number, Day of birth (dd/mm/yyyy)"
      text_help_2 = "Required fields for each user must be separated by commas and each user must be separated by semicolons."
      text_example = "Example: 12345678Z, 01/01/1980; 87654321Y, 01/02/1990"

      expect(required_fields_to_verify_text_help).to include(text_help_1)
      expect(required_fields_to_verify_text_help).to include(text_help_2)
      expect(example_text_help).to include(text_example)
    end

    it "returns text help when postal_code is required" do
      Setting["remote_census.request.date_of_birth"] = nil

      text_help_1 = "To verify a user, your application needs: Document number and Postal Code"
      text_help_2 = "Required fields for each user must be separated by commas and each user must be separated by semicolons."
      text_example = "Example: 12345678Z, 28001; 87654321Y, 28002"

      expect(required_fields_to_verify_text_help).to include(text_help_1)
      expect(required_fields_to_verify_text_help).to include(text_help_2)
      expect(example_text_help).to include(text_example)
    end

    it "returns text help when date_of_birth and postal_code are required" do
      text_help_1 = "To verify a user, your application needs: Document number, Day of birth (dd/mm/yyyy) and Postal Code"
      text_help_2 = "Required fields for each user must be separated by commas and each user must be separated by semicolons."
      text_example = "Example: 12345678Z, 01/01/1980, 28001; 87654321Y, 01/02/1990, 28002"

      expect(required_fields_to_verify_text_help).to include(text_help_1)
      expect(required_fields_to_verify_text_help).to include(text_help_2)
      expect(example_text_help).to include(text_example)
    end
  end
end
