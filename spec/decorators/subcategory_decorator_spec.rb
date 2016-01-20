# coding: utf-8
require 'rails_helper'

describe SubcategoryDecorator do
  let(:subcategory) do
    create(:subcategory, name: {ca: "Nom"}, description: { ca: "Descripció"})
  end

  let(:decorator){ described_class.decorate(subcategory) }

  describe "name" do
    it "returns the translated name" do
      I18n.locale = :ca
      expect(decorator.name).to eq("Nom")
    end
  end

  describe "description" do
    it "returns the translated name" do
      I18n.locale = :ca
      expect(decorator.description).to eq("Descripció")
    end
  end
end
