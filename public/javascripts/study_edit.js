/*jslint white: false, browser: true, regexp: false */
/*global jQuery */

(function($) {
  $(document).ready(function() {
    // -- auto-resize certain textareas (must be done before hiding content)
    $('table textarea').TextAreaExpander(40, 200);

    // -- tag fields that have been edited
    $('input,textarea,select').not('select.predefined')
      .change(function() { $(this).addClass('dirty'); })
      .keyup (function() { $(this).addClass('dirty'); });

    // -- disable the return key in text fields
    $('form').delegate('input:text', 'keypress', function(ev) {
      return (ev.keyCode !== 13);
    });
  });
}(jQuery));
