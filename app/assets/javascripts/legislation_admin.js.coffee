App.LegislationAdmin =

  initialize: ->
    $("input[type='checkbox']#debate_phase_active").on
      change: ->
        if $("input[type='checkbox']#debate_phase_active").is(':checked')
          console.log("checked")
          $("input#debate_start_date").removeAttr("disabled")
          $("input#debate_end_date").removeAttr("disabled")
        else
          console.log("unchecked")
          $("input#debate_start_date").val("")
          $("input#debate_start_date").attr("disabled", true)
          $("input#debate_end_date").val("")
          $("input#debate_end_date").attr("disabled", true)

    $("input[type='checkbox']#allegations_phase_active").on
      change: ->
        if $("input[type='checkbox']#allegations_phase_active").is(':checked')
          $("input#allegations_start_date").removeAttr("disabled")
          $("input#allegations_end_date").removeAttr("disabled")
        else
          $("input#allegations_start_date").val("")
          $("input#allegations_start_date").prop( "disabled", true )
          $("input#allegations_end_date").val("")
          $("input#allegations_end_date").prop( "disabled", true )

    $("input[type='checkbox']#draft_publication_phase_active").on
      change: ->
        if $("input[type='checkbox']#draft_publication_phase_active").is(':checked')
          $("input#draft_publication_date").removeAttr("disabled")
        else
          $("input#draft_publication_date").val("")
          $("input#draft_publication_date").prop( "disabled", true )

    $("input[type='checkbox']#final_version_publication_phase_active").on
      change: ->
        if $("input[type='checkbox']#final_version_publication_phase_active").is(':checked')
          $("input#final_publication_date").removeAttr("disabled")
        else
          $("input#final_publication_date").val("")
          $("input#final_publication_date").prop( "disabled", true )



