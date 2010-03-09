(function() {
    function onload(context) {
	fixPage();

	// -- deals with collapsible page content
	jQuery('.collapsible', context).hide().wrap("<div></div>").before(
          '<a href="" class="toggle noprint">[+]</a>' +
          '<div class="proxy">&hellip;</div><div class="clear"/>' +
	  '<input type = "hidden" class = "state" name = "" value = "">' );
	jQuery('.collapsible.start-open', context).each(function() {
		var content = jQuery(this);
		var placeholder = content.parent().find('.proxy');
		var link = content.parent().find('.toggle');
		var field = content.parent().find('input.state');

		content.show();
		placeholder.hide();
		link.html('[&ndash;]');
		field.attr('name', content.attr('id'));
		field.attr('value', 'true');
	});
	jQuery('.toggle', context).click(function() {
		var link = jQuery(this);
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
		    field.attr('name', content.attr('id'));
		    field.attr('value', 'true');
		}
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
