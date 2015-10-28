define(['chai', 'sinon', 'jquery', 'orbitz', 'AirResultDetailsToggle'], function (chai, sinon, $, o, AirResultDetailsToggle) {
	'use strict';

	var expect = chai.expect,
		$fixture, content, icon, label, module, msg, trigger; 

	describe('AirResultDetailsToggle', function() {

		before(function(){
			$fixture = jQuery('<div class="card"><a href="/details" class="trigger" data-wt-ti="airCard-details" data-toggle-content=".content" data-toggle-parent=".card" data-toggle-label-swap="Hide details" data-toggle-load-url="/details"><i class="i i-plus"></i> <span class="toggle-label">View details</span></a><div class="content"></div>');
			jQuery(document.body).append($fixture);
			
			content = $fixture.find('.content');
			icon = $fixture.find('.i');
			label = $fixture.find('.toggle-label');
			module = new AirResultDetailsToggle($fixture.find('.trigger'));
			module.options = { webtrendsLabel: 'Web Trends Label Text' };
			trigger = $fixture.find('.trigger');
			sinon.spy($, "ajax");
        });

		after(function(){
			$fixture.remove();
			$.ajax.restore();
		});

		it('toggles the content', function(){
			msg = 'The icon should have .i-plus class';
			expect(jQuery(icon).hasClass('i-plus')).to.be.equal(true, msg);

			msg = 'The content should be collapsed';
			expect(jQuery(content).hasClass('is-opening')).not.to.be.equal(true, msg);

			msg = 'The content should be empty';
			expect(jQuery(content).text()).to.be.equal('', msg);

			msg = 'The link text is correct';
			expect(jQuery(label).text()).to.be.equal('View details', msg);
			
			$(trigger).trigger('click');

			msg = 'The content should have .is-open class';
			expect(jQuery(content).hasClass('is-opening')).to.be.equal(true, msg);

			msg = 'The link text should be swapped';
			expect(jQuery(label).text()).to.be.equal('Hide details', msg);

			msg = 'ajax.calledOnce';
			expect($.ajax.calledOnce).to.be.equal(true, msg);

			msg = 'Content should be updated';
			expect(jQuery(content).text()).to.be.equal('new content', msg);

			module.$element.on('webtrends:multiTrackEvent', function(event, options) {
				expect(options['DCSext.fctkw']).to.equal('Web Trends Label Text');
			});

			msg = 'o.initAgents should be envoked';
			expect(o.initAgents.calledOnce).to.be.equal(true, msg);
		});
	});
});
