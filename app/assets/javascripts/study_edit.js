/*jslint white: false, browser: true, regexp: false */
/*global jQuery */

(function($) {
  var ROW_PATTERN = 'tr';

  function is_last(row) {
    return row.nextAll(ROW_PATTERN).length === 0;
  }

  function is_empty(row) {
    return row.find('input:text[value],textarea[value]').length === 0;
  }

  function multitext_edited() {
    var item = $(this),
        row  = item.parent().closest(ROW_PATTERN),
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
      row.after(new_row);
      item.focus().addClass('dirty');
    }
  }

  function tag_as_dirty() {
    var item = $(this),
        parent = item.parent(),
	grandparent = parent.parent();
    item.addClass('dirty');
    if (parent.is('td')) {
      parent.addClass('dirty');
    } else if (grandparent.is('td')) {
      grandparent.addClass('dirty');
    }
  };

  function multitext_cleanup() {
    var item = $(this),
        row  = item.parent().closest(ROW_PATTERN);
    if (is_empty(row) && !is_last(row)) {
      row.removeClass('dirty')
	.nextAll(ROW_PATTERN).find('input,textarea').each(tag_as_dirty);
      setTimeout(function() { row.remove(); }, 100);
    }
  }

  $(document).ready(function() {
    // -- update textfields with selection dropdowns
    $('input:text[data-selection-id]').each(function () {
      var item = $(this), pulldown = $(item.attr('data-selection-id'));
      item.addPulldown(pulldown);
      pulldown.css({ display: 'none' }).addClass('adapt-pulldown');
    });

    // -- fix for IE6 to make choice items highlight on hover
    $('.adapt-choices li').hover(
      function () { $(this).addClass('hover'); },
      function () { $(this).removeClass('hover'); }
    );

    // -- automatic extension of multiple text input field collections
    $('fieldset.repeatable')
      .find('table').find('input:text,textarea')
      .keyup(multitext_edited).change(multitext_edited).blur(multitext_cleanup);

    // -- tag fields that have been edited
    $('input,textarea,select').change(tag_as_dirty).keyup(tag_as_dirty);

    // -- disable the return key in text fields
    $('form').delegate('input:text', 'keypress', function(ev) {
      return (ev.keyCode !== 13);
    });

    // -- prepare overlay for modal dialogs
    $('<div id="adapt-overlay">')
      .append('<div class="blanket">')
      .appendTo('body');

    // -- show overlayed message whenever the form is submitted
    $('form').submit(function () {
      $('<div id="alert" class="dialog">')
	.append('<span class="busy-indicator" />')
	.append('Adapt is synchronizing your data...')
	.appendTo('#adapt-overlay');
      $('#adapt-overlay').css('display', 'block');
    });
  });
}(jQuery));
