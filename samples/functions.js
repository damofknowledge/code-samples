/* globals window, jQuery, ampersandrew */
(function(window, $, a, undefined){
	"use strict";

	$(document).ready(function(){

		var $allAnimatedModules = $(".animated-element"),
			$allReloadModules = $(".reload-src"),
			$doc = $('body'),
			$holder = $(window),
			$holderHeight = $holder.height(),
			scroll_timer,
			isScrolling = false,
			mHistory = Modernizr.history;
		
	// bind interactions, react to scroll event on window, hide/reveal side nav
		$holder.scroll(function() {
			clearTimeout(scroll_timer);
			scroll_timer = setTimeout(function() { // use a timer for performance
				var el;
				if ($holder.scrollTop() >= $holderHeight) {
					$doc.removeClass('hide-top');
				} else {
					$doc.addClass('hide-top');
				}

				$allAnimatedModules.each(function(i, element) {
					el = $(element);
					if (el.visible(true)) {
						el.addClass("animate");
						$allAnimatedModules = $(".animated-element:not(.animate)");
					}
				});

				$allReloadModules.each(function(i, element) {
					el = $(element);
					if (el.visible(true) && el.hasClass("reload-src")) {
						setTimeout(function() {
							clearTimeout(this);
							var tempSrc = el.attr("src");
							el.attr("src","");
							el.attr("src",tempSrc);
							el.removeClass("reload-src");
							$allReloadModules = $(".reload-src");
						}, 250);
					}
				});

				// set Hero
				if ($holder.scrollTop() > $holderHeight) {
					if (!$("body").hasClass("hide-hero")) {
						$("body").addClass("hide-hero");
					}
				} else {
					if ($("body").hasClass("hide-hero")) {
						$("body").removeClass("hide-hero");
					}
				}
			}, 10);
		});

		$('.contact-container a:eq(0)').on('focus', function() {
			$('html, body').animate({scrollTop: document.body.scrollHeight}, 500, "swing");
		});
		
		$('body').on('click touchend', '.b-top-project', function(event) {
			event.preventDefault();
			$('html, body').animate({scrollTop: 0}, 1000, "swing");
			$('.main').focus();
			return false;
		});

		$('body').on('click touchend', '.b-replay-stack', function(event) {
			event.preventDefault();
			$('img.stack').removeClass("animate");
			setTimeout(function() {
				clearTimeout(this);
				$('img.stack').addClass("animate");
			}, 500);

			return false;
		});

		$('body').on('click touchend', '.b-skip', function(event) {
			event.preventDefault();
			var targetTop = $($(this).attr('href')).offset().top;
			$('html, body').animate({scrollTop: targetTop}, 500, "swing");
			return false;
		});

		$('body').on("touchstart", '.banner', function(event) {
		});

		$('body').on("touchmove", '.banner', function(event) {
			isScrolling = true;	
		});

		$('body').on('click touchend', '.banner', function(event) {
			if (!isScrolling) {
				if (mHistory) {
					event.preventDefault();
					var _href = ""+$(this).attr('href');
					a.loadContent(_href, 0, true);
					return false;
				}
			}
			isScrolling = false;
		});

		$('body').on('click touchend', '.b-next, .b-previous', function(event) {
			if (mHistory) {
				event.preventDefault();
				var _href = ""+$(this).attr('href');
				a.loadContent(_href, 0);
				return false;
			}
		});

		$('body').on('click touchend', '.b-related-project', function(event) {
			if (mHistory) {
				event.preventDefault();
				var _href = ""+$(this).attr('href');
				a.loadContent(_href, 0);
				return false;
			}
		});

		$('body').on('click touchend', '.b-project-collapse, .b-project-close', function(event) {
			if (mHistory) {
				event.preventDefault();
				if (!$(this).hasClass("homeReferral")) {
					var _href = ""+$(this).attr('href');
					a.loadContent(_href, 0);
				} else {
					$("body").addClass("loading");
					setTimeout(function() {
						clearTimeout(this);
						history.go(-1);
					}, 1000);
				}
				return false;
			}
		});

	// resize window actions
		$(window).on("resize", function() {
			var windowResizeThrottle = setTimeout(a.resizeHandler, 150);
			clearTimeout(windowResizeThrottle);
		});
		
	// load page
		var loadPageThrottle = setTimeout(function() {
				clearTimeout(loadPageThrottle);
				a.init();
			}, 1000);

		if (mHistory) {
			a.popStateAddListener();
		}

	});
})(window, jQuery, ampersandrew);

