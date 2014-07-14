$doc = $ document
$window = $ window
$body = $ 'body'

pos = 
	left: 0, top: 0, center: 0.5, bottom: 1, right: 1
	get: (p) ->
		return r if (r = @[p])?
		return parseInt(p)/100 if ~p.indexOf '%'

class InfoTooltip
	constructor: ->
		@init()

	init: =>
		$doc = $ document
		$window = $ window
		$body = $ 'body'

		$doc.on 'mouseenter', '[data-tooltip-text]', @_mouseenter
		$doc.on 'mouseleave', '[data-tooltip-text]', @hideTooltip
		$doc.on 'hide-tootlip', @hideTooltip

		@tooltip = $ "<div class='general-help-tooltip'>"
		@tooltip.append @$nub = $ "<div class=\"nub\">"
		@tooltip.append @$text = $ "<div class=\"tooltip-text\">"

		@interval = null

		$body.append @tooltip.hide()

	###
	Hide tooltip
	###
	hideTooltip : =>
		clearTimeout @interval
		@interval = setTimeout =>
			@tooltip.stop(true, true).transition opacity: 0, duration: 100, =>
				@tooltip.hide()
				$window.off 'resize', @hideTooltip
		, 150

	showTooltip: =>
		return if @e.isDefaultPrevented()

		showTooltip = (text = (target = $ @e.currentTarget).attr 'data-tooltip-text').length > 0
		showTooltip and= !target.hasClass 'no-tooltip'
		showTooltip and= !target.attr 'data-no-tooltip'
		
		return unless showTooltip
		@$text.html text
		$window.on 'resize', @hideTooltip

		css = @tooltipPosition target, target.attr 'data-tooltip-position'

		@tooltip.show()
			.css(opacity: 0)
			.css(css.tooltip)
			.removeClass('center left right bottom top')
			.toggleClass(css.classes or '')
			.stop(true, true).transition opacity: 1

		@$nub.attr('style', '').css css.nub

	tooltipPosition: (@target = @target, position) =>
		@position = position or @position or 'center top'
		# return css unless position isnt (css = @target.data 'tooltipPosition').position

		# horizontal & vertical aligniament
		unless ~@position.indexOf '%'
			[h, v] = @position.replace(' ', '-').split '-'
			classes = @position
		else
			[h, v] = @position.split ' '

		{h, v} = h: pos.get(h), v: pos.get v

		offset = target.offset()
		
		top = offset.top + target.outerHeight() * v - @tooltip.outerHeight(false) * (1 - v)
		left = offset.left + target.outerWidth() * h - @tooltip.outerWidth(false) * (1 - h)
		
		nub = classes? and {} or left: (offset.left + target.outerWidth()/2 - 4) - left
		classes ?= offset.top > top and 'top' or 'bottom'

		@target.data 'tooltipPosition', ret = {position, tooltip: {top, left}, nub, classes}
		ret

	###
	Trigger the showTooltip on mouse enter
	###
	_mouseenter : (@e) =>
		clearTimeout @interval
		@interval = setTimeout @showTooltip , 150

tooltip = new InfoTooltip
$ tooltip.init