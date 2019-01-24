class Migrations::LegacyLegislation::Cleanup

  def delete_old_data
    delete_migrated_processes_without_annotations
    delete_old_annotations
    delete_old_legacy_legislation_processes
  end

  def delete_migrated_processes_without_annotations
    old_processes.each do |process|
      old_process = ::Legislation::Process.find process[:id]
      old_process.really_destroy!
    end
  end

  def delete_old_legacy_legislation_processes
    ::LegacyLegislation.destroy_all
  end

  def delete_old_annotations
    ::Annotation.destroy_all
  end

  def old_processes
    [
      {
        id: 35,
        title: "Carta de Servicios del Servicio de Teleasistencia Domiciliaria"
      },
      {
        id: 33,
        title: "Carta de Servicios de Centros Municipales de Mayores"
      },
      {
        id: 32,
        title: "Carta de Servicios de los Centros de Día"
      },
      {
        id: 31,
        title: "Carta de Servicios del Servicio de Ayuda a Domicilio"
      }
    ]
  end

end
