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
    var input = elem.clone();
    var id = elem.attr('id');
    var name = elem.attr('name');
    var n = parseInt(id.match(/\d+/)) + 1;
    input.attr('value', '');
    input.attr('id', id.replace(/\d+/, n));
    input.attr('name', name.replace(/\d+/, n));
    input.change(file_selected);
    elem.after('<p><input type="checkbox" checked="" value="1" ' +
	       'name="' + name.replace(/\[[^\[\]]*\]$/, '[use]') +
	       '" id="' + id.replace(/_[^_]*$/, '_use') +
	       '"/>' + elem.val() + '</p>');
    elem.hide();
    elem.parent().append(input);
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
    jQuery('input[type=file]').change(file_selected);
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
