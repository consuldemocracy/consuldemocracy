App.ColumnsSelector =

  initColums: () ->
    App.ColumnsSelector.hideAll()
    c_value = App.ColumnsSelector.currentValue()

    if c_value.length == 0
      c_value = $("#js-columns-selector").data("default")
      App.Cookies.saveCookie($("#js-columns-selector").data("cookie"), c_value, 30)
    columns = c_value.split(",")

    for column in columns
      do ->
        $("[data-field=" + column + "]").removeClass("hidden")
        $("#column_selector_" + column).prop("checked", true)

  initChecks: () ->
    $(".column-selecteable th[data-field]").each ->
      field = $(this).data("field")
      text = $.trim($(this).text())
      item = $("#column_selector_item_template").clone()
      item.prop("id", "column_selector_item_" + field)
      input = item.find("input")
      input.prop("name", "column-selector[" + field + "]")
      input.prop("id", "column_selector_" + field)
      input.data("column", field)
      label = item.find("label")
      label.prop("for", "column_selector_" + field)
      label.text(text)
      item.removeClass("hidden")
      $("#js-columns-selector-wrapper").append(item)

  toggleOptions: (event) ->
    event.preventDefault()
    $("#js-columns-selector").toggleClass("hollow")
    $("#js-columns-selector-wrapper").toggleClass("hidden")

  hideAll: () ->
    $("[data-field]").addClass("hidden")
    $(".column-selector-item input").prop("checked", false)

  toggleColumn: (event) ->
    column = $(event.target).data("column")
    App.ColumnsSelector.displayColumn(column)

  displayColumn: (column) ->
    item = $("#column_selector_" + column)
    if item.prop("checked")
      $("[data-field=" + column + "]").removeClass("hidden")
    else
      $("[data-field=" + column + "]").addClass("hidden")

    value = App.ColumnsSelector.updateItem(column)
    App.Cookies.saveCookie($("#js-columns-selector").data("cookie"), value, 30)

  updateItem: (value) ->
    values = App.ColumnsSelector.currentValue().split(",")
    index = values.indexOf(value)
    if index >= 0
      values.splice index, 1
    else
      values.push value

    values.join ","

  currentValue: () ->
    App.Cookies.getCookie($("#js-columns-selector").data("cookie"))

  initialize: ->
    App.ColumnsSelector.initChecks()
    App.ColumnsSelector.initColums()

    $("#js-columns-selector").on
      click: (event) ->
        App.ColumnsSelector.toggleOptions(event)

    $(".column-selector-item input").on
      click: (event) ->
        App.ColumnsSelector.toggleColumn(event)
