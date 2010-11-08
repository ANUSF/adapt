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
      entry_pattern: '> ul > li',
      body_pattern:  '> div'
    },

    setup: function (options) {
      $.extend(this.options, options || {});
    },

    select: function () {
      var ref = $(this).attr('href'),
	  selected = $(ref),
	  container = selected.closest('.tabs-container'),
	  entries = container.find(tabs.options.entry_pattern);
      container.find(tabs.options.body_pattern).css({ display: 'none' });
      selected.css({ display: 'block' });
      entries.find('a').removeClass('current-tab');
      entries.find('a[href=' + ref + ']').addClass('current-tab');
      container.find('> input:first').attr('value', ref);
      return false;
    },

    select_with_reload: function () {
      var ref = $(this).attr('href'),
          link = $(ref).closest('.tabs-container')
		   .find(tabs.options.entry_pattern).find('a[href=' + ref + ']'),
	  form = link.closest('form');
      form.find('input[name=active_tab]').attr('value', ref);

      if (form.find('.dirty').length === 0) {
	link.each(tabs.select);
      }
      else {
	form.submit();
      }

      return false;
    }
  };

  $.fn.extend({
    tabContainer: function() {
      this.each(function() {
	var container = $(this),
	    entries = container.find(tabs.options.entry_pattern);

	container.find('.tab-headers').css({ display: 'block' });
	container.find('> input:first').attr('name', 'active_tab');
	entries.find('a.current-tab').each(tabs.select);
	entries.each(function() {
	  var link = $(this),
	      container = link.closest('.tabs-container', link),
	      err = $('> div' + link.attr('href') + ' .error', container);
	  if (err.size() > 0) {
	    link.addClass("with-error");
	  }
	});
	container.find('input,textarea,select').not('select.predefined')
	  .change(function() { $(this).addClass('dirty'); })
	  .keyup(function() { $(this).addClass('dirty'); });
      });
    },
    tabLink: function() {
      this.click(tabs.select_with_reload);
    }
  });
}(jQuery));
