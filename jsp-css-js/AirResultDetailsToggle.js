/*
 * AirResultDetailsToggle
 *
 * HideReveal-type functionality using AJAX to bring in details for Air Results Card
 *
 * Joel Sunman - 2015-03-20
 *
 */

define (['jquery', 'orbitz', 'ProgressIndicator'], function($, o, ProgressIndicator) {

	var AirResultDetailsToggle = function (element, options) {
		this.$element = element;
		this.options = options;

		var content = this.$element.data('toggle-content'),
			parent = this.$element.data('toggle-parent');
		
		this.toggleLabel = this.$element.find('.toggle-label').html();
		this.toggleLabelSwap = this.$element.data('toggle-label-swap') ? this.$element.data('toggle-label-swap') : this.toggleLabel;
		this.toggleLoadUrl = this.$element.data('toggle-load-url');
		this.toggleLoadSelector = this.$element.data('toggle-load-selector');

		this.$content = this.$element.closest(parent).find(content);
		this.$icon = this.$element.find('.i');
		this.$toggleLabel = this.$element.find('.toggle-label');

		this.$element.on('click', this.handleTriggerClicked.bind(this));
		this.$content.on('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', this.handleTransitionEnd.bind(this));
	};

	AirResultDetailsToggle.prototype = {

		handleTriggerClicked: function(event) {
			event.preventDefault();
			this.$content.removeClass('is-open transition-end');

			this.$content.toggleClass('is-opening');
			this.$icon.toggleClass('i-plus i-minus');

			// Swap the label
			if ((this.$content).hasClass('is-opening')) {
				this.$toggleLabel.html(this.toggleLabelSwap);
				this.loadDetails();
			} else {
				this.$toggleLabel.html(this.toggleLabel);
				this.hideIntrastitial();
			}
			
			// Webtrends
			if (this.options.webtrendsLabel) {
				this.$element.trigger('webtrends:multiTrackEvent', {
					'DCSext.fctkw': this.options.webtrendsLabel
				});
			}
		},

		handleTransitionEnd: function(event) {
			if ((this.$content).hasClass('is-open')) {
				this.$content.addClass('transition-end');
			}
		},

		loadDetails: function() {
			this.showIntrastitial();
				
			if (this.request) {
				this.request.abort();
			}

			this.request = $.ajax({
				url: this.toggleLoadUrl,
				context: this
			})
			.done(function(response){
				this.request = null;
				this.updateDetails(response);
			})
			.fail(function(){
				this.request = null;
				this.$content.removeClass('is-open');
				this.$content.toggleClass('is-opening');
				this.$icon.toggleClass('i-plus i-minus');
				this.$toggleLabel.html(this.toggleLabel);
				// Unbind and do default action, go to URL
				this.$element.off('click');
				this.$element.get(0).click();
			});
		},
		
		showIntrastitial: function() {
			if (!this.pi) {
				this.pi = new ProgressIndicator();
				this.$element.after(this.pi.$spinnerElement);
			}
			this.pi.start();
		},
		
		hideIntrastitial: function() {
			if (this.pi) {
				this.pi.stop();
			}
		},

		updateDetails: function(response) {
			if (this.toggleLoadSelector && $("<div />").html(response).find(this.toggleLoadSelector).length > 0) {
				// Content was found and it is not empty
				this.$content.html($(response).filter(this.toggleLoadSelector));
				o.initAgents(this.$content);
				this.hideIntrastitial();
				this.$content.toggleClass('is-open');
			} else {
				// Content was not found as expected
				this.$content.removeClass('is-open');
				this.$content.toggleClass('is-opening');
				this.$icon.toggleClass('i-plus i-minus');
				this.$toggleLabel.html(this.toggleLabel);
				// Unbind and do default action, go to URL
				this.$element.off('click');
				this.$element.get(0).click();
			}
		}
	};

	return AirResultDetailsToggle;
});