class Admin::SiteCustomization::Documents::IndexComponent < ApplicationComponent
  include PermanentDocumentPath

  attr_reader :documents

  def initialize(documents)
    @documents = documents
  end
end
