class Documents::DocumentsComponent < ApplicationComponent
  attr_reader :documents

  def initialize(documents)
    @documents = documents
  end

  def render?
    documents.any?
  end
end
