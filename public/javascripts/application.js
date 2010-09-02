(function() {
  function select_tab_with_data_refresh() {
    var link = jQuery(this);
    var chosen_tab = link.attr('href').replace(/.*#/, '#');
    var container = link.closest('.tabs-container', link);
    var form = link.closest('form');
    form.find('input[name=active_tab]').attr('value', chosen_tab);

    if (form.find('.dirty').length == 0) {
      link.each(select_tab);
    } else if (jQuery.browser.msie) {
      form.submit();
    } else {
      form.ajaxSubmit({
	type: 'PUT',
	url: form.attr('action') + '?stripped=1',
	timeout: 20000,
	success: function(html, status) {
	  jQuery.djtch.update(container, html);
	},
	error: function(XMLHttpRequest, textStatus, errorThrown) {
	  alert("Something went wrong: " + textStatus);
	}
      });
    }
    return false;
  }

  function select_tab() {
    var link = jQuery(this);
    var ref = link.attr('href');
    var container = link.closest('.tabs-container', link);
    jQuery('.tab-body', container).css({ display: 'none' });
    jQuery('.tab-body' + ref, container).css({ display: 'block' });
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
    jQuery('table textarea').TextAreaExpander(40, 200);

    // -- handles tabs
    jQuery('.tabs-container', context).each(function() {
      var container = jQuery(this);
      jQuery('.tab-headers', container).css({ display: 'block' });
      jQuery('.tab-body:not[:first]', container).css({ display: 'none' });
      jQuery('> input:first', container).attr('name', 'active_tab');
      jQuery('.tab-entry a.current-tab', container).each(select_tab);
      jQuery('.tab-entry a', container)
	.each(function() {
	  var link = jQuery(this);
	  var container = link.closest('.tabs-container', link);
	  var err = jQuery('> div' + link.attr('href') + ' .error', container);
	  if (err.size() > 0) link.addClass("with-error");
	})
	.click(select_tab_with_data_refresh);
      container.find('input,textarea,select')
	.change(function() { jQuery(this).addClass('dirty'); })
	.keyup(function() { jQuery(this).addClass('dirty'); });
    });

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
	jQuery(this).next().css({ display: 'block' }).each(function () {
	  var item = jQuery(this);
	  item.css("left", item.prev().position().left);
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
    jQuery('#flash_notice').animate({ opacity: 0 }, 10000);

    // -- nicer tooltips
    jQuery('*[title]').each(function() {
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
      jQuery('#tooltip').stop(true, true).text('').hide();
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

    // -- enable ajax templating via jquery.djtch.js
    jQuery.djtch.setup({
      preUpdateHook:  fixPage,
      postUpdateHook: onload
    });
    jQuery(document).djtchEnable();
  });
})();
