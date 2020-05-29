shared_examples "acts as paranoid" do |factory_name|
  let!(:resource) { create(factory_name) }

  it "#{described_class} can be recovered after soft deletion" do
    resource.destroy!
    resource.reload

    expect(resource.hidden_at).not_to be_blank
    resource.restore!
    resource.reload

    expect(resource.hidden_at).to be_blank
  end

  describe "#{described_class} translations" do
    it "is hidden after parent resource destroy" do
      resource.destroy!
      resource.reload

      expect(resource.translations.with_deleted.first.hidden_at).not_to be_blank
    end

    it "is destroyed after parent resource really_destroy" do
      expect { resource.really_destroy! }.to change { resource.translations.with_deleted.count }.from(1).to(0)
    end

    it "cannot be recovered through non recursive restore" do
      resource.destroy!
      resource.reload

      expect { resource.restore }.not_to change { resource.translations.with_deleted.first.hidden_at }
    end

    it "can be recovered through recursive restore after non-recursive restore" do
      resource.destroy!
      resource.restore
      resource.destroy!
      resource.reload

      expect { resource.restore(recursive: true) }.to change { resource.translations.with_deleted.first.hidden_at }
    end

    it "can be recovered after soft deletion through recursive restore" do
      original_translation = resource.translations.first
      new_translation = resource.translations.build
      described_class.translated_attribute_names.each do |translated_attribute_name|
        new_translation.send("#{translated_attribute_name}=", original_translation.send(translated_attribute_name))
      end
      new_translation.locale = :fr
      new_translation.save!

      expect(resource.translations.with_deleted.count).to eq(2)
      resource.destroy!
      resource.reload
      expect(resource.translations.with_deleted.count).to eq(2)
      expect(resource.translations.with_deleted.first.hidden_at).not_to be_blank
      expect(resource.translations.with_deleted.second.hidden_at).not_to be_blank
      resource.restore!(recursive: true)
      resource.reload
      expect(resource.translations.with_deleted.first.hidden_at).to be_blank
      expect(resource.translations.with_deleted.second.hidden_at).to be_blank
    end
  end
end
