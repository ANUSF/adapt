###
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
###

###
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
###

$ = jQuery

hCheck = not ($.browser.msie or $.browser.opera)

clip = (val, min, max) -> Math.min max, Math.max min, val

resizeTextarea = ->
  item = $(this)

  # find content length and box width
  vlen   = this.value.length
  ewidth = this.offsetWidth

  # workaround for IE and Opera idiosyncrasy
  if hCheck and (vlen < this.valLength or ewidth != this.boxWidth)
    item.css
      height: '0px'

  # update the height and the overflow property
  if vlen != this.valLength or ewidth != this.boxWidth
    h = clip this.scrollHeight, item.data('hMin'), item.data('hMax')
    item.css
      overflow: if this.scrollHeight > h then "auto" else "hidden"
      height: h + "px"

  # memorise the current values
  this.valLength = vlen
  this.boxWidth = ewidth

  # return true so that normal callbacks still run
  true


$.fn.TextAreaExpander = (minHeight, maxHeight) ->
  this.each ->
    $(this).
      data('hMin', minHeight).
      data('hMax', maxHeight).
      css({ "padding-top": 0, "padding-bottom": 0, "resize": "none" }).
      bind("keyup", resizeTextarea).bind("focus", resizeTextarea).
      triggerHandler "focus"
