/* globals window, jQuery, picturefill */

var ampersandrew = (function(window, $) {
	"use strict";

	var $allAnimatedModules = $(".animated-element"),
		$allReloadModules = $(".reload-src"),
		$doc = $('body'),
		$holder = $(window),
		$holderHeight = $holder.height(),
		mHistory = Modernizr.history,
		isHomePage = $("body").hasClass("home") ? true : false,
		frame,
		sprite = new Image(),

		init = function() {
			console.log("init");
			var el;
			
			if (isHomePage) {
				setTimeout(startHeaderAnimation, 1000);
				loadTwitter();
			}
			
			// Already visible modules
			$allAnimatedModules.each(function (i, element) {
				console.log("allAnimatedModules");
				el = $(element);
				if (el.visible(true)) {
					el.addClass("animate already-animated");
				}
			});
			
			// add min-height for any reloaded img modules
			if ($(".reload-src").length > 0) {
				$(".reload-src").each(function (index) {
					$(this).css("min-height", $(this).height());
				});
			}
			
			$('.screenshot-gallery').bxSlider({
				mode: 'fade',
				auto: false
			});
			
			externalLinks();
			resizeHandler();
			picturefill();

			setTimeout(function() {
				$("body").removeClass("loading");
				setTimeout(function() {
					$("body").addClass("loaded");
				}, 50);
			}, 100);
		},

	//autoload external links in new window
		externalLinks = function() {
			console.log("externalLinks");
			$("a[href^='http:']:not([href*='" + window.location.host + "']), a[rel*='external']").each(function() {
				$(this).attr("target", "_blank");
			});
		},

	// side navigation
		getSideNav = function() {
			$holderHeight = $holder.height(); 
		},

	// popstate listener
		popStateAddListener = function() {
			console.log("popStateAddListener");
			$(window).on("popstate", function(e) {
				console.log("popstate");
				if (e.originalEvent.state === null) return;
				$("body").addClass("loading");
				if (history.state.path) {
					setTimeout(function() {
						clearTimeout(this);
						loadContent(history.state.path, history.state.scrollTop);
					}, 1000);
				} else {
					setTimeout(function() {
						clearTimeout(this);
						var link = location.pathname.replace(/^.*[\\/]/, ""); // get filename only
						loadContent(link, history.state.scrollTop);
					}, 1000);
				}
			});
		},

		stateData = {},
		loadContent = function(href, popScroll, homeReferral) {
			console.log("loadContent");
			$("body").addClass("loading");
			$doc.addClass('hide-top');
			setTimeout(function() {
				clearTimeout(this);

				stateData = {
					path: window.location.href,
	            	scrollTop: $(window).scrollTop(),
	            	isHomeReferral: false
		        };
		        history.replaceState(stateData, null, stateData.path);

		        stateData = {
		        	path: href,
					scrollTop: 0,
					isHomeReferral: homeReferral ? true : false
				};
				history.pushState(stateData, null, stateData.path);

		        $.get(href, function(response, status, xhr) {
		        	$("body").attr("class", /body([^>]*)class=(["']+)([^"']*)(["']+)/gi.exec(response.substring(response.indexOf("<body"), response.indexOf("</body>") + 7))[3]);
				});

				$('#page-holder').load(href + " #page-holder", function(response, status, xhr) {
					if (stateData.isHomeReferral) {
						$('.b-project-collapse, .b-project-close').addClass("homeReferral");
					} else {
						$('.b-project-collapse, .b-project-close').removeClass("homeReferral");
					}
					resetAll(popScroll);
				});
			}, 1000);
		},

	// Project Page
		setProjectTop = function() {
			var winHeightMain = $(window).innerHeight();
			
			if ($("body").hasClass("single")) {
				$(".main").css({"margin-top": winHeightMain + "px","margin-bottom": $(".contact-container").height() + "px"});
				$(".contact-container img").load(function() {
					$(".main").css({"margin-bottom": $(".contact-container").height() + "px"});
				});
			} else {
				$(".main").css({"margin-top": 0});
			}
		},

	// resize window actions
		resizeHandler = function() {
			getSideNav();
			setProjectTop();
		},

	// Twitter
		loadTwitter = function() {
			var twitterConfig = {
				account: '425295523981979648',
				element: 'twitter-feed'
			};
			if (document.getElementById('twitter-feed') !== null) {
				twitterFetcher.fetch(twitterConfig.account, twitterConfig.element, 1, true, false, false, function() { 
					return; 
				}, false);
			}
		},

	// load page and loader animation controls
		startHeaderAnimation = function() {
			if ($(".bg-header-animated").length > 0) {
				var tempSrc = $(".bg-header-animated").attr("src");
				$(".bg-header-animated").attr("src","");
				$(".bg-header-animated").attr("src",tempSrc);
				$(".bg-header-animated").removeClass("reload-src-no-delay");
				startLogoAnimation();
			}
		},

		startLogoAnimation = function() {
			setTimeout(function() {
				animatedLogo();
			}, 300);
		},

		resetAll = function(popScroll) {
			console.log("resetAll");
			$allAnimatedModules = $(".animated-element");
			$allReloadModules = $(".reload-src");
			isHomePage = $("body").hasClass("home") ? true : false;
			init();
			if (popScroll !== 0) {
				$('html, body').animate({scrollTop: popScroll}, 0, "swing");
			} else {
				$('html, body').animate({scrollTop: 0}, 0, "swing");
			}
		},

	// animated logo in canvas
		drawFrame = function(ctx, image, width, height, num) {
			var offsetX = 0,
				offsetY = num * height;
			
			ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
			ctx.drawImage(image, offsetX, offsetY, width, height, 0, 0, width, height);
		},

		rightNow = function() {
			if (window.performance && window.performance.now) {
				return window.performance.now();
			} else {
				return +(new Date());
			}
		},

		animatedLogo = function() {
			console.log("animatedLogo");
			var fps = 30,
				currentFrame = 0,
				totalFrames = 60,
				canvas = document.getElementById("logo-canvas"),
				ctx = canvas.getContext("2d"),
				currentTime = rightNow();

			sprite.src = "/wp-content/themes/ampersandrew-ss-theme/images/l-ampersandrew-inline-animated.png";
			sprite.width = 1273;
			sprite.height = 288;

			(function animloop(time) {
				var delta = (time - currentTime) / 1000;

				currentFrame += (delta * fps);

				var frameNum = Math.floor(currentFrame);

				if (frameNum >= totalFrames) {
					console.log("cancelAnimationFrame");
					window.cancelAnimationFrame(frame);
					return;
				}

				frame = window.requestAnimationFrame(animloop);	
				drawFrame(ctx, sprite, sprite.width, sprite.height, frameNum);	
				currentTime = time;
			})(currentTime);
		};

	return {
		init: init,
		loadContent: loadContent,
		popStateAddListener: popStateAddListener,
		resizeHandler: resizeHandler,
	};

})(window, jQuery);