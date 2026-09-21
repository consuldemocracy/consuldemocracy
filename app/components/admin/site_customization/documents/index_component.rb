class Admin::SiteCustomization::Documents::IndexComponent < ApplicationComponent
  attr_reader :documents

  def initialize(documents)
    @documents = documents
  end
end
