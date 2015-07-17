# Carousel 0.1
# Simple horizontal carousel library, with momentum and snapping.
# Usage:
#   myCarousel = require('carousel') boxDiv, sliderDiv
#   myCarousel.next()

module.exports = carousel = (box, slider) ->

  # Instance vars
  min = max = offset = reference = pressed = xform = velocity = frame = snap =
    timestamp = ticker = amplitude = target = timeConstant = count = overlay =
    null

  # Internal functions
  xpos = (e) ->
    if e.targetTouches?.length >= 1
        return e.targetTouches[0].clientX
    e.clientX

  scroll = (x) ->
    if x > max
      offset = max
    else if x < min
      offset = min
    else
      offset = x
    slider.style[xform] = 'translateX(' + (-offset) + 'px)'

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
    reference = xpos e

    velocity = amplitude = 0
    frame = offset
    timestamp = Date.now()
    clearInterval ticker
    ticker = setInterval track, 100

    e.preventDefault()
    e.stopPropagation()
    false

  drag = (e) ->
    if pressed
      x = xpos e
      delta = reference - x
      if delta > 2 or delta < -2
        reference = x
        scroll offset + delta
    e.preventDefault()
    e.stopPropagation()
    false

  release = (e) ->
    pressed = false

    clearInterval ticker
    target = offset
    if velocity > 10 or velocity < -10
      amplitude = 0.8 * velocity
      target = offset + amplitude
    target = Math.round(target / snap) * snap
    amplitude = target - offset
    timestamp = Date.now()
    requestAnimationFrame autoScroll

    e.preventDefault()
    e.stopPropagation()
    false

  # Public functions
  ret =
    getCurrentSlide: ->
      Math.round offset / boxWidth

    getSlideCount: ->
      max / boxWidth

    move: (screens) ->
      clearInterval ticker
      target = offset
      target = (Math.round(target / snap) + screens) * snap
      amplitude = target - offset
      timestamp = Date.now()
      requestAnimationFrame autoScroll

      endScreen = ret.getCurrentSlide() + screens
      lastScreen = ret.getSlideCount()
      endScreen = 0 if endScreen < 0
      endScreen = lastScreen if endScreen > lastScreen
      endScreen

    next: ->
      ret.move 1

    prev: ->
      ret.move -1

  # Initialize
  if typeof window.ontouchstart isnt 'undefined'
    slider.addEventListener 'touchstart', tap
    slider.addEventListener 'touchmove', drag
    slider.addEventListener 'touchend', release
  slider.addEventListener 'mousedown', tap
  slider.addEventListener 'mousemove', drag
  slider.addEventListener 'mouseup', release

  boxWidth = parseInt(getComputedStyle(box).width, 10)
  sliderWidth = slider.scrollWidth
  max = sliderWidth - boxWidth
  offset = min = 0
  pressed = false
  timeConstant = 200 # ms

  snap = boxWidth
  count = boxWidth / sliderWidth

  xform = 'transform'
  ['webkit', 'Moz', 'O', 'ms'].every (prefix) ->
    e = prefix + 'Transform'
    if 'undefined' isnt typeof slider.style[e]
      xform = e
      return false
    return true

  ret
