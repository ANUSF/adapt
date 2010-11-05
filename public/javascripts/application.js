(function() {
  function tooltip_css(tooltip, mouse_x, mouse_y) {
    var win = jQuery(window);
    var left = Math.min(mouse_x + 20, win.width() - tooltip.outerWidth());
    var top = Math.min(mouse_y + 10,
		       win.height() + win.scrollTop() - tooltip.outerHeight());
    if (mouse_x + 20 > left && mouse_y + 10 > top)
      left = mouse_x - tooltip.outerWidth() - 20;

    return { left: left, top:  top };
  }

  function select_tab_with_data_refresh() {
    var ref = jQuery(this).attr('href');
    var selected = jQuery('.tab-body' + ref);
    var container = selected.closest('.tabs-container');
    var link = container.find('a.tab-link[href=' + ref + ']');
    var form = link.closest('form');
    form.find('input[name=active_tab]').attr('value', ref);

    if (form.find('.dirty').length == 0)
      link.each(select_tab);
    else
      form.submit();

    return false;
  }

  function select_tab() {
    var ref = jQuery(this).attr('href');
    var selected = jQuery('.tab-body' + ref);
    var container = selected.closest('.tabs-container');
    var link = container.find('a.tab-link[href=' + ref + ']');
    jQuery('.tab-body', container).css({ display: 'none' });
    selected.css({ display: 'block' });
    jQuery('.tab-entry a', container).removeClass('current-tab');
    link.addClass('current-tab');
    jQuery('> input:first', container).attr('value', ref);
    return false;
  }

  function file_selected() {
    var elem = jQuery(this);
    var id = elem.attr('id');
    var name = elem.attr('name');
    var n = parseInt(id.match(/\d+/)) + 1;
    var checkbox = jQuery('<input type="checkbox" checked=""/>')
      .attr('value', '1')
      .attr('name', name.replace(/\[[^\[\]]*\]$/, '[use]'))
      .attr('id', id.replace(/_[^_]*$/, '_use'));
    var input = elem.clone(true)
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
    return row.nextAll('.multi').length == 0;
  }

  function is_empty(row) {
    return row.find('input:text[value],textarea[value]').length == 0;
  }

  function multitext_edited() {
    var item = jQuery(this);
    var row  = item.parent().closest('.multi');
    if (!is_empty(row) && is_last(row)) {
      item.blur();
      var new_row = row.clone(true);
      jQuery('input:text,textarea', new_row).each(function() {
	var field = jQuery(this);
	var n = parseInt(field.attr('id').match(/\d+/)) + 1;
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
    var item = jQuery(this);
    var row  = item.parent().closest('.multi');
    if (is_empty(row) && !is_last(row)) {
      row.removeClass('dirty')
	.nextAll('.multi').find('input,textarea').addClass('dirty');
      setTimeout(function() { row.remove(); }, 100);
    }
  }

  jQuery(document).ready(function() {
    // -- auto-resize certain textareas (must be done before hiding content)
    jQuery('table textarea').TextAreaExpander(40, 200);

    // -- handles tabs
    jQuery('.tabs-container').each(function() {
      var container = jQuery(this);
      jQuery('.tab-headers', container).css({ display: 'block' });
      jQuery('.tab-body', container).not(':first').css({ display: 'none' });
      jQuery('> input:first', container).attr('name', 'active_tab');
      jQuery('.tab-entry a.current-tab', container).each(select_tab);
      jQuery('.tab-entry a', container).each(function() {
	var link = jQuery(this);
	var container = link.closest('.tabs-container', link);
	var err = jQuery('> div' + link.attr('href') + ' .error', container);
	if (err.size() > 0) link.addClass("with-error");
      });
      container.find('input,textarea,select').not('select.predefined')
	.change(function() { jQuery(this).addClass('dirty'); })
	.keyup(function() { jQuery(this).addClass('dirty'); });
    });
    jQuery('a.tab-link').click(select_tab_with_data_refresh);

    // -- allows multiple file uploads
    jQuery('input:file.multi').change(file_selected);

    // -- automatic extension of multiple text input field collections
    jQuery('.multi').find('input:text,textarea')
      .keyup(multitext_edited).change(multitext_edited).blur(multitext_cleanup);

    // -- update textfields with selection dropdowns
    jQuery('select.predefined')
      .blur(function() {
	jQuery(this).css({ display: 'none' });
      })
      .click(function() { // change does not seem to work properly on IE
      	var item = jQuery(this);
	setTimeout(function() {
	  item.prev().val(item.val()).trigger('keyup');
	}, 100);
      })
      .prev()
      .mousedown(function() {
	jQuery(this).next().toggle();
      })
      .focus(function() {
	jQuery('select.predefined').css({ display: 'none' });
	jQuery(this).next().each(function () {
	  var item = jQuery(this);
	  var pos = item.prev().position();
	  item.css({ display: 'block', left: pos.left });
	});
      })
      .blur(function() {
	var dropdown = jQuery(this).next();
	setTimeout(function() {
	  if (jQuery("*:focus").attr('id') != dropdown.attr('id')) {
	    dropdown.css({ display: 'none' });
	  }
	}, 100);
      })
      .keyup(function() {
	var dropdown = jQuery(this).next();
	setTimeout(function() { dropdown.css({ display: 'none' }); }, 100);
      });

    // -- remove flash notices after some time
    jQuery('#flash_notice').animate({ opacity: 0 }, 10000);

    // -- nicer tooltips
    jQuery('*').nicerTooltips();

    // -- disable the return key in text fields
    jQuery('form').delegate('input:text', 'keypress', function(ev) {
      return (ev.keyCode != 13);
    });
  });
})();
