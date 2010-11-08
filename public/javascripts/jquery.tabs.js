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
    patterns: {
      header: '> ul',
      entry:  '> ul > li',
      body:   '> div'
    },

    select: function (element, callback) {
      var ref       = element.attr('href'),
	  selected  = $(ref),
	  container = $(selected.data('container')),
	  entries   = container.find(tabs.patterns.entry),
	  form;

      //TODO - better way to pass this info around
      container.find('input[name=active_tab]').attr('value', ref);

      if (!callback || callback(selected)) {
	container.find(tabs.patterns.body).css({ display: 'none' });
	selected.css({ display: 'block' });
	entries.find('a').removeClass('current-tab');
	entries.find('a[href=' + ref + ']').addClass('current-tab');
      }
      return false;
    },

    propagate_tags: function () {
      var link = $(this).find('a');
      var body = $(link.attr('href'));
      $.each(arguments, function (index, tag) {
	if (body.find('[class=' + tag + ']').size() > 0) {
	  link.addClass(tag);
	}
      });
    }
  };

  $.fn.extend({
    tabContainer: function(options) {
      this.each(function() {
	var node = this,
	    base = $(this),
	    tags = options && options.tags_to_propagate || [];
	base.find(tabs.patterns.body)
	  .each(function() { $(this).data('container', node); });
	base.find(tabs.patterns.header)
	  .css({ display: 'block' });
	base.find(tabs.patterns.entry)
	  .each(tabs.propagate_tags, tags)
	  .find('a.current-tab').each(function () {
	    return tabs.select($(this));
	  });
      });
    },
    tabLink: function(callback) {
      this.click(function () {
	return tabs.select($(this), callback);
      });
    }
  });
}(jQuery));
