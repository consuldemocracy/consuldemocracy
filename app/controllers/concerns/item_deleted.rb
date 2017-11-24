module ItemDeleted
  extend ActiveSupport::Concern

  included do
    before_action :find_unscoped_resourse, :only => :show
  end

  private

    def find_unscoped_resourse
      @resource = resource_model.unscoped.find(params[:id])
      render 'shared/item_deleted' if @resource.hidden?
      set_resource_instance
    end
end
