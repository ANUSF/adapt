(function() {
  /*
   Author: Olaf Delgado-Friedrichs (odf@github.com)
   Copyright (c) 2011 The Australian National University
  
   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files (the
   "Software"), to deal in the Software without restriction, including
   without limitation the rights to use, copy, modify, merge, publish,
   distribute, sublicense, and/or sell copies of the Software, and to
   permit persons to whom the Software is furnished to do so, subject to
   the following conditions:
  
   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.
  
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
   LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  */
  /*
   A jQuery plugin that implements pulldown menues for text fields.
  
   The 'setTimeout' calls, explicit manipulation of the 'display'
   property and other strange quirks of the code were necessary in
   order to make things work properly in Internet Explorer.
  
   Usage example:
  
       $('input:text[data-pulldown-id]').each(function () {
         $(this).addPulldown($('#' + $(this).attr('data-pulldown-id')));
       }
  */  var $, allPulldowns, handlers, hideAllPulldowns;
  $ = jQuery;
  allPulldowns = [];
  hideAllPulldowns = function() {
    return $(allPulldowns).each(function() {
      return $(this).css({
        display: 'none'
      });
    });
  };
  handlers = {
    field: {
      click: function() {
        return false;
      },
      focus: function() {
        var field, pos;
        field = $(this);
        pos = field.offset();
        hideAllPulldowns;
        $(field.data('pulldown')).each(function() {
          var item;
          item = $(this);
          item.data('field', field).css({
            position: 'absolute',
            display: 'block'
          });
          if (pos) {
            return item.css({
              left: pos.left,
              top: pos.top + field.outerHeight()
            });
          }
        });
        return false;
      },
      keyup: function() {
        return $($(this).data('pulldown')).css({
          display: 'none'
        });
      }
    },
    pulldown: {
      click: function(event) {
        var target, text;
        target = $(event.target);
        text = target.hasClass('empty') ? '' : target.text();
        $($(this).data('field')).val(text).trigger('keyup');
        return false;
      }
    }
  };
  $.fn.extend({
    addPulldown: function(pulldown) {
      var element;
      pulldown.bind(handlers.pulldown).appendTo('body');
      element = pulldown.get(0);
      if ($.inArray(element, allPulldowns) < 0) {
        allPulldowns.push(element);
      }
      return this.each(function() {
        return $(this).data('pulldown', element).bind(handlers.field);
      });
    }
  });
  $(document).ready(function() {
    return $('body').click(hideAllPulldowns);
  });
}).call(this);
