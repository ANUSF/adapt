(function() {
  function toggle(item) {
    var link = jQuery(item);
    var placeholder = link.parent().find('.proxy');
    var content = link.parent().find('.collapsible');
    if (content.is(':visible')) {
      content.hide();
      placeholder.show();
      link.html('[+]');
    } else {
      content.show();
      placeholder.hide();
      link.html('[&ndash;]');
    }
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
	       '"/>' + elem.val() + '</p>');
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
    var row  = jQuery(this).parent().closest('.multi');
    if (!is_empty(row) && is_last(row)) {
      var new_row = row.clone(true);
      jQuery('input:text,textarea', new_row).each(function() {
	var field = jQuery(this);
	var n = parseInt(field.attr('id').match(/\d+/)) + 1;
	field.attr('id', field.attr('id').replace(/\d+/, n));
	field.attr('name', field.attr('name').replace(/\d+/, n));
	field.val('');
      });
      row.parent().append(new_row);
    }
  }

  function multitext_cleanup() {
    var row  = jQuery(this).parent().closest('.multi');
    if (is_empty(row) && !is_last(row)) row.remove();
  }

  function onload(context) {
    fixPage();

    // -- deals with collapsible page content
    jQuery('.collapsible', context).wrap("<div/>").each(function() {
      var content = jQuery(this);
      content.before('<div class="proxy">&hellip;</div><div class="clear"/>');
      var link = jQuery('<a href="" class="toggle noprint"/>');
      content.parent().prepend(link);
      if (content.hasClass('start-open')) content.hide();
      toggle(link);
    });
    jQuery('.toggle', context).click(function() {
      toggle(this);
      return false;
    });
    jQuery('.toggle', context).hover(function() {
      jQuery(this).parent().find('.proxy').addClass('toggle-show');
      jQuery(this).parent().find('.collapsible').addClass('toggle-hide');
      return false;
    }, function() {
      jQuery(this).parent().find('.proxy').removeClass('toggle-show');
      jQuery(this).parent().find('.collapsible').removeClass('toggle-hide');
    });

    // -- handles tabs
    jQuery('.tabs-container', context).each(function() {
      var container = jQuery(this);
      jQuery('> ul', container).show();
      jQuery('> div', container).hide();
      jQuery('> input:first', container).attr('name', 'active-tab');
      jQuery('> ul a.current-tab:first', container).each(select_tab);
      jQuery('> ul a', container)
	.each(function() {
	  var link = jQuery(this);
	  var container = link.closest('.tabs-container', link);
	  var err = jQuery('> div' + link.attr('href') + ' .error', container);
	  if (err.size() > 0) link.addClass("with-error");
	})
	.click(function() { jQuery('#flash_notice', context).hide(); })
	.click(select_tab);
    });

    // -- allows multiple file uploads
    jQuery('input:file.multi', context).change(file_selected);

    // -- automatic extension of multiple text input field collections
    jQuery('.multi', context).find('input:text,textarea')
      .keyup(multitext_edited).blur(multitext_cleanup);
  }

  function fixPage() {
    jQuery('table.zebra')
      .find('tr:nth-child(odd)').removeClass('odd').addClass('even').end()
      .find('tr:nth-child(even)').removeClass('even').addClass('odd');
  }

  jQuery(document).ready(function() {
    onload(document);

    // -- enable ajax templating via jquery.djtch.js
    jQuery.djtch.setup({
      preUpdateHook:  onload,
      postUpdateHook: fixPage
    });
    jQuery(document).djtchEnable();
  });
})();
