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

    select: function () {
      var ref       = $(this).attr('href'),
	  selected  = $(ref),
	  container = $(selected.data('container')),
	  callback  = selected.data('callback');

      //TODO - better way to pass this info around
      container.find('input[name=active_tab]').attr('value', ref);

      if (!callback || callback(selected)) {
	container.find(tabs.patterns.body).css({ display: 'none' });
	selected.css({ display: 'block' });
	container.find(tabs.patterns.entry)
	  .find('> a').removeClass('current-tab')
	  .filter('[href=' + ref + ']').addClass('current-tab');
      }
      return false;
    },

    propagate_tags: function () {
      var link = $(this).find('a');
      var body = $(link.attr('href'));
      $.each(arguments, function (index, tag) {
	if (body.find('.' + tag).size() > 0) {
	  link.addClass(tag);
	}
      });
    }
  };

  $.fn.extend({
    tabContainer: function(options) {
      this.each(function() {
	var node     = this,
	    base     = $(this),
	    tags     = (options || {}).tags_to_propagate || [],
	    callback = (options || {}).callback;
	base.find(tabs.patterns.body).each(function() {
	  $(this).data('container', node).data('callback', callback);
	});
	base.find(tabs.patterns.header)
	  .css({ display: 'block' });
	base.find(tabs.patterns.entry)
	  .each(tabs.propagate_tags, tags)
	  .find('> a').click(tabs.select)
	  .filter('.current-tab').each(tabs.select);
      });
    },
    tabLink: function() {
      this.click(tabs.select);
    }
  });
}(jQuery));
