/*jslint white: false, browser: true, regexp: false */
/*global jQuery */

(function($) {
  $(document).ready(function() {
    // -- auto-resize certain textareas (must be done before hiding content)
    $('table textarea').TextAreaExpander(40, 200);

    // -- update textfields with selection dropdowns
    $('input:text[data-selection-id]').each(function () {
      var item = $(this), pulldown = $(item.attr('data-selection-id'));
      item.addPulldown(pulldown);
      pulldown.css({ display: 'none' });
    });

    // -- tag fields that have been edited
    $('input,textarea,select').not('select.predefined')
      .change(function() { $(this).addClass('dirty'); })
      .keyup (function() { $(this).addClass('dirty'); });

    // -- disable the return key in text fields
    $('form').delegate('input:text', 'keypress', function(ev) {
      return (ev.keyCode !== 13);
    });

    // -- prepare overlay for modal dialogs
    $('<div id="overlay">')
      .append('<div id="blanket">')
      .appendTo('body');

    // -- show overlayed message whenever the form is submitted
    $('form').submit(function () {
      $('<div id="alert" class="dialog">')
	.append('<span class="busy-indicator" />')
	.append('Loading...')
	.appendTo('#overlay');
      $('#overlay').css('display', 'block');
    });
  });
}(jQuery));
