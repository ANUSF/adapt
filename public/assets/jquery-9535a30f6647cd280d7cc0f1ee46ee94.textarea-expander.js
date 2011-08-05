(function() {
  /*
  # Based on JS code by Craig Buckler (see original copyright below).
  #
  # Changes:
  #
  # - reorganised the code a bit
  # - more idiomatic and modern jQuery
  # - removed some unnecessary tests
  # - no class name magic for setting height bounds individually
  # - the TextAreaExpander() method is not called automatically
  #
  # Usage:
  #
  # From JavaScript, use:
  #     $(<node>).TextAreaExpander(<minHeight>, <maxHeight>);
  #     where:
  #       <node> is the DOM node selector, e.g. "textarea"
  #       <minHeight> is the minimum textarea height in pixels (optional)
  #       <maxHeight> is the maximum textarea height in pixels (optional)
  #
  #
  # Olaf Delgado-Friedrichs, The Australian National University, 2011
  */
  /*
  # TextAreaExpander plugin for jQuery
  # v1.0
  # Expands or contracts a textarea height depending on the
  # quantity of content entered by the user in the box.
  #
  # By Craig Buckler, Optimalworks.net
  #
  # As featured on SitePoint.com:
  # http://www.sitepoint.com/blogs/2009/07/29/build-auto-expanding-textarea-1/
  #
  # Please use as you wish at your own risk.
  */
  var $, clip, goodBrowser, resizeTextarea;
  $ = jQuery;
  goodBrowser = !($.browser.msie || $.browser.opera);
  clip = function(val, min, max) {
    return Math.min(max, Math.max(min, val));
  };
  resizeTextarea = function() {
    var clippedHeight, item, newHeight, newLen, newWidth, oldLen, oldWidth;
    item = $(this);
    oldLen = item.data('valLength');
    oldWidth = item.data('boxWidth');
    newLen = item.val().length;
    newWidth = this.offsetWidth;
    if (goodBrowser && (newLen < oldLen || newWidth !== oldWidth)) {
      item.css({
        height: '0px'
      });
    }
    if (newLen !== oldLen || newWidth !== oldWidth) {
      newHeight = this.scrollHeight;
      clippedHeight = clip(newHeight, item.data('hMin'), item.data('hMax'));
      item.css({
        overflow: clippedHeight < newHeight ? "auto" : "hidden",
        height: "" + clippedHeight + "px"
      });
    }
    item.data('valLength', newLen);
    item.data('boxWidth', newWidth);
    return true;
  };
  $.fn.TextAreaExpander = function(minHeight, maxHeight) {
    return this.each(function() {
      return $(this).data('hMin', minHeight).data('hMax', maxHeight).css({
        "padding-top": 0,
        "padding-bottom": 0,
        "resize": "none"
      }).bind("keyup", resizeTextarea).bind("focus", resizeTextarea).triggerHandler("focus");
    });
  };
}).call(this);
