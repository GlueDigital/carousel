# Carousel 0.1
# Simple horizontal carousel library, with momentum and snapping.
# Usage:
#   myCarousel = require('carousel') boxDiv, sliderDiv
#   myCarousel.next()

module.exports = carousel = (box, slider, opts={}) ->
  opts.amplitudeCoef = opts.amplitudeCoef or 0.8
  opts.timeConstant = opts.timeConstant or 325
  opts.allowScroll = opts.allowScroll or false
  opts.withDots = opts.withDots or true

  # Instance vars; make sure they aren't bound to the functions!
  min = max = offset = reference = pressed = xform = velocity = frame = snap =
    timestamp = ticker = amplitude = target = timeConstant = overlay = auto =
    alsoScroll = xstart = ystart = startOffset = currSlide = dots =
    mustCancel = null

  # Internal functions
  xpos = (e) ->
    if e.targetTouches?.length >= 1
        return e.targetTouches[0].clientX
    e.clientX

  ypos = (e) ->
    if e.targetTouches?.length >= 1
        return e.targetTouches[0].clientY
    e.clientY

  scroll = (x) ->
    if x > max
      offset = max
    else if x < min
      offset = min
    else
      offset = x
    slider.style[xform] = 'translateX(' + (-offset) + 'px)'
    t = Math.round offset / boxWidth
    if t isnt currSlide
      currSlide = t
      updateDots()

  updateDots = ->
    if dots
      Array.prototype.map.call dots.childNodes, (dot, i) ->
        dot.classList.toggle 'active', i is currSlide

  track = ->
    now = Date.now()
    elapsed = now - timestamp
    timestamp = now
    delta = offset - frame
    frame = offset

    v = 1000 * delta / (1 + elapsed)
    velocity = 0.8 * v + 0.2 * velocity

  autoScroll = ->
    if amplitude
      elapsed = Date.now() - timestamp
      delta = -amplitude * Math.exp(-elapsed / timeConstant)
      if delta > 5 or delta < -5
        scroll target + delta
        requestAnimationFrame autoScroll
      else
        scroll target

  tap = (e) ->
    pressed = true
    xstart = reference = xpos e
    ystart = ypos e
    alsoScroll = false
    startOffset = offset

    velocity = amplitude = 0
    frame = offset
    timestamp = Date.now()
    clearInterval ticker
    ticker = setInterval track, 100
    mustCancel = false

    # if not opts.allowScroll
    #   e.preventDefault()
    #   e.stopPropagation()
    #   false

  drag = (e) ->
    if pressed
      x = xpos e
      delta = reference - x
      totalY = Math.abs ystart - y
      totalX = Math.abs xstart - x
      if totalX > 30 or totalY > 30
        mustCancel = true
      if opts.allowScroll
        # Scroll only if movement has been mostly vertical
        y = ypos e
        if totalY > totalX and totalY > 30
          alsoScroll = true
      if delta > 2 or delta < -2
        reference = x
        scroll offset + delta
    if not alsoScroll
      e.preventDefault()
      e.stopPropagation()
      false

  release = (e) ->
    pressed = false

    clearInterval ticker
    target = offset
    if velocity > 10 or velocity < -10
      amplitude = opts.amplitudeCoef * velocity
      target = offset + amplitude
    target = Math.round(target / snap) * snap
    amplitude = target - offset
    timestamp = Date.now()
    requestAnimationFrame autoScroll

    # if not alsoScroll # Prevent warning about cancelling scroll
    #   e.preventDefault()
    #   e.stopPropagation()
    #   false

  cancelClick = (e) ->
    if mustCancel
      e.preventDefault()
      e.stopPropagation()
      false

  # Public functions
  ret =
    getCurrentSlide: ->
      currSlide

    getSlideCount: ->
      max / boxWidth

    move: (slides) ->
      lastSlide = ret.getSlideCount()
      if currSlide + slides > lastSlide
        slides = lastSlide - currSlide
      if currSlide + slides < 0
        slides = -currSlide

      clearInterval ticker
      target = offset
      target = (Math.round(target / snap) + slides) * snap
      amplitude = target - offset
      timestamp = Date.now()
      requestAnimationFrame autoScroll

      currSlide + slides

    next: ->
      ret.move 1

    prev: ->
      ret.move -1

    nextCyclic: ->
      if ret.getCurrentSlide() is ret.getSlideCount()
        ret.move -ret.getCurrentSlide()
      else
        ret.move 1

    prevCyclic: ->
      if ret.getCurrentSlide is 0
        ret.move ret.getSlideCount()
      else
        ret.move -1

    auto:
      start: (interval = 3000) ->
        f = ->
          ret.nextCyclic() unless pressed
        auto = setInterval f, interval
      stop: ->
        clearInterval auto if auto
        auto = null


  # Initialize
  if typeof window.ontouchstart isnt 'undefined'
    slider.addEventListener 'touchstart', tap
    slider.addEventListener 'touchmove', drag
    slider.addEventListener 'touchend', release
  slider.addEventListener 'mousedown', tap
  slider.addEventListener 'mousemove', drag
  slider.addEventListener 'mouseup', release
  slider.addEventListener 'click', cancelClick

  boxWidth = parseInt(getComputedStyle(box).width, 10)
  sliderWidth = slider.scrollWidth
  max = sliderWidth - boxWidth
  offset = min = 0
  pressed = false
  timeConstant = opts.timeConstant

  snap = boxWidth
  currSlide = 0

  xform = 'transform'
  ['webkit', 'Moz', 'O', 'ms'].every (prefix) ->
    e = prefix + 'Transform'
    if 'undefined' isnt typeof slider.style[e]
      xform = e
      return false
    return true

  # Add indicator dots if requested
  if opts.withDots
    dots = document.createElement 'div'
    dots.classList.add 'dots'
    count = max / boxWidth
    for i in [0..count]
      dot = document.createElement 'div'
      dot.classList.add 'dot'
      dots.appendChild dot
    updateDots()
    box.appendChild dots

  ret
