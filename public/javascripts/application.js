/*jslint white: false, browser: true, regexp: false */
/*global jQuery */

(function($) {
  function is_last(row) {
    return row.nextAll('.multi').length === 0;
  }

  function is_empty(row) {
    return row.find('input:text[value],textarea[value]').length === 0;
  }

  function multitext_edited() {
    var item = $(this),
        row  = item.parent().closest('.multi'),
        new_row;
    if (!is_empty(row) && is_last(row)) {
      item.blur();
      new_row = row.clone(true);
      $('input:text,textarea', new_row).each(function() {
	var field = $(this),
	    n = parseInt(field.attr('id').match(/\d+/), 10) + 1;
	field.attr('id', field.attr('id').replace(/\d+/, n));
	field.attr('name', field.attr('name').replace(/\d+/, n));
	field.val('');
      });
      new_row.find('textarea').TextAreaExpander(40, 200);
      new_row.find('select.predefined').each(function () {
	$(this).prev().addPulldown($(this));
      });
      row.parent().append(new_row);
      item.focus().addClass('dirty');
    }
  }

  function multitext_cleanup() {
    var item = $(this),
        row  = item.parent().closest('.multi');
    if (is_empty(row) && !is_last(row)) {
      row.removeClass('dirty')
	.nextAll('.multi').find('input,textarea').addClass('dirty');
      setTimeout(function() { row.remove(); }, 100);
    }
  }

  function tab_change_handler(event) {
    var target = $(event.target),
        form   = target.closest('form');
    form.find('input[name=active_tab]').attr('value', '#' + target.attr('id'));
    if (form.find('.dirty').size() > 0) {
      form.submit();
    }
  }

  $(document).ready(function() {
    // -- handle tabs
    $('.tab-container')
      .prepend('<input name=active_tab type=hidden />')
      .tabContainer({ tags_to_propagate: ['error'] })
      .find('> div').bind('tab-opened', tab_change_handler).end()
      .find('.active-tab').tabSelect();
    $('.tab-link').tabLink();

    // -- allow multiple file uploads
    $('input:file.multi').multiFile();

    // -- automatic extension of multiple text input field collections
    $('.multi').find('input:text,textarea')
      .keyup(multitext_edited).change(multitext_edited).blur(multitext_cleanup);

    // -- update textfields with selection dropdowns
    $('select.predefined').each(function () {
      $(this).prev().addPulldown($(this));
    });

    // -- remove flash notices after some time
    $('#flash_notice').animate({ opacity: 0 }, 10000);

    // -- nicer tooltips
    $('*').nicerTooltips();
  });
}(jQuery));
