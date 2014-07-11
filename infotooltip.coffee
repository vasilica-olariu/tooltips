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
		$doc.on 'mouseenter', '[data-tooltip-text]', @_mouseenter
		$doc.on 'mouseleave', '[data-tooltip-text]', @hideTooltip
		$doc.on 'hide-tootlip', @hideTooltip
		@tooltip = $ "<div class='general-help-tooltip'>"
		@interval = null

		$body.append @tooltip

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
		
		if showTooltip
			@tooltip.html text
			$window.on 'resize', @hideTooltip

			@tooltip.show()
				.css(opacity: 0)
				.css(@tooltipPosition target, target.attr 'data-tooltip-position')
				.removeClass('center left right bottom top').addClass(@position)
				.stop(true, true).transition opacity:1

	tooltipPosition: (@target = @target, position) =>
		@position = position or @position or 'center top'
		# horizontal & vertical aligniament
		[h, v] = @position.replace(' ', '-').split '-'
		{h, v} = h: pos.get(h), v: pos.get v

		offset = target.offset()
		
		top = offset.top + target.outerHeight() * v - @tooltip.outerHeight(false) * (1 - v)
		left = offset.left + target.outerWidth() * h - @tooltip.outerWidth(false) * (1 - h)
		
		{top, left}

	###
	Trigger the showTooltip on mouse enter
	###
	_mouseenter : (@e) =>
		clearTimeout @interval
		@interval = setTimeout @showTooltip , 150

module.exports = new InfoTooltip