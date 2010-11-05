/*jslint white: false, browser: true, regexp: false */
/*global jQuery */

(function($) {
  function select_tab() {
    var ref = $(this).attr('href'),
        selected = $('.tab-body' + ref),
        container = selected.closest('.tabs-container'),
        link = container.find('a.tab-link[href=' + ref + ']');
    $('.tab-body', container).css({ display: 'none' });
    selected.css({ display: 'block' });
    $('.tab-entry a', container).removeClass('current-tab');
    link.addClass('current-tab');
    $('> input:first', container).attr('value', ref);
    return false;
  }

  function select_tab_with_data_refresh() {
    var ref = $(this).attr('href'),
        selected = $('.tab-body' + ref),
	container = selected.closest('.tabs-container'),
	link = container.find('a.tab-link[href=' + ref + ']'),
        form = link.closest('form');
    form.find('input[name=active_tab]').attr('value', ref);

    if (form.find('.dirty').length === 0) {
      link.each(select_tab);
    }
    else {
      form.submit();
    }

    return false;
  }

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
    $('.tabs-container').each(function() {
      var container = $(this);
      $('.tab-headers', container).css({ display: 'block' });
      $('.tab-body', container).not(':first').css({ display: 'none' });
      $('> input:first', container).attr('name', 'active_tab');
      $('.tab-entry a.current-tab', container).each(select_tab);
      $('.tab-entry a', container).each(function() {
	var link = $(this),
	    container = link.closest('.tabs-container', link),
	    err = $('> div' + link.attr('href') + ' .error', container);
	if (err.size() > 0) {
	  link.addClass("with-error");
	}
      });
      container.find('input,textarea,select').not('select.predefined')
	.change(function() { $(this).addClass('dirty'); })
	.keyup(function() { $(this).addClass('dirty'); });
    });
    $('a.tab-link').click(select_tab_with_data_refresh);

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
