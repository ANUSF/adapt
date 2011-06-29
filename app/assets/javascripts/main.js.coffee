$ = jQuery

tab_change_handler = (event) ->
  target = $ event.target
  form   = target.closest 'form'
  form.find('input[name=active_tab]').attr 'value', '#' + target.attr 'id'
  form.submit() if form.find('.dirty').size() > 0

$(document).ready ->
  $('table.zebra tr:nth-child(even) td').each ->
    $(this).css 'background-color', '#f8f8f8'

  # -- auto-expanding some textareas
  $('textarea.expandable, table textarea').TextAreaExpander 40, 200

  # -- make sure tabs signal all errors
  $('form.formtastic .inline-errors').addClass 'error'

  # -- handle tabs
  $('.tab-container').
    prepend('<input name=active_tab type=hidden />').
    tabContainer(
      tags_to_propagate: ['error'],
      patterns: { body: '> fieldset' }
    ).
    find('> fieldset legend span').css({ display: 'none' }).end().
    find('> fieldset').bind('tab-opened', tab_change_handler).end().
    find('.active-tab').tabSelect()
  $('.tab-link').tabLink()

  # -- allow multiple file uploads
  $('input:file.multi').multiFile()

  # -- remove flash notices after some time
  $('.flash-notice').each ->
    setTimeout (=> $(this).animate { opacity: 0 }, 'slow'), 5000

  # -- turn inline hints in formtastic into nice mouseover tooltips
  $(document).enableTooltips { tooltip_id: 'adapt-tooltip', delay: 3000 }
  $('.inline-hints').each ->
    $(this).css({ display: 'none' }).parent().addTooltip $(this).text()
