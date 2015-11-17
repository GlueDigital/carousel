Carousel = require './lib/carousel'

# Initialization logic
window.addEventListener 'DOMContentLoaded', ->
  slider = document.getElementById 'scrollable'
  box = document.getElementById 'view'
  # We make the carousel available through window so you can play with it.
  window.carousel = carousel = Carousel box, slider,
    timeConstant: 200
    allowScroll: true
  document.getElementById('next').addEventListener 'click', carousel.next
  document.getElementById('prev').addEventListener 'click', carousel.prev