(function() {
    function toggle(item) {
	var link = jQuery(item);
	var placeholder = link.parent().find('.proxy');
	var content = link.parent().find('.collapsible');
	var field = link.parent().find('input.state');
	if (content.is(':visible')) {
	    content.hide();
	    placeholder.show();
	    link.html('[+]');
	    field.attr('value', 'false');
	} else {
	    content.show();
	    placeholder.hide();
	    link.html('[&ndash;]');
	    field.attr('value', 'true');
	}
    }

    function onload(context) {
	fixPage();

	// -- deals with collapsible page content
	jQuery('.collapsible', context).wrap("<div/>").each(
	    function() {
		var content = jQuery(this);
		content.before('<div class="proxy">&hellip;</div>' +
			       '<div class="clear"/>' +
			       '<input type="hidden" class="state" name=' +
			       '"show-'+content.attr('id')+'"/>');
		var link  = jQuery('<a href="" class="toggle noprint"/>');
		content.parent().prepend(link);
		if (content.hasClass('start-open')) content.hide();
		toggle(link);
	    }
	);
	jQuery('.toggle', context).click(function() {
		toggle(this);
		return false;
	});
	jQuery('.toggle', context).hover(function() {
		jQuery(this).parent().find('.proxy')
		    .addClass('toggle-show');
		jQuery(this).parent().find('.collapsible')
		    .addClass('toggle-hide');
		return false;
	    }, function() {
		jQuery(this).parent().find('.proxy')
		    .removeClass('toggle-show');
		jQuery(this).parent().find('.collapsible')
		    .removeClass('toggle-hide');
	    });
	
	// -- handles tabs
	jQuery('.tabs-container', context).each(
	    function() {
		var container = jQuery(this);
		jQuery('> ul', container).show();
		jQuery('> div', container).hide();
		jQuery('> div:first', container).show();
		jQuery('> ul a:first', container).addClass('current-tab');
		jQuery('> ul a', container).click(
		    function() {
			var link = jQuery(this);
			var ref = link.attr('href');
			jQuery('> div', container).hide();
			jQuery('> div' + ref, container).show();
			jQuery('> ul a', container).removeClass('current-tab');
			link.addClass('current-tab');
			return false;
		    }
		);
	    }
	);
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
