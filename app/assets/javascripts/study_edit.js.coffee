$ = jQuery

tagAsDirty = ->
  item = $ this
  parent = item.parent()
  grandparent = parent.parent()

  item.addClass 'dirty'
  if parent.is 'td'
    parent.addClass 'dirty'
  else if grandparent.is 'td'
    grandparent.addClass 'dirty'

multitextCleanup = ->
  PATTERN = 'tr'

  item = $ this
  row  = item.closest PATTERN
  followingRows = row.nextAll PATTERN
  isLast = followingRows.length == 0
  isEmpty = row.find('input:text,textarea').
    filter(-> $(this).attr('value') != "").length == 0

  if isEmpty and not isLast
    row.removeClass 'dirty'
    followingRows.find('input,textarea').each tagAsDirty
    setTimeout (-> row.remove()), 100
  else if isLast and not isEmpty
    newRow = row.clone true
    $('input:text,textarea', newRow).each ->
      field = $(this)
      n = parseInt(field.attr('id').match(/\d+/), 10) + 1
      field.attr 'id', field.attr('id').replace(/\d+/, n)
      field.attr 'name', field.attr('name').replace(/\d+/, n)
      field.val ''

    newRow.find('textarea').TextAreaExpander 40, 200
    newRow.find('select.predefined').each -> $(this).prev().addPulldown $(this)

    row.after newRow
    item.addClass 'dirty'

$(document).ready ->
  # -- update textfields with selection dropdowns
  $('input:text[data-selection-id]').each ->
    item = $ this
    pulldown = $ item.attr 'data-selection-id'
    item.addPulldown pulldown
    pulldown.css({ display: 'none' }).addClass 'adapt-pulldown'

  # -- fix for IE6 to make choice items highlight on hover
  $('.adapt-choices li').hover(
    (-> $(this).addClass 'hover'), (-> $(this).removeClass 'hover')
  )

  # -- automatic extension of multiple text input field collections
  $('fieldset.repeatable').find('table').find('input:text,textarea').
    keyup(multitextCleanup).change(multitextCleanup).blur(multitextCleanup)

  # -- tag fields that have been edited
  $('input,textarea,select').change(tagAsDirty).keyup(tagAsDirty)

  # -- disable the return key in text fields
  $('form').delegate 'input:text', 'keypress', (ev) -> ev.keyCode != 13

  # -- prepare overlay for modal dialogs
  $('<div id="adapt-overlay">').append('<div class="blanket">').appendTo('body')

  # -- show overlayed message whenever the form is submitted
  $('form.adapt_study').submit ->
    $('<div id="alert" class="dialog">').
      append('<span class="busy-indicator" />').
      append('Adapt is synchronizing your data...').
      appendTo('#adapt-overlay')
    $('#adapt-overlay').css 'display', 'block'
