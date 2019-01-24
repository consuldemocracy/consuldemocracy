class Migrations::LegacyLegislation::Process

  def migrate_processes
    old_processes_info.each do |info|
      new_process_params = {
        title: info[:title],
        description: file_content_for(info[:description_file]),
        additional_info: file_content_for(info[:additional_file]),
        start_date: info[:start_date].to_date,
        end_date: info[:end_date].to_date,
        draft_publication_date: info[:start_date].to_date,
        allegations_start_date: info[:start_date].to_date,
        allegations_end_date: info[:end_date].to_date,
        created_at: info[:start_date].to_time,
        updated_at: info[:start_date].to_time,
        draft_publication_enabled: true,
        allegations_phase_enabled: true,
        published: true
      }
      new_process = Legislation::Process.create!(new_process_params)

      new_process.draft_versions.create!(title: "borrador",
                                         body: file_content_for(info[:draft_file]),
                                         body_html: file_content_for(info[:draft_file]),
                                         created_at: info[:start_date].to_time,
                                         updated_at: info[:start_date].to_time,
                                         status: "published")

      info[:documents].each do |document|
        absolute_path = Rails.root.join(document[:path])
        if File.exists?(absolute_path)
          new_process.documents.create!(title: document[:title],
                                        attachment: File.open(absolute_path),
                                        user_id: 1)
        end
      end
    end
  end

  def undo_migrate_data
    old_processes_info.each do |info|
      process = Legislation::Process.find_by(title: info[:title])
      process.really_destroy! if process.present?
    end
  end

  def file_content_for(file_path)
    return nil unless file_path.present?

    absolute_path = Rails.root.join(file_path)
    return nil unless File.exists?(absolute_path)

    File.read absolute_path
  end

  def old_processes_info
    [
      {
        old_id: 9,
        start_date: "17/08/2016",
        end_date: "17/08/2017",
        title: "Registro de lobbies del Ayuntamiento de Madrid",
        description_file: "app/views/pages/processes/lobbies/description.html",
        additional_file: "app/views/pages/processes/lobbies/additional.html",
        draft_file: "app/views/pages/processes/lobbies/draft.html",
        documents: [
          {
            title: "Propuesta de acuerdo del Pleno",
            path: "public/docs/procesos/acuerdo_de_pleno_registro_de_lobbies.pdf"
          }
        ]
      },
      {
        old_id: 8,
        start_date: "17/08/2016",
        end_date: "17/08/2017",
        title: "Alianza para el Gobierno Abierto",
        description_file: "app/views/pages/processes/open_government/description.html",
        additional_file: "app/views/pages/processes/open_government/additional.html",
        draft_file: "app/views/pages/processes/open_government/draft.html",
        documents: []
      },
      {
        old_id: 1,
        start_date: "09/12/2015",
        end_date: "31/01/2016",
        title: "Ayúdanos a mejorar la Ordenanza de Transparencia de la Ciudad de Madrid",
        description_file: "app/views/pages/processes/transparency/description.html",
        additional_file: nil,
        draft_file: "app/views/pages/processes/transparency/draft.html",
        documents: []
      },
      {
        old_id: 6,
        start_date: "29/10/2015",
        end_date: "29/10/2016",
        title: "Carta de Servicios del Centro de Prevención del Deterioro Cognitivo",
        description_file: "app/views/pages/processes/service_letters/description1.html",
        additional_file: "app/views/pages/processes/service_letters/additional1.html",
        draft_file: "app/views/pages/processes/service_letters/draft1.html",
        documents: [
          {
            title: "Resultados de participación",
            path: "public/docs/procesos/resultados_proceso_CPD_cognitivo.pdf"
          }
        ]
      },
      {
        old_id: 2,
        start_date: "29/10/2015",
        end_date: "29/10/2016",
        title: "Carta de Servicios del Servicio de Ayuda a Domicilio",
        description_file: "app/views/pages/processes/service_letters/description2.html",
        additional_file: "app/views/pages/processes/service_letters/additional2.html",
        draft_file: "app/views/pages/processes/service_letters/draft2.html",
        documents: [
          {
            title: "Resultados de participación",
            path: "public/docs/procesos/resultados_proceso_SAD.pdf"
          }
        ]
      },
      {
        old_id: 3,
        start_date: "29/10/2015",
        end_date: "29/10/2016",
        title: "Carta de Servicios de los Centros de Día del Ayuntamiento de Madrid",
        description_file: "app/views/pages/processes/service_letters/description3.html",
        additional_file: "app/views/pages/processes/service_letters/additional3.html",
        draft_file: "app/views/pages/processes/service_letters/draft3.html",
        documents: [
          {
            title: "Resultados de participación",
            path: "public/docs/procesos/resultados_proceso_centros_dia.pdf"
          }
        ]
      },
      {
        old_id: 4,
        start_date: "29/10/2015",
        end_date: "29/10/2016",
        title: "Carta de Servicios de Centros Municipales de Mayores",
        description_file: "app/views/pages/processes/service_letters/description4.html",
        additional_file: "app/views/pages/processes/service_letters/additional4.html",
        draft_file: "app/views/pages/processes/service_letters/draft4.html",
        documents: [
          {
            title: "Resultados de participación",
            path: "public/docs/procesos/resultados_proceso_centros_mayores.pdf"
          }
        ]
      },
      {
        old_id: 5,
        start_date: "29/10/2015",
        end_date: "29/10/2016",
        title: "Carta de Servicios del Servicio de Teleasistencia Domiciliaria",
        description_file: "app/views/pages/processes/service_letters/description5.html",
        additional_file: "app/views/pages/processes/service_letters/additional5.html",
        draft_file: "app/views/pages/processes/service_letters/draft5.html",
        documents: [
          {
            title: "Resultados de participación",
            path: "public/docs/procesos/resultados_proceso_teleasistencia.pdf"
          }
        ]
      },
      {
        old_id: 7,
        start_date: "01/12/2017",
        end_date: "29/10/2016",
        title: "Plan de Derechos Humanos del Ayuntamiento de Madrid (2017-2020)",
        description_file: "app/views/pages/processes/human_rights/description.html",
        additional_file: nil,
        draft_file: "app/views/pages/processes/human_rights/draft.html",
        documents: [
          {
            title: "Borrador del Plan de Derechos Humanos del Ayuntamiento de Madrid (2017-2020)",
            path: "public/docs/docs/Borrador_PlanDDHH_20Octubre.pdf"
          }
        ]
      }
    ]
  end

end
