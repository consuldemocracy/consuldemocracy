class Migrations::LegacyLegislation::Annotation

  def migrate_annotations
    processes_info.each do |process|
      draft = draft_for process[:new_id]

      old_annotations_for(process[:old_id]).each do |old_annotation|
        new_annotation_params = {
          quote: old_annotation.quote,
          ranges: old_annotation.ranges,
          text: old_annotation.text,
          author_id: old_annotation.user_id,
          created_at: old_annotation.created_at,
          updated_at: old_annotation.created_at,
          range_start: old_annotation.ranges.first['start'],
          range_start_offset: old_annotation.ranges.first['startOffset'],
          range_end: old_annotation.ranges.first['end'],
          range_end_offset: old_annotation.ranges.first['endOffset'],
          context: "<span class=annotator-hl>#{old_annotation.quote}</span>"
        }
        draft.annotations.create!(new_annotation_params) if new_annotation_params[:quote].present?
      end

      last_update_date = draft.annotations.maximum(:created_at)
      new_process_for(process[:new_id]).update_columns(end_date: last_update_date,
                                                       allegations_end_date: last_update_date,
                                                       updated_at: last_update_date)
    end
  end

  def undo_migrate_data
    processes_info.each do |process|
      draft = draft_for process[:new_id]
      draft.annotations.each { |annotation| annotation.really_destroy! }
    end
  end

  def old_annotations_for(process_id)
    ::LegacyLegislation.find(process_id).annotations
  end

  def draft_for(process_id)
    new_process_for(process_id).draft_versions.first
  end

  def new_process_for(process_id)
    ::Legislation::Process.find process_id
  end

  def processes_info
    [
      {
        old_id: 9,
        title: "Registro de lobbies del Ayuntamiento de Madrid",
        new_id: 86
      },
      {
        old_id: 8,
        title: "Alianza para el Gobierno Abierto",
        new_id: 87
      },
      {
        old_id: 1,
        title: "Ordenanza De Transparencia De La Ciudad De Madrid",
        new_id: 88
      },
      {
        old_id: 6,
        title: "Carta de Servicios del Centro de Prevención del Deterioro Cognitivo",
        new_id: 89
      },
      {
        old_id: 5,
        title: "Carta de Servicios del Servicio de Teleasistencia Domiciliaria",
        new_id: 93
      },
      {
        old_id: 4,
        title: "Carta de Servicios de Centros Municipales de Mayores",
        new_id: 92
      },
      {
        old_id: 3,
        title: "Carta de Servicios de los Centros de Día",
        new_id: 91
      },
      {
        old_id: 2,
        title: "Carta de Servicios del Servicio de Ayuda a Domicilio",
        new_id: 90
      },
      {
        old_id: 7,
        title: "Plan de Derechos Humanos del Ayuntamiento de Madrid (2017-2020)",
        new_id: 94
      }
    ]
  end

end
