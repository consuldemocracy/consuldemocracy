# coding: utf-8
require 'rails_helper'

describe CategoryDecorator do
  let(:category) do
    create(:category, name: {ca: "Nom"}, description: { ca: "Descripció"})
  end

  let(:decorator){ described_class.decorate(category) }

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
