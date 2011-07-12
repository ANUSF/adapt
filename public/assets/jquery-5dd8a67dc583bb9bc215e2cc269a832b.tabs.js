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
   A simple tab handling plugin for jQuery, featuring a custom event
   'tab-opened' as well as the automatic propagation of a customizable
   set of class tags from the tab body to the associated title link
   (useful e.g. for signaling errors).
  
   Example markup:
  
       <div class='tabs'>
         <ul>
           <li><a href='#tab1'>First Tab Title</a></li>
           <li><a href='#tab2'>Second Tab Title</a></li>
         </ul>
         <div id='tab1'>Content for first tab.</div>
         <div id='tab2'>Content for second tab.</div>
       </div>
  
   Usage example:
  
       function tab_change_handler(event) {
         alert('Opened tab "' + $(event.target).attr('id') + '"');
       }
  
       $(document).ready(function() {
         $('.tabs')
           .tabContainer({ tagsToPropagate: ['error'],
                           currentTabClass: 'open-tab' })
           .find('> div').bind('tab-opened', tab_change_handler);
       }
  
  */  var $, defaultPatterns, propagateTags, select;
  $ = jQuery;
  defaultPatterns = {
    header: '> ul',
    entry: '> ul > li',
    body: '> div',
    link: '> a'
  };
  select = function() {
    var container, options, patterns, ref, selected, tagClass;
    ref = $(this).attr('href');
    selected = $(ref);
    container = $(selected.data('container'));
    options = container.data('options') || {};
    patterns = container.data('patterns') || defaultPatterns;
    tagClass = options.currentTabClass || 'current-tab';
    container.find(patterns.body).css({
      display: 'none'
    });
    selected.css({
      display: 'block'
    });
    container.find(patterns.entry).find(patterns.link).removeClass(tagClass).filter('[href=' + ref + ']').addClass(tagClass);
    selected.trigger('tab-opened');
    return false;
  };
  propagateTags = function() {
    var body, link;
    link = $(this).find('a');
    body = $(link.attr('href'));
    return $.each(arguments, function(index, tag) {
      if (body.find('.' + tag).size() > 0) {
        return link.addClass(tag);
      }
    });
  };
  $.fn.extend({
    tabContainer: function(options) {
      var patterns, tags;
      if (options == null) {
        options = {};
      }
      tags = options.tagsToPropagate || [];
      patterns = {};
      $.extend(patterns, defaultPatterns);
      $.extend(patterns, options.patterns || {});
      return this.each(function() {
        var base;
        base = $(this);
        base.data('options', options);
        base.data('patterns', patterns);
        base.find(patterns.body).data('container', this);
        base.find(patterns.header).css({
          display: 'block'
        });
        return base.find(patterns.entry).each(propagateTags, tags).find(patterns.link).click(select).first().each(select);
      });
    },
    tabSelect: function() {
      return this.each(select);
    },
    tabLink: function() {
      return this.click(select);
    }
  });
}).call(this);
