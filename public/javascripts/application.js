(function() {
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
    var input = elem.clone(true);
    var id = elem.attr('id');
    var name = elem.attr('name');
    var n = parseInt(id.match(/\d+/)) + 1;
    input.attr('value', '');
    input.attr('id', id.replace(/\d+/, n));
    input.attr('name', name.replace(/\d+/, n));
    input.removeClass('dirty');
    elem.after('<p><input type="checkbox" class="dirty" checked="" value="1" ' +
	       'name="' + name.replace(/\[[^\[\]]*\]$/, '[use]') +
	       '" id="' + id.replace(/_[^_]*$/, '_use') +
	       '"/>' + elem.val().replace(/^.*[\/\\]/, '') + '</p>');
    elem.addClass('dirty').css({ display: 'none' });
    elem.parent().append(input);
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
      setTimeout(function() { row.remove(); }, 200);
    }
  }

  function onload(context) {
    fixPage();

    // -- auto-resize certain textareas (must be done before hiding content)
    jQuery('table textarea', context).TextAreaExpander(40, 200);

    // -- handles tabs
    jQuery('.tabs-container', context).each(function() {
      var container = jQuery(this);
      jQuery('.tab-headers', container).css({ display: 'block' });
      jQuery('.tab-body', container).css({ display: 'none' });
      jQuery('.tab-body:first', container).css({ display: 'block' });
      jQuery('> input:first', container).attr('name', 'active_tab');
      jQuery('.tab-entry a.current-tab', container).each(select_tab);
      jQuery('.tab-entry a', container).each(function() {
	var link = jQuery(this);
	var container = link.closest('.tabs-container', link);
	var err = jQuery('> div' + link.attr('href') + ' .error', container);
	if (err.size() > 0) link.addClass("with-error");
      });
      container.find('input,textarea,select')
	.change(function() { jQuery(this).addClass('dirty'); })
	.keyup(function() { jQuery(this).addClass('dirty'); });
    });
    jQuery('a.tab-link', context).click(select_tab_with_data_refresh);

    // -- allows multiple file uploads
    jQuery('input:file.multi', context).change(file_selected);

    // -- automatic extension of multiple text input field collections
    jQuery('.multi', context).find('input:text,textarea')
      .keyup(multitext_edited).change(multitext_edited).blur(multitext_cleanup);

    // -- update textfields with selection dropdowns
    jQuery('select.predefined', context)
      .blur(function() {
	jQuery(this).css({ display: 'none' });
      })
      .change(function() {
	var item = jQuery(this);
	item.removeClass('dirty');
	item.prev().val(item.selected().val()).keyup().addClass('dirty');
      })
      .prev()
      .mousedown(function() {
	jQuery(this).next().toggle();
      })
      .focus(function() {
	jQuery('select.predefined', context).css({ display: 'none' });
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
	}, 200);
      })
      .keyup(function() {
	var dropdown = jQuery(this).next();
	setTimeout(function() { dropdown.css({ display: 'none' }); }, 200);
      });

    // -- remove flash notices after some time
    jQuery('#flash_notice', context).animate({ opacity: 0 }, 10000);

    // -- nicer tooltips
    jQuery('*[title]', context).each(function() {
      jQuery(this)
	.data('tipText', jQuery(this).attr('title'))
	.removeAttr('title');
    }).hover(function(e) {
      jQuery('#tooltip')
	.stop(true, true)
	.css('display', 'none')
	.text(jQuery(this).data('tipText'))
	.css({ top: (e.pageY + 10) + 'px',
	       left: (e.pageX + 20) + 'px' })
	.delay(1000)
	.fadeIn('slow');
    }, function() {
      jQuery('#tooltip').stop(true, true).fadeOut('fast');
    }).click(function() {
      jQuery('#tooltip').stop(true, true).fadeOut('fast');
    }).mousemove(function(e) {
      jQuery('#tooltip')
	.css({ top: (e.pageY + 10) + 'px',
	       left: (e.pageX + 20) + 'px' });
    });
    jQuery('<p id="tooltip"/>').css('display', 'none').appendTo('body');
  }

  function fixPage() {
  }

  jQuery(document).ready(function() {
    onload(document);

    // -- disable the return key in text fields
    jQuery('form').delegate('input:text', 'keypress', function(ev) {
      return (ev.keyCode != 13);
    });

    // -- enable ajax templating via jquery.djtch.js
    jQuery.djtch.setup({
      preUpdateHook:  fixPage,
      postUpdateHook: onload
    });
    jQuery(document).djtchEnable();
  });
})();
