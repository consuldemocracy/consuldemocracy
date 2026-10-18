class Admin::SiteCustomization::Documents::IndexComponent < ApplicationComponent
  include Header

  attr_reader :documents

  def initialize(documents)
    @documents = documents
  end

  private

    def title
      t("admin.documents.index.title")
    end
end
