class Admin::Poll::Questions::Options::Documents::IndexComponent < ApplicationComponent
  attr_reader :option

  def initialize(option)
    @option = option
  end

  private

    def documents
      @documents ||= @option.class.find(@option.id).documents
    end
end
