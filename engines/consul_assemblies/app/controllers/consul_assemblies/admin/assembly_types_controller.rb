require_dependency "consul_assemblies/application_controller"

module ConsulAssemblies
  class Admin::AssemblyTypesController < Admin::AdminController

    before_action :authenticate_user!
    before_action :load_assembly_types, only: [:index]

    def new
      @assembly_type = ConsulAssemblies::AssemblyType.new()
    end

    def index; end

    def create
      @assembly_type = ConsulAssemblies::AssemblyType.new(assembly_type_params)
      if @assembly_type.save
        redirect_to admin_assembly_types_path, notice: t('.assembly_type_created')
      else
        flash.now[:error] = t('admin.site_customization.pages.create.error')
        render :new
      end
    end

    def update
      @assembly_type = ConsulAssemblies::AssemblyType.find(params[:id])
      if @assembly_type.update(assembly_type_params)
        redirect_to admin_assembly_types_path, notice: t('.assembly_type_updated')
      else
        flash.now[:error] = t('admin.site_customization.pages.create.error')
        render :new
      end
    end

    def destroy
      @assembly_type = ConsulAssemblies::AssemblyType.find(params[:id])
      @assembly_type.destroy

      redirect_to admin_assembly_types_path, notice: t('.assembly_type_destroyed')
    end

    def edit
      @assembly_type = ConsulAssemblies::AssemblyType.find(params[:id])
    end

    private

    def assembly_type_params
      params.require(:assembly_type).permit(
        :name,
        :description
      )
    end

    def load_assembly_types
      @assembly_types = ConsulAssemblies::AssemblyType.order(:name).page(params[:page] || 1)
    end

  end
end
