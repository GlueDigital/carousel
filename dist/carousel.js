(function() {
  var carousel;

  module.exports = carousel = function(box, slider, opts) {
    var alsoScroll, amplitude, auto, autoScroll, boxWidth, cancelClick, currSlide, dots, drag, frame, initialize, max, min, mustCancel, offset, overlay, pressed, reference, release, ret, scroll, snap, startOffset, tap, target, tearDown, ticker, timeConstant, timestamp, track, updateDots, velocity, xform, xpos, xstart, ypos, ystart;
    if (opts == null) {
      opts = {};
    }
    opts.amplitudeCoef = opts.amplitudeCoef || 0.8;
    opts.timeConstant = opts.timeConstant || 325;
    opts.allowScroll = opts.allowScroll || false;
    opts.withDots = opts.withDots || true;
    opts.dotsParent = opts.dotsParent || null;
    opts.useTranslate3d = opts.useTranslate3d || true;
    opts.snapParts = opts.snapParts || true;
    opts.slidePerTouch = opts.slidePerTouch || false;
    min = max = offset = reference = pressed = xform = velocity = frame = snap = timestamp = ticker = amplitude = target = timeConstant = overlay = auto = alsoScroll = xstart = ystart = startOffset = currSlide = dots = mustCancel = boxWidth = null;
    xpos = function(e) {
      var ref;
      if (((ref = e.targetTouches) != null ? ref.length : void 0) >= 1) {
        return e.targetTouches[0].clientX;
      }
      return e.clientX;
    };
    ypos = function(e) {
      var ref;
      if (((ref = e.targetTouches) != null ? ref.length : void 0) >= 1) {
        return e.targetTouches[0].clientY;
      }
      return e.clientY;
    };
    updateDots = function() {
      if (dots) {
        return Array.prototype.map.call(dots.childNodes, function(dot, i) {
          return dot.classList.toggle('active', i === currSlide);
        });
      }
    };
    scroll = function(x) {
      var t;
      if (x > max) {
        offset = max;
      } else if (x < min) {
        offset = min;
      } else {
        offset = x;
      }
      if (opts.useTranslate3d) {
        slider.style[xform] = 'translate3d(' + (-offset) + 'px, 0, 0)';
      } else {
        slider.style[xform] = 'translateX(' + (-offset) + 'px)';
      }
      t = Math.round(offset / snap);
      if (t !== currSlide) {
        currSlide = t;
        return updateDots();
      }
    };
    track = function() {
      var delta, elapsed, now, v;
      now = Date.now();
      elapsed = now - timestamp;
      timestamp = now;
      delta = offset - frame;
      frame = offset;
      v = 1000 * delta / (1 + elapsed);
      return velocity = 0.8 * v + 0.2 * velocity;
    };
    autoScroll = function() {
      var delta, elapsed;
      if (amplitude) {
        elapsed = Date.now() - timestamp;
        delta = -amplitude * Math.exp(-elapsed / timeConstant);
        if (delta > 0.5 || delta < -0.5) {
          scroll(target + delta);
          return window.requestAnimationFrame(autoScroll);
        } else {
          return scroll(target);
        }
      }
    };
    tap = function(e) {
      pressed = true;
      xstart = reference = xpos(e);
      ystart = ypos(e);
      alsoScroll = false;
      startOffset = offset;
      velocity = amplitude = 0;
      frame = offset;
      timestamp = Date.now();
      window.clearInterval(ticker);
      ticker = window.setInterval(track, 100);
      return mustCancel = false;
    };
    drag = function(e) {
      var delta, totalX, totalY, x, y;
      if (pressed) {
        x = xpos(e);
        y = ypos(e);
        delta = reference - x;
        totalY = Math.abs(ystart - y);
        totalX = Math.abs(xstart - x);
        if (totalX > 30 || totalY > 30) {
          mustCancel = true;
        }
        if (opts.allowScroll) {
          if (totalY > totalX && totalY > 30) {
            alsoScroll = true;
          }
        }
        if (delta > 2 || delta < -2) {
          reference = x;
          scroll(offset + delta);
        }
      }
      if (!alsoScroll) {
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
    };
    release = function() {
      pressed = false;
      window.clearInterval(ticker);
      target = offset;
      if (velocity > 10 || velocity < -10) {
        amplitude = opts.amplitudeCoef * velocity;
        target = offset + amplitude;
      }
      if (opts.slidePerTouch) {
        if (offset - startOffset > 0) {
          target = startOffset + snap;
        } else {
          target = startOffset - snap;
        }
      }
      target = Math.round(target / snap) * snap;
      amplitude = target - offset;
      timestamp = Date.now();
      return window.requestAnimationFrame(autoScroll);
    };
    cancelClick = function(e) {
      if (mustCancel) {
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
    };
    initialize = function() {
      var c, candidate, count, dot, j, ref, sliderWidth;
      if (typeof window.ontouchstart !== 'undefined') {
        slider.addEventListener('touchstart', tap);
        slider.addEventListener('touchmove', drag);
        slider.addEventListener('touchend', release);
      }
      slider.addEventListener('mousedown', tap);
      slider.addEventListener('mousemove', drag);
      slider.addEventListener('mouseup', release);
      slider.addEventListener('click', cancelClick, true);
      boxWidth = parseInt(window.getComputedStyle(box).width, 10);
      sliderWidth = slider.scrollWidth;
      max = sliderWidth - boxWidth;
      if (max < 0) {
        max = 0;
      }
      offset = min = 0;
      pressed = false;
      timeConstant = opts.timeConstant;
      currSlide = 0;
      snap = boxWidth;
      if (opts.snapParts) {
        c = slider.firstChild;
        while (c) {
          if (c.nodeType !== 3) {
            candidate = parseInt(window.getComputedStyle(c).width, 10);
            if (candidate > 20 && candidate < snap) {
              snap = candidate;
              break;
            }
          }
          c = c.nextSibling;
        }
      }
      xform = 'transform';
      ['webkit', 'Moz', 'O', 'ms'].every(function(prefix) {
        var e;
        e = prefix + 'Transform';
        if ('undefined' !== typeof slider.style[e]) {
          xform = e;
          return false;
        }
        return true;
      });
      if (opts.withDots) {
        dots = document.createElement('div');
        dots.classList.add('dots');
        count = max / snap;
        for (j = 0, ref = count; 0 <= ref ? j <= ref : j >= ref; 0 <= ref ? j++ : j--) {
          dot = document.createElement('div');
          dot.classList.add('dot');
          dots.appendChild(dot);
        }
        updateDots();
        if (opts.dotsParent) {
          return opts.dotsParent.appendChild(dots);
        } else {
          return box.appendChild(dots);
        }
      }
    };
    tearDown = function() {
      slider.removeEventListener('touchstart', tap);
      slider.removeEventListener('touchmove', drag);
      slider.removeEventListener('touchend', release);
      slider.removeEventListener('mousedown', tap);
      slider.removeEventListener('mousemove', drag);
      slider.removeEventListener('mouseup', release);
      slider.removeEventListener('click', cancelClick, true);
      if (dots) {
        dots.parentNode.removeChild(dots);
      }
      return scroll(0);
    };
    ret = {
      getCurrentSlide: function() {
        return currSlide;
      },
      getSlideCount: function() {
        return max / snap;
      },
      move: function(slides) {
        var lastSlide;
        lastSlide = ret.getSlideCount();
        if (currSlide + slides > lastSlide) {
          slides = lastSlide - currSlide;
        }
        if (currSlide + slides < 0) {
          slides = -currSlide;
        }
        window.clearInterval(ticker);
        target = offset;
        target = (Math.round(target / snap) + slides) * snap;
        amplitude = target - offset;
        timestamp = Date.now();
        window.requestAnimationFrame(autoScroll);
        return currSlide + slides;
      },
      next: function() {
        return ret.move(1);
      },
      prev: function() {
        return ret.move(-1);
      },
      nextCyclic: function() {
        if (ret.getCurrentSlide() === ret.getSlideCount()) {
          return ret.move(-ret.getCurrentSlide());
        } else {
          return ret.move(1);
        }
      },
      prevCyclic: function() {
        if (ret.getCurrentSlide === 0) {
          return ret.move(ret.getSlideCount());
        } else {
          return ret.move(-1);
        }
      },
      auto: {
        start: function(interval) {
          var f;
          if (interval == null) {
            interval = 3000;
          }
          f = function() {
            if (!pressed) {
              return ret.nextCyclic();
            }
          };
          return auto = window.setInterval(f, interval);
        },
        stop: function() {
          if (auto) {
            window.clearInterval(auto);
          }
          return auto = null;
        }
      },
      reset: function() {
        tearDown();
        return initialize();
      }
    };
    initialize();
    return ret;
  };

}).call(this);
