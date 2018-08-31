optsDefaults =
  amplitudeCoef: 0.8
  timeConstant: 325
  allowScroll: false
  withDots: true
  dotsClickable: true
  dotsParent: null
  useTranslate3d: true
  snapParts: true
  slidePerTouch: false
  onDotsUpdated: null

module.exports = carousel = (box, slider, opts={}) ->
  for key of optsDefaults
    opts[key] = optsDefaults[key] if not opts.hasOwnProperty key

  # Instance vars; make sure they aren't bound to the functions!
  min = max = offset = reference = pressed = xform = velocity = frame = snap =
    timestamp = ticker = amplitude = target = timeConstant = overlay = auto =
    scrollInstead = xstart = ystart = startOffset = currSlide = dots =
    mustCancel = boxWidth = null

  # Internal functions
  xpos = (e) ->
    if e.targetTouches?.length >= 1
      return e.targetTouches[0].clientX
    e.clientX

  ypos = (e) ->
    if e.targetTouches?.length >= 1
      return e.targetTouches[0].clientY
    e.clientY

  updateDots = ->
    if dots
      Array.prototype.map.call dots.childNodes, (dot, i) ->
        if i is currSlide
          dot.classList.add 'active'
        else
          dot.classList.remove 'active'
    opts.onDotsUpdated? currSlide, Math.round max / snap

  scroll = (x) ->
    if x > max
      offset = max
    else if x < min
      offset = min
    else
      offset = x
    if opts.useTranslate3d
      slider.style[xform] = 'translate3d(' + (-offset) + 'px, 0, 0)'
    else
      slider.style[xform] = 'translateX(' + (-offset) + 'px)'
    t = Math.round offset / snap
    if t isnt currSlide
      currSlide = t
      updateDots()

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
      if delta > 0.5 or delta < -0.5
        scroll target + delta
        window.requestAnimationFrame autoScroll
      else
        scroll target

  tap = (e) ->
    pressed = true
    xstart = reference = xpos e
    ystart = ypos e
    scrollInstead = null
    startOffset = offset

    velocity = amplitude = 0
    frame = offset
    timestamp = Date.now()
    window.clearInterval ticker
    ticker = window.setInterval track, 100
    mustCancel = false

    # if not opts.allowScroll
    #   e.preventDefault()
    #   e.stopPropagation()
    #   false

  drag = (e) ->
    if pressed and not scrollInstead
      x = xpos e
      y = ypos e
      delta = reference - x
      totalY = Math.abs ystart - y
      totalX = Math.abs xstart - x
      if totalX > 30 or totalY > 30
        mustCancel = true
      if opts.allowScroll and scrollInstead is null
        # Scroll only if movement has been mostly vertical
        if totalY > totalX
          scrollInstead = true
          return
        else
          scrollInstead = false
      if delta > 2 or delta < -2
        reference = x
        scroll offset + delta
    if scrollInstead is false
      e.preventDefault()
      e.stopPropagation()
      false

  release = ->
    pressed = false

    window.clearInterval ticker
    target = offset
    if velocity > 10 or velocity < -10
      amplitude = opts.amplitudeCoef * velocity
      target = offset + amplitude
    if opts.slidePerTouch
      if offset - startOffset < 0
        target = startOffset - snap
      else
        target = startOffset + snap
    target = Math.round(target / snap) * snap
    amplitude = target - offset
    timestamp = Date.now()
    window.requestAnimationFrame autoScroll

  cancelClick = (e) ->
    if mustCancel
      e.preventDefault()
      e.stopPropagation()
      false

  initialize = (handler) ->
    # Initialize
    if typeof window.ontouchstart isnt 'undefined'
      box.addEventListener 'touchstart', tap
      box.addEventListener 'touchmove', drag
      box.addEventListener 'touchend', release
    box.addEventListener 'mousedown', tap
    box.addEventListener 'mousemove', drag
    box.addEventListener 'mouseup', release
    box.addEventListener 'click', cancelClick, true
    box.addEventListener 'dragstart', (e) ->
      e.preventDefault()
      false

    boxWidth = parseInt(window.getComputedStyle(slider).width, 10)
    sliderWidth = slider.scrollWidth
    max = sliderWidth - boxWidth
    if max < 0
      max = 0
    offset = min = 0
    pressed = false
    timeConstant = opts.timeConstant

    currSlide = 0
    snap = boxWidth
    if opts.snapParts
      # Check if parts are smaller than one slide, and snap to those instead
      c = slider.firstChild
      while c
        if c.nodeType isnt 3
          candidate = parseInt(window.getComputedStyle(c).width, 10)
          if candidate > 20 and candidate < snap
            snap = candidate
            break
        c = c.nextSibling

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
      count = max / snap
      for i in [0..count]
        dot = document.createElement 'div'
        if opts.dotsClickable
          do (i) ->
            dot.addEventListener 'click', (e) ->
              e.preventDefault()
              handler.jumpTo i
        dot.classList.add 'dot'
        dots.appendChild dot
      updateDots()
      if opts.dotsParent
        opts.dotsParent.appendChild dots
      else
        box.appendChild dots

    opts.onDotsUpdated? currSlide, Math.round max / snap

  tearDown = ->
    box.removeEventListener 'touchstart', tap
    box.removeEventListener 'touchmove', drag
    box.removeEventListener 'touchend', release
    box.removeEventListener 'mousedown', tap
    box.removeEventListener 'mousemove', drag
    box.removeEventListener 'mouseup', release
    box.removeEventListener 'click', cancelClick, true
    if dots
      dots.parentNode.removeChild dots
    scroll 0

  # Public functions
  ret =
    getCurrentSlide: ->
      currSlide

    getSlideCount: ->
      Math.round max / snap

    move: (slides) ->
      lastSlide = ret.getSlideCount()
      if currSlide + slides > lastSlide
        slides = lastSlide - currSlide
      if currSlide + slides < 0
        slides = -currSlide

      window.clearInterval ticker
      target = offset
      target = (Math.round(target / snap) + slides) * snap
      amplitude = target - offset
      timestamp = Date.now()
      window.requestAnimationFrame autoScroll

      currSlide + slides

    jumpTo: (slide) ->
      ret.move slide - currSlide

    teleportTo: (slides) ->
      target = (Math.round(target / snap) + slides) * snap
      scroll target
      currSlide + slides

    next: (e) ->
      e?.preventDefault?()
      ret.move 1

    prev: (e) ->
      e?.preventDefault?()
      ret.move -1

    nextCyclic: (e) ->
      e?.preventDefault?()
      if ret.getCurrentSlide() is ret.getSlideCount()
        ret.move -ret.getCurrentSlide()
      else
        ret.move 1

    prevCyclic: (e) ->
      e?.preventDefault?()
      if ret.getCurrentSlide is 0
        ret.move ret.getSlideCount()
      else
        ret.move -1

    auto:
      start: (interval = 3000) ->
        f = ->
          ret.nextCyclic() unless pressed
        auto = window.setInterval f, interval
      stop: ->
        window.clearInterval auto if auto
        auto = null

    reset: ->
      tearDown()
      initialize()

  initialize ret
  ret
