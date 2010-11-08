/*
 * Author: Olaf Delgado-Friedrichs (odf@github.com)
 * Copyright (c) 2010 ANU
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/**
 * Very simple tab handling via jQuery.
 */

/*jslint white: false, browser: true */
/*global jQuery */

(function($) {
  var tabs = {
    options: {
      header_pattern: '> ul',
      entry_pattern:  '> ul > li',
      body_pattern:   '> div'
    },

    setup: function (options) {
      $.extend(this.options, options || {});
    },

    select: function (reload) {
      var ref       = $(this).attr('href'),
	  selected  = $(ref),
	  container = $(selected.data('container')),
	  entries   = container.find(tabs.options.entry_pattern),
	  form;

      container.find('input[name=active_tab]').attr('value', ref);

      if (reload) {
	//TODO - find a better way to specify the form
	form = selected.closest('form');
	if (form.find('.dirty').length > 0) {
	  form.submit();
	  return false;
	}
      }
      container.find(tabs.options.body_pattern).css({ display: 'none' });
      selected.css({ display: 'block' });
      entries.find('a').removeClass('current-tab');
      entries.find('a[href=' + ref + ']').addClass('current-tab');
      return false;
    },

    signal_errors: function () {
      var link = $(this).find('a');
      if ($(link.attr('href')).find('.error').size() > 0) {
	link.addClass("with-error");
      }
    }
  };

  $.fn.extend({
    tabContainer: function() {
      this.each(function() {
	var node = this;
	var base = $(this);
	base.find(tabs.options.body_pattern)
	  .each(function() { $(this).data('container', node); });
	base.find(tabs.options.header_pattern)
	  .css({ display: 'block' });
	base.find(tabs.options.entry_pattern)
	  .each(tabs.signal_errors)
	  .find('a.current-tab').each(tabs.select, [false]);
      });
    },
    tabLink: function() {
      this.click(tabs.select, [true]);
    }
  });
}(jQuery));
