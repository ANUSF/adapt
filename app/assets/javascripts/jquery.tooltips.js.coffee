###
# Author: Olaf Delgado-Friedrichs (odf@github.com)
# Copyright (c) 2011 The Australian National University
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

###
# Prettier tooltips via Javascript and jQuery.
#
# To enable tooltips, do:
#
#     $(document).enableTooltips();
#
# To use a different id for the tooltip element than the default
# 'tooltip', do:
#
#     $(document).enableTooltips({ tooltipId: 'my-tip' });
#
# To nap the tooltips from the title attributes, do:
#     $('*[title]').each(function () {
#       $(this).addTooltip($(this).attr('title')).removeAttr('title');
#     });
#
# Styling example:
#     #tooltip {
#       background-color: #ffc;
#       border:           1px solid #ccc;
#       padding:          2px;
#       text-align:       left;
#       width:            20em;
#     }
###

$ = jQuery

tooltipId = 'tooltip'

fadeInDelay = 3000

findTooltip = -> $('#' + tooltipId)

hideTooltip = -> findTooltip().stop(true, true).fadeOut('fast')


handlers =
  target:
    mouseenter: (e) ->
      console.log "mouseenter"
      tipText = $(this).data 'tipText'
      if tipText?.length
        findTooltip().
          stop(true, true).
          css({ display: 'none' }).
          text(tipText).
          delay(fadeInDelay).
          fadeIn('slow')

    mouseleave: hideTooltip
    mousedown: hideTooltip
    keydown:   hideTooltip

  body:
    mousemove: (e) ->
      win     = $ window
      tooltip = findTooltip()
      maxLeft = win.width() - tooltip.outerWidth()
      maxTop  = win.height() + win.scrollTop() - tooltip.outerHeight()
      left    = Math.min e.pageX + 20, maxLeft
      top     = Math.min e.pageY + 10, maxTop

      if e.pageX + 20 > left && e.pageY + 10 > top
        left = e.pageX - tooltip.outerWidth() - 20

      tooltip.css { left: left, top: top }

$.fn.extend
  addTooltip: (text) ->
    this.each -> $(this).data('tipText', text).bind(handlers.target)

  enableTooltips: (options = {}) ->
    tooltipId   = options.tooltipId or "tooltip"
    fadeInDelay = options.delay or 3000
    $("<p id='#{tooltipId}'/>").
      css({ display: 'none', position: 'absolute' }).
      appendTo('body');
    $('body').bind handlers.body
