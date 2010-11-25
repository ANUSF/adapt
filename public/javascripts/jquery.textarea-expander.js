/**
 * TextAreaExpander plugin for jQuery
 * v1.0
 * Expands or contracts a textarea height depending on the
 * quatity of content entered by the user in the box.
 *
 * By Craig Buckler, Optimalworks.net
 *
 * As featured on SitePoint.com:
 * http://www.sitepoint.com/blogs/2009/07/29/build-auto-expanding-textarea-1/
 *
 * Please use as you wish at your own risk.
 */

/**
 * This is a slight variation of Buckler's original code:
 *
 * - the formatting was changed
 * - no class name magic for setting height bounds individually
 * - the TextAreaExpander() method is not called automatically
 *
 * Olaf Delgado-Friedrichs, ANUSF, 2010-09-02
 */

/**
 * Usage:
 *
 * From JavaScript, use:
 *     $(<node>).TextAreaExpander(<minHeight>, <maxHeight>);
 *     where:
 *       <node> is the DOM node selector, e.g. "textarea"
 *       <minHeight> is the minimum textarea height in pixels (optional)
 *       <maxHeight> is the maximum textarea height in pixels (optional)
 */

(function($) {
  $.fn.TextAreaExpander = function(minHeight, maxHeight) {
    var hCheck = !($.browser.msie || $.browser.opera);

    function ResizeTextarea(e) {
      // event or initialize element?
      e = e.target || e;

      // find content length and box width
      var vlen = e.value.length, ewidth = e.offsetWidth;

      if (vlen != e.valLength || ewidth != e.boxWidth) {
	if (hCheck && (vlen < e.valLength || ewidth != e.boxWidth))
	  e.style.height = "0px";
	var h = Math.max(e.expandMin, Math.min(e.scrollHeight, e.expandMax));

	e.style.overflow = (e.scrollHeight > h ? "auto" : "hidden");
	e.style.height = h + "px";

	e.valLength = vlen;
	e.boxWidth = ewidth;
      }

      return true;
    };

    // initialize
    this.each(function() {
      // is a textarea?
      if (this.nodeName.toLowerCase() != "textarea") return;

      // set height restrictions
      this.expandMin = minHeight;
      this.expandMax = maxHeight;

      // initial resize
      ResizeTextarea(this);

      // zero vertical padding and add events
      if (!this.Initialized) {
	this.Initialized = true;
	$(this).css({"padding-top": 0, "padding-bottom": 0, "resize": "none"});
	$(this).bind("keyup", ResizeTextarea).bind("focus", ResizeTextarea);
      }
    });

    return this;
  };
})(jQuery);
