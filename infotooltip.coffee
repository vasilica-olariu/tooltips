$doc = $ document
$window = $ window
$body = $ 'body'

pos = 
	left: 0, top: 0, center: 0.5, bottom: 1, right: 1
	get: (p) ->
		return r if (r = @[p])?
		return parseInt(p)/100 if ~p.indexOf '%'
	classes: 'center left right bottom top'

__delay = (fn, t = 10) -> _delay = null; ->  clearTimeout(_delay); _delay = setTimeout fn, t

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
		@interval = setTimeout @_hideTooltip, 150

	_hideTooltip: =>
		@tooltip.stop(true, true).transition opacity: 0, duration: 100, =>
			@tooltip.hide()
			$window.off 'resize', @hideTooltip

	checkAndHide: (target) =>
		do @hideTooltip unless target.is ':visible'

	showTooltip: =>
		return if @e.isDefaultPrevented()

		img_src = (target = $ @e.currentTarget).attr 'data-tooltip-image'
		showTooltip = (img_src or text = (target = $ @e.currentTarget).attr 'data-tooltip-text').length > 0
		showTooltip and= !target.hasClass 'no-tooltip'
		showTooltip and= !target.attr 'data-no-tooltip'
		@tooltip.removeClass(@customClass).addClass @customClass = target.data 'tooltip-class'
		
		return unless showTooltip

		unless img_src and img_src is @img_src
			if @img_src = img_src
				@$text.html @imgTmpl img_src

				unless @imageLoaded()
					@_hideTooltip()
					return @loadImage().then @showTooltip
			else @$text.html text

		$window.on 'resize', @hideTooltip

		unless target.data 'has_click_bind'
			target.bind 'click', __delay @checkAndHide.bind(@, target), 0
			target.data 'has_click_bind', true

		@tooltip.toggleClass('image-tooltip', !!img_src).css(top: -999, left: -999).show()
		css = @tooltipPosition target, target.attr 'data-tooltip-position'

		@tooltip.show()
			.attr('style': '')
			.css(opacity: 0)
			.css(css.tooltip)
			.removeClass(pos.classes)
			.addClass(css.classes or '')
			.stop(true, true).transition opacity: 1

		@$nub.attr('style', '').css css.nub

	imgTmpl: (src) -> "<img src=\"#{src}\" alt=\"#{src}\" class=\"tooltip-image\" />"

	tooltipPosition: (target, position, ret) =>
		position or= 'center top'

		# horizontal & vertical aligniament
		unless ~position.indexOf '%'
			[h, v] = position.replace(' ', '-').split '-'
			class_h = h
			class_v = v if v is 'center'
		else
			[h, v] = position.split ' '

		{h, v} = h: pos.get(h), v: pos.get v

		offset = target.offset()

		tooltipOuterHeight = @tooltip.outerHeight(true)
		top = offset.top + target.outerHeight() * v - tooltipOuterHeight * (1 - v)
		left = offset.left + target.outerWidth() * h - @tooltip.outerWidth() * (1 - h)
		left -= Math.max 0, left + @tooltip.outerWidth(true) - ($window.width() - $window.scrollLeft())

		if top < (wst = $window.scrollTop())
			top = offset.top + target.outerHeight() * 1-v - tooltipOuterHeight * v
		
		nub = classes? and {} or left: (offset.left + target.outerWidth()/2) - left - (tooltipOuterHeight - @tooltip.outerHeight false)/2 + 3
		classes = (class_h or '') + ' ' + (class_v or (offset.top > top and 'top' or 'bottom'))

		@tooltip.removeClass(pos.classes).addClass classes
		
		return @tooltipPosition ([].slice.call(arguments).concat true)... unless ret?

		{position, tooltip: {top, left}, nub, classes}

	###
	Trigger the showTooltip on mouse enter
	###
	_mouseenter : (@e) =>
		clearTimeout @interval
		@interval = setTimeout @showTooltip , 150

	loadImage: =>
		def = new $.Deferred

		def.resolve() if @imageLoaded()
		@$text.find('img').bind 'load', def.resolve.bind def

		def.promise()

	imageLoaded: =>
		if (img = @$text.find('img').get 0)? then img.complete else true

tooltip = new InfoTooltip
$ tooltip.init