(function() {
    function onload(context) {
	fixPage();
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
