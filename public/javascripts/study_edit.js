/*jslint white: false, browser: true, regexp: false */
/*global jQuery */

(function($) {
     function tag_as_dirty() {
	 var item = $(this), parent = item.parent();
	 item.addClass('dirty');
	 if (parent.is('td')) {
	     parent.addClass('dirty');
	 }
     };

  $(document).ready(function() {
    // -- update textfields with selection dropdowns
    $('input:text[data-selection-id]').each(function () {
      var item = $(this), pulldown = $(item.attr('data-selection-id'));
      item.addPulldown(pulldown);
      pulldown.css({ display: 'none' }).addClass('adapt-pulldown');
    });

    // -- fix for IE6 to make choice items highlight on hover
    $('.adapt-choices li').hover(
      function () { $(this).addClass('hover'); },
      function () { $(this).removeClass('hover'); }
    );

    // -- tag fields that have been edited
    $('input,textarea,select').change(tag_as_dirty).keyup(tag_as_dirty);

    // -- disable the return key in text fields
    $('form').delegate('input:text', 'keypress', function(ev) {
      return (ev.keyCode !== 13);
    });

    // -- prepare overlay for modal dialogs
    $('<div id="adapt-overlay">')
      .append('<div class="blanket">')
      .appendTo('body');

    // -- show overlayed message whenever the form is submitted
    $('form').submit(function () {
      $('<div id="alert" class="dialog">')
	.append('<span class="busy-indicator" />')
	.append('Adapt is synchronizing your data...')
	.appendTo('#adapt-overlay');
      $('#adapt-overlay').css('display', 'block');
    });
  });
}(jQuery));
