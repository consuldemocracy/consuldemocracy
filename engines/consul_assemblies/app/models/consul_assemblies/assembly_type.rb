module ConsulAssemblies
  class AssemblyType < ActiveRecord::Base
    has_many :assemblies
    validates :name, presence: true
  end
end
