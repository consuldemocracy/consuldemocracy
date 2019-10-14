require_dependency "consul_assemblies/application_controller"

module ConsulAssemblies
  class Admin::AssembliesController < Admin::AdminController

    before_action :authenticate_user!
    before_action :load_assemblies, only: [:index]
    before_action :load_geozones, :load_assembly_types, only: [:create, :new, :edit, :update]

    def new
      @assembly = ConsulAssemblies::Assembly.new()
    end

    def index; end

    def create
      @assembly = ConsulAssemblies::Assembly.new(assembly_params)
      if @assembly.save
        redirect_to admin_assemblies_path, notice: t('.assembly_created')
      else
        flash.now[:error] = t('admin.site_customization.pages.create.error')
        render :new
      end
    end

    def update
      @assembly = ConsulAssemblies::Assembly.find(params[:id])
      if @assembly.update(assembly_params)
        redirect_to admin_assemblies_path, notice: t('.assembly_updated')
      else
        flash.now[:error] = t('admin.site_customization.pages.create.error')
        render :new
      end
    end

    def destroy
      @assembly = ConsulAssemblies::Assembly.find(params[:id])
      @assembly.destroy

      redirect_to admin_assemblies_path, notice: t('.assembly_destroyed')
    end

    def edit
      @assembly = ConsulAssemblies::Assembly.find(params[:id])
    end

    private

    def load_assemblies
      @assemblies = ConsulAssemblies::Assembly.order(:name).page(params[:page] || 1)
    end

    def load_assembly_types
      @assembly_types = ConsulAssemblies::AssemblyType.order(:name)
    end

    def load_geozones
      @geozones = Geozone.order(:name)
    end

    def assembly_params
      params.require(:assembly).permit(
        :name,
        :general_description,
        :scope_description,
        :geozone_id,
        :about_venue,
        :created_at,
        :updated_at,
        :assembly_type_id
      )
    end

  end
end
