###
 Author: Olaf Delgado-Friedrichs (odf@github.com)
 Copyright (c) 2010 ANU

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
###

###
 A jQuery plugin that implements pulldown menues for text fields.

 The 'setTimeout' calls, explicit manipulation of the 'display'
 property and other strange quirks of the code were necessary in
 order to make things work properly in Internet Explorer.

 Usage example:

     $('input:text[data-pulldown-id]').each(function () {
       $(this).addPulldown($('#' + $(this).attr('data-pulldown-id')));
     }
###

$ = jQuery

allPulldowns = []

hideAllPulldowns = -> $(allPulldowns).each -> $(this).css { display: 'none' }

handlers =
  field:
    click: -> false

    focus: ->
      field = $ this
      pos = field.offset()
      hideAllPulldowns

      $(field.data 'pulldown').each ->
        item = $ this
        item.data('field', field).css { position: 'absolute', display: 'block' }
        item.css { left: pos.left, top: pos.top + field.outerHeight() } if pos
      false

    keyup: -> $($(this).data 'pulldown').css { display: 'none' }

  pulldown:
    click: (event) ->
      target = $ event.target
      text   = if target.hasClass 'empty' then '' else target.text()
      $($(this).data 'field').val(text).trigger('keyup')
      false

$.fn.extend
  addPulldown: (pulldown) ->
    this.each ->
      element = pulldown.get 0
      allPulldowns.push element if $.inArray(element, allPulldowns) < 0
      $(this).data('pulldown', element).bind(handlers.field)
      pulldown.bind(handlers.pulldown).appendTo('body')

$(document).ready -> $('body').click hideAllPulldowns
