(function() {
    function onload(context) {
	fixPage();

	// -- deals with collapsible page content
	jQuery('.collapsible', context).hide().wrap("<div></div>").before(
          '<a href="" class="toggle noprint">[+]</a>' +
          '<div class="proxy">&hellip;</div><div class="clear"/>');
	jQuery('.toggle', context).click(function() {
		var link = jQuery(this);
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
