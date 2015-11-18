Carousel = require './lib/carousel'

init = (container) ->
  find = (q) -> container.getElementsByClassName(q)[0]
  carousel = Carousel find('view'), find('scrollable'),
    timeConstant: 200
    allowScroll: true
  find('next').addEventListener 'click', carousel.next
  find('prev').addEventListener 'click', carousel.prev
  carousel

# Initialization logic
window.addEventListener 'DOMContentLoaded', ->
  window.carouselWhole = init document.getElementById 'container-whole'
  window.carouselParts = init document.getElementById 'container-parts'
