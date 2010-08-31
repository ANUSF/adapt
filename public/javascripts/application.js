(function() {
  function select_tab_with_data_refresh() {
    var link = jQuery(this);
    var chosen_tab = link.attr('href').replace(/.*#/, '#');
    var container = link.closest('.tabs-container', link);
    var form = link.closest('form');
    form.find('input[name=active_tab]').attr('value', chosen_tab);
    if (jQuery.browser.msie) {
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
    jQuery('> div', container).hide();
    jQuery('> div' + ref, container).show();
    jQuery('> ul a', container).removeClass('current-tab');
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
    elem.after('<p><input type="checkbox" checked="" value="1" ' +
	       'name="' + name.replace(/\[[^\[\]]*\]$/, '[use]') +
	       '" id="' + id.replace(/_[^_]*$/, '_use') +
	       '"/>' + elem.val().replace(/^.*[\/\\]/, '') + '</p>');
    elem.hide();
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
      item.focus();
    }
  }

  function multitext_cleanup() {
    var item = jQuery(this);
    var row  = item.parent().closest('.multi');
    if (is_empty(row) && !is_last(row))
      setTimeout(function() { row.remove(); }, 200);
  }

  function onload(context) {
    fixPage();

    // -- auto-resize certain textareas (must be done before hiding content)
    jQuery('table textarea').TextAreaExpander(40, 200);

    // -- handles tabs
    jQuery('.tabs-container', context).each(function() {
      var container = jQuery(this);
      jQuery('> ul', container).show();
      jQuery('> div', container).hide();
      jQuery('> input:first', container).attr('name', 'active_tab');
      jQuery('> ul a.current-tab:first', container).each(select_tab);
      jQuery('> ul a', container)
	.each(function() {
	  var link = jQuery(this);
	  var container = link.closest('.tabs-container', link);
	  var err = jQuery('> div' + link.attr('href') + ' .error', container);
	  if (err.size() > 0) link.addClass("with-error");
	})
	.click(select_tab_with_data_refresh);
    });

    // -- allows multiple file uploads
    jQuery('input:file.multi', context).change(file_selected);

    // -- automatic extension of multiple text input field collections
    jQuery('.multi', context).find('input:text,textarea')
      .keyup(multitext_edited).change(multitext_edited).blur(multitext_cleanup);

    // -- update textfields with selection dropdowns
    jQuery('select.predefined', context)
      .blur(function() {
	jQuery(this).hide();
      })
      .change(function() {
	var item = jQuery(this);
	item.prev().val(item.selected().val()).keyup();
      })
      .prev()
      .mousedown(function() {
	jQuery(this).next().toggle();
      })
      .focus(function() {
	jQuery('select.predefined', context).hide();
	jQuery(this).next().show().each(function () {
	  var item = jQuery(this);
	  item.css("left", item.prev().position().left);
	});
      })
      .blur(function() {
	var dropdown = jQuery(this).next();
	  setTimeout(function() {
	    if (jQuery("*:focus").attr('id') != dropdown.attr('id')) {
	      dropdown.hide();
	    }
	  }, 200);
      })
      .keyup(function() {
	var dropdown = jQuery(this).next();
	setTimeout(function() { dropdown.hide(); }, 200);
      });
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
