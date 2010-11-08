/*jslint white: false, browser: true, regexp: false */
/*global jQuery */

(function($) {
  function file_selected() {
    var elem = $(this),
        id = elem.attr('id'),
        name = elem.attr('name'),
	n = parseInt(id.match(/\d+/), 10) + 1,
        checkbox = $('<input type="checkbox" checked=""/>')
	  .attr('value', '1')
	  .attr('name', name.replace(/\[[^\[\]]*\]$/, '[use]'))
	  .attr('id', id.replace(/_[^_]*$/, '_use')),
        input = elem.clone(true)
	  .attr('value', '')
	  .attr('id', id.replace(/\d+/, n))
	  .attr('name', name.replace(/\d+/, n))
	  .removeClass('dirty');
    elem
      .addClass('dirty')
      .css({ display: 'none' })
      .after('<p/>').next()
      .append(checkbox)
      .append(elem.val().replace(/^.*[\/\\]/, ''))
      .after(input);
  }

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

  $(document).ready(function() {
    // -- auto-resize certain textareas (must be done before hiding content)
    $('table textarea').TextAreaExpander(40, 200);

    // -- handles tabs
    $('.tab-container').tabContainer({
      tags_to_propagate: ['error'],

      callback: function (selected_body) {
	var form = selected_body.closest('form');
	if (form.find('.dirty').size() > 0) {
	  form.submit();
	  return false;
	} else {
	  return true;
	}
      }
    }).find('.active-tab').tabSelect();
    $('.tab-link').tabLink();

    // -- tags fields that have been edited
    $('input,textarea,select').not('select.predefined')
      .change(function() { $(this).addClass('dirty'); })
      .keyup (function() { $(this).addClass('dirty'); });

    // -- allows multiple file uploads
    $('input:file.multi').change(file_selected);

    // -- automatic extension of multiple text input field collections
    $('.multi').find('input:text,textarea')
      .keyup(multitext_edited).change(multitext_edited).blur(multitext_cleanup);

    // -- update textfields with selection dropdowns
    $('select.predefined')
      .blur(function() {
	$(this).css({ display: 'none' });
      })
      .click(function() { // change does not seem to work properly on IE
        var item = $(this);
	setTimeout(function() {
	  item.prev().val(item.val()).trigger('keyup');
	}, 100);
      })
      .prev()
      .mousedown(function() {
	$(this).next().toggle();
      })
      .focus(function() {
	$('select.predefined').css({ display: 'none' });
	$(this).next().each(function () {
	  var item = $(this),
	      pos = item.prev().position();
	  item.css({ display: 'block', left: pos.left });
	});
      })
      .blur(function() {
	var dropdown = $(this).next();
	setTimeout(function() {
	  if ($("*:focus").attr('id') !== dropdown.attr('id')) {
	    dropdown.css({ display: 'none' });
	  }
	}, 100);
      })
      .keyup(function() {
	var dropdown = $(this).next();
	setTimeout(function() { dropdown.css({ display: 'none' }); }, 100);
      });

    // -- remove flash notices after some time
    $('#flash_notice').animate({ opacity: 0 }, 10000);

    // -- nicer tooltips
    $('*').nicerTooltips();

    // -- disable the return key in text fields
    $('form').delegate('input:text', 'keypress', function(ev) {
      return (ev.keyCode !== 13);
    });
  });
}(jQuery));
