Carousel = require './util/carousel'

# Initialization logic

# Start everything by rendering the top component on the page.
window.addEventListener 'DOMContentLoaded', ->
  slider = document.getElementById 'scrollable'
  box = document.getElementById 'view'
  carousel = Carousel box, slider
  document.getElementById('next').addEventListener 'click', carousel.next
  document.getElementById('prev').addEventListener 'click', carousel.prev