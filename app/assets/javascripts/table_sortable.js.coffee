App.TableSortable =
  getCellValue: (row, index) ->
    $(row).children("td").eq(index).text()

  comparer: (index) ->
    (a, b) ->
      valA = App.TableSortable.getCellValue(a, index)
      valB = App.TableSortable.getCellValue(b, index)
      return if $.isNumeric(valA) and $.isNumeric(valB) then valA - valB else valA.localeCompare(valB)

  initialize: ->
    $("table.sortable th").click ->
      table = $(this).parents("table").eq(0)
      rows = table.find("tbody tr").toArray().sort(App.TableSortable.comparer($(this).index()))
      @asc = !@asc

      if @asc
        table.append rows
      else
        table.append rows.reverse()

      return
