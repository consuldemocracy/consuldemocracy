class Admin::SDG::Managers::IndexComponent < ApplicationComponent
  include Header

  attr_reader :users
  delegate :page_entries_info, :paginate, to: :helpers

  def initialize(users)
    @users = users
  end

  private

    def title
      SDG::Manager.model_name.human(count: 2).upcase_first
    end
end
