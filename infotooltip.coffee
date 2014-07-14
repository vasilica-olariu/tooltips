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

		$doc.on 'mouseenter', '[data-tooltip-text],[data-tooltip-image]', @_mouseenter
		$doc.on 'mouseleave', '[data-tooltip-text],[data-tooltip-image]', @hideTooltip
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

		img_src = (target = $ @e.currentTarget).attr 'data-tooltip-image'
		showTooltip = (img_src or text = (target = $ @e.currentTarget).attr 'data-tooltip-text').length > 0
		showTooltip and= !target.hasClass 'no-tooltip'
		showTooltip and= !target.attr 'data-no-tooltip'
		
		return unless showTooltip
		@$text.html unless img_src then text else @imgTmpl img_src
		$window.on 'resize', @hideTooltip

		@tooltip.toggleClass('image-tooltip', !!img_src).css(top: -999, left: -999).show()
		css = @tooltipPosition target, target.attr 'data-tooltip-position'

		@tooltip.show()
			.attr('style': '')
			.css(opacity: 0)
			.css(css.tooltip)
			.removeClass('center left right bottom top')
			.toggleClass(css.classes or '')
			.stop(true, true).transition opacity: 1

		@$nub.attr('style', '').css css.nub

	imgTmpl: (src) -> "<img src=\"#{src}\" alt=\"#{src}\" class=\"tooltip-image\" />"

	tooltipPosition: (target, position) =>
		position or= 'center top'

		# horizontal & vertical aligniament
		unless ~position.indexOf '%'
			[h, v] = position.replace(' ', '-').split '-'
			classes = position
		else
			[h, v] = position.split ' '

		{h, v} = h: pos.get(h), v: pos.get v

		offset = target.offset()
		
		top = offset.top + target.outerHeight() * v - @tooltip.outerHeight(false) * (1 - v)
		left = offset.left + target.outerWidth() * h - @tooltip.outerWidth(false) * (1 - h)
		
		nub = classes? and {} or left: (offset.left + target.outerWidth()/2 - 4) - left
		classes ?= offset.top > top and 'top' or 'bottom'

		target.data 'tooltipPosition', ret = {position, tooltip: {top, left}, nub, classes}
		ret

	###
	Trigger the showTooltip on mouse enter
	###
	_mouseenter : (@e) =>
		clearTimeout @interval
		@interval = setTimeout @showTooltip , 150

tooltip = new InfoTooltip
$ tooltip.init