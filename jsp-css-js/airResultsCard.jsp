<%--
	Attribute list for this module:
		* searchResult (required)   - the flight information object for this result
		* showContinueWithSelectedFlightButton (required)     - boolean
		* isPackage                 - boolean
		* isHotelPackage            - boolean
		* numNights                 - Number
		* hasBonusLoyalty           - boolean
		* enableSelectBySlice       - boolean
--%>

<c:set var="searchResult" value="${renderParam.searchResult}" />
<c:set var="showContinueWithSelectedFlightButton" value="${renderParam.showContinueWithSelectedFlightButton}" />
<c:set var="isPackage" value="${renderParam.isPackage}" />
<c:set var="isHotelPackage" value="${renderParam.isHotelPackage}" />
<c:set var="numNights" value="${renderParam.numNights}" />
<c:set var="hasBonusLoyalty" value="${renderParam.hasBonusLoyalty}" />
<c:set var="isOnexPath" value="${pageParam.node == 'onex535' && featureConfig.air.onexSearchResultsViewZeroEnabled}" />
<c:set var="showSecondaryPrice" value="${search.ar.ex.numberOfTravelers > 1 && isOnexPath}" />

<%-- For APC unlimited mileage MVT --%>
<c:if test="${!empty renderParam.carResult}">
	<c:choose>
		<c:when test="${(renderParam.carResult.carPrice.carRatePeriod.code != 'T') && !(renderParam.carResult.carPrice.freeDistance > -1 && !empty renderParam.carResult.carPrice.rateAfterFreeDistance)}">
			<c:set var="isUnlimitedCarMiles" value="data-unlimited-car-miles='true'" />
		</c:when>
		<c:otherwise>
			<c:set var="isUnlimitedCarMiles" value="data-unlimited-car-miles='false'" />
		</c:otherwise>
	</c:choose>
</c:if>

<util:dataContext name="airResultsCard" var="airResultsCardContext" />
<div class="container-card-full-width airResultsCard ${hasBonusLoyalty ? 'hasBonusLoyalty' : ''}" ${airResultsCardContext} ${isUnlimitedCarMiles}>

	<%-- Display flight summary --%>
	<render:include src="/WEB-INF/module/zero/results/airResultSummary.jsp">
		<render:attribute name="searchResult" value="${searchResult}" />
		<render:attribute name="enableSelectBySlice" value="${renderParam.enableSelectBySlice}" />
	</render:include>

	<c:choose>
		<c:when test="${not empty searchResult.changeSliceUrl}">
			<c:set var="changeDepartureText">
				<format:sysText key="airResultsBundling.changeDeparture" />
			</c:set>
			<url:link url="${searchResult.changeSliceUrl}" label="${changeDepartureText}" agent="air-search-by-slice" classes="changeDeparture" />
		</c:when>
		<c:otherwise>
			<util:dataContext name="airPrice" var="dataContextAttr" />
			<div class="airPrice" ${dataContextAttr}>

				<%-- Contact airlines text hidden by default, shows for small screens only --%>
				<c:if test="${searchResult.contactAirlineToBuy}">
					<div class="contactAirlineToBuyText"><format:sysText key="airResultsCard.buyFromAirlineLink" /></div>
				</c:if>

				<c:set var="airlineHiddenParam">
					<c:forEach items="${renderParam.searchResult.solutionSummary.searchSliceSummary}" var="sliceSummary" varStatus="sliceSummaryStatus">
						<c:forEach items="${sliceSummary.marketingAirlines}" var="marketingAirline" varStatus="marketingAirlineStatus">
							<format:description value="${marketingAirline.carrier}"/>
							<c:if test="${!marketingAirline.railAndFly}">
								<c:forEach items="${marketingAirline.flightNumbers}" var="flightNumber" varStatus="flightNumberStatus">
									${flightNumber}
									<c:if test="${!flightNumberStatus.last}"> / </c:if>
								</c:forEach>
							</c:if>
						</c:forEach>
					</c:forEach>
				</c:set>

				<div class="priceGroup pricing">
					<c:set var="fractionsDisplay" value="${isPackage ? pricingDisplayConfig.displayFractionDigitsInSearchResultsForDp : pricingDisplayConfig.displayFractionDigitsInSearchResultsForAir}" />

					<c:if test="${isPackage}">

						<%-- Pkg icons --%>
						<render:include src="/WEB-INF/module/zero/results/include/pkgIcons.jsp" />

						<%-- Number of nights --%>
						<c:if test="${not empty numNights}">
							<span class="numNights">
								<c:choose>
									<c:when test="${numNights == 1}">
										<format:sysText key="pkgResultsSummary.pkgNightsSingularLabel">
											<format:param>${numNights}</format:param>
										</format:sysText>
									</c:when>
									<c:otherwise>
										<format:sysText key="pkgResultsSummary.pkgNightsLabel">
											<format:param>${numNights}</format:param>
										</format:sysText>
									</c:otherwise>
								</c:choose>
							</span>
						</c:if>

					</c:if>

					<%-- Primary price --%>
					<div class="primaryPrice ${isPackage ? 'pkgPrice' : ''}">

						<c:choose>
							<c:when test="${featureConfig.loyalty.pointsBasedLoyaltyEnabled && searchResult.displayPrimaryPriceInPoints}">
								<c:if test="${not empty renderParam.pointsPerPerson && renderParam.pointsPerPerson > 0}">
								
									<c:if test="${featureConfig.loyalty.showLoyaltyCalculatorOnAirCardsEnabled && !hidePoints && (renderParam.airResult.loyaltyCalculatorInfo.agentSession || featureConfig.loyalty.agentOnlyCalculatorOverrideEnabled)}">
										<c:set var="mcContent">
											<div class="lBox">
												<render:include src="/WEB-INF/module/zero/global/include/lightboxShell_Mosaic.jsp"/>
											</div>
										</c:set>
										<c:set var="calcResult" value="calcResult-${renderParam.searchResult.key}"/>
										<c:set var="mcContent"><c:out value="${mcContent}" escapeXml="true" /></c:set>

										<json:agent var="lb" type="CalculatorInfo">
											"content": {"domNode": "pointsCalculator"},
											"options": {
												"compact": "true",
												"heading": "<json:escape><format:sysText key="loyaltyCalculator.dialog.heading" /></json:escape>",
												"classes": "pointsCalculatorLightbox loyaltyCalculatorMod ${calcResult}",
												"closeLabel": "<format:sysText key="dialog.closeLabel"/>",
												"topBoundaryText": "<format:sysText key="dialog.topBoundaryText"/>",
												"bottomBoundaryText": "<format:sysText key="dialog.bottomBoundaryText"/>",
												"wrapLinkText": "<format:sysText key="dialog.wrapLinkText"/>",
												"calcData": {
													"awards": ${renderParam.searchResult.loyaltyCalculatorInfo},
													"itemsToReview": [ {
														"adultsTotalPricePerPerson": { "amount":${renderParam.pointsPerPerson} },
														"totalTaxAndFee": { "amount": ${renderParam.searchResult.taxes} },
														"totalPriceWithTax": { "amount": ${renderParam.searchResult.primaryPriceInPoints} },
														"numberOfTravelers": ${renderParam.searchResult.numberOfTickets}
													} ],
													"profile": { "points": "19,937,782" },
													"browser": { "popup": ${true} }
												}
											}
										</json:agent>

										<div class="calculate-point-options"
											data-agent="LightBoxAgent"
											data-LightBoxAgent-content="${mcContent}"
											data-LightBoxAgent-triggerselector=".${calcResult}"
											data-LightBoxAgent-contentselector=".${calcResult}-content"
											data-LightBoxAgent-classname="lightboxGallery"
											data-LightBoxAgent-wrapperclasses="" >

											<c:set var="linkText">
												<format:sysText key="loyaltyCalculator.dialog.linkText" />
											</c:set>

											<a class="font-size-xs ${calcResult}">
												<i class="icon-calculator"></i> ${linkText}
											</a>
											<div class="pointsCalculatorLightbox loyaltyCalculatorMod ${calcResult}-content noneBlock" data-agent="${lb}">
												<span class="msg-page-alert">
													<span><format:sysText key="loyaltyCalculator.dialog.persistenceWarningMessage" /></span>
												</span>
												<render:include src="/WEB-INF/module/zero/loyalty/loyaltyCalculator.jsp">
													<render:attribute name="retrieveParams" value="${true}" />
												</render:include>
											</div>
						
										</div>	
									</c:if>				

									<div class="points">
										<format:number value="${renderParam.pointsPerPerson}" groupingUsed="true" maxFractionDigits="0"/>
									</div>
									<div class="pointsMetric">
										<format:sysText key="airResultsCard.pointsOrText"/>
									</div>
								</c:if>
								<div class="price">
									<format:money value="${searchResult.primaryPrice}" fractionDigitsDisplayed="${fractionsDisplay}" />
								</div>
								<div class="priceMetric">
									<format:sysText key="airResultsCard.dualPricingPerPersonText"/>
								</div>
								<c:if test="${searchResult.numberOfTickets > 1}">
									<p class="priceMetric">
										<format:sysText key="pkgResultsCard.totalNoPriceText" var="totalPrice">
											<format:param><format:money value="${searchResult.sellRate}" /></format:param>
										</format:sysText>
										(${totalPrice})
									</p>
								</c:if>
							</c:when>
							<c:otherwise>
								<div class="price">
									<format:money value="${searchResult.primaryPrice}" fractionDigitsDisplayed="${fractionsDisplay}" classes="small-cents small-symbol" />
								</div>
								<div class="priceMetric">
									<c:choose>
										<c:when test="${isPackage}">
											<format:sysText key="airResultsCard.dualPricingPerPersonText"/>
											<c:if test="${searchResult.numberOfTickets > 1 && featureConfig.loyalty.loyaltyPartnerCssEnabled}">
												<p class="priceMetric">
													<format:sysText key="pkgResultsCard.totalNoPriceText" var="totalPrice">
														<format:param><format:money value="${searchResult.sellRate}" /></format:param>
													</format:sysText>
													(${totalPrice})
												</p>
											</c:if>
										</c:when>
										<c:otherwise>
											${searchResult.primaryPriceSubText}
										</c:otherwise>
									</c:choose>
								</div>
							</c:otherwise>
						</c:choose>
					</div>
					<c:if test="${isOnexPath}">
						<div class="font-size-xs fg-neutral-dark changeCost">
							<format:sysText key="airResultsCard.totalChangeCostOneTicketText" />
						</div>
					</c:if>
					<c:if test= "${showSecondaryPrice}">
						<div class="priceMetric totalChangeCost">
							<format:money value="${searchResult.secondaryPrice}" fractionDigitsDisplayed="${fractionsDisplay}" />
							<format:sysText key="airResultsCard.totalChangeCostPerPersonText" />
						</div>
					</c:if>

					<%-- Discount Messaging --%>
					<c:if test="${searchResult.showPaymentDiscount}">
						<c:set var="mcContent">
							<div class="showPaymentDiscount">
								<render:include src="/WEB-INF/module/zero/global/include/lightboxShell.jsp"/>
							</div>
						</c:set>
						<c:set var="mcContent"><c:out value="${mcContent}" escapeXml="true" /></c:set>
						<div class="discountPricing ${search.ar.slice != null ? 'searchBySliceActive' : ''}" data-agent="ResponsiveMicrocontent"
							data-ResponsiveMicrocontent-content="${mcContent}"
							data-ResponsiveMicrocontent-triggerselector=".microTrigger"
							data-ResponsiveMicrocontent-contentselector=".microContent" >
							<span class="microTrigger showPaymentDiscountTrigger">
								<format:money value="${searchResult.paymentDiscountInfo.paymentDiscountDisplayAmount}" fractionDigitsDisplayed="${fractionsDisplay}" classes="${moneyClass}" />
								<format:sysText key="paymentTypeDiscount.withoutPaymentDiscountLowercase" />
							</span>
							<div class="microContent showPaymentDiscountContent noneBlock">
								<div class="paymentDiscountHeader">
									<format:sysText key="paymentTypeDiscount.paymentDiscountCapitalized" />
								</div>
								<div class="paymentDiscount">
									<p>
										<format:sysText key="paymentTypeDiscount.discountPerBookingColon" />
									</p>
									<ul class="list-bulleted">
										<c:forEach items="${searchResult.paymentDiscountInfo.discountedPaymentTypes}" var="paymentTypeDiscount">
											<li>
												<format:sysText key="paymentTypeDiscount.paymentDiscountMessage">
													<format:param><format:money value="${paymentTypeDiscount.value}" fractionDigitsDisplayed="${fractionsDisplay}" /></format:param>
													<format:param><format:description value="${paymentTypeDiscount.key}"/></format:param>
												</format:sysText>
											</li>
										</c:forEach>
									</ul>
									<p>
										<format:sysText key="paymentTypeDiscount.noDiscountColon" />
									</p>
									<ul class="list-bulleted">
										<c:forEach items="${searchResult.paymentDiscountInfo.nonDiscountedPaymentTypes}" var="paymentType">
											<li><format:description value="${paymentType}"/></li>
										</c:forEach>
									</ul>
								</div>
							</div>
						</div>
					</c:if>

					<%-- Low Seat Availability --%>
					<c:if test="${searchResult.solutionSummary.lsaAlertEnabled}">
						<render:include src="/WEB-INF/module/zero/results/airResults-lsaAlert.jsp" >
							<render:attribute name="seatCount" value="${searchResult.solutionSummary.lowestSeatCount}" />
						</render:include>
					</c:if>

					<%-- Free Cancel message --%>
					<c:if test="${!featureConfig.air.displayCancellationMessageOnAgreeAndBookPageEnabled && searchResult.displayFree24hrCancellationMessage && search.ar.type.code != 'exchange'}">
						<render:include src="/WEB-INF/module/zero/results/airResults-freeCancel.jsp" />
					</c:if>

					<%-- Loyalty Earn --%>
					<c:if test="${not empty searchResult.aggregateLoyaltyEarnAmount}">
						<util:dataContext name="loyaltyEarnAmount" var="dataContextAttr" />
						<div class="loyaltyEarnAmount" ${dataContextAttr}>
							<i class="i i-loyalty"></i> <format:sysText key="rewardsProgram.earn">
								<format:param>
									<format:money value="${searchResult.aggregateLoyaltyEarnAmount}" />
								</format:param>
							</format:sysText>
							<c:if test="${hasBonusLoyalty}">
								<p class="bonusLoyalty">
									(<format:sysText key="rewardsProgram.bonusWithProgram" />)
								</p>
							</c:if>
						</div>
					</c:if>

					<%-- Baggage Fees icon only, link displayed in catch-all --%>
					<c:if test="${not empty searchResult.solutionSummary.fareMessageArticleId}">
						<i class="i i-baggage-x"></i>
					</c:if>

				</div>

				<c:if test="${empty renderParam.showContinueWithSelectedFlightButton || !renderParam.showContinueWithSelectedFlightButton}">
					<div class="priceGroup airCard-button">
						<%-- Select Button --%>
						<c:choose>
							<c:when test="${isHotelPackage}">
								<url:link classes="buttons-primary buttons-compact" useQueryString="true" agent="agent-Interstitial" dataContext="selectButton">
									<url:linkBody>
										<format:sysText key="airResultsCard.selectLink.label" />
										<%-- a11y text: airlines + flight numbers + total price --%>
										<span class="offscreen">
											${airlineHiddenParam}
											<format:money value="${searchResult.primaryPrice}" fractionDigitsDisplayed="${fractionsDisplay}" />
										</span>
									</url:linkBody>
									<url:linkAddParam name="selectKey" value="${searchResult.key}" />
									<url:linkAddParam name="userRate.price" value="${searchResult.userDisplayedRate.price}" />
								</url:link>
							</c:when>
							<c:when test="${searchResult.contactAirlineToBuy}">
								<%-- Contact airlines link --%>
								<div class="buyFromAirline text-left">
									<format:sysText key="airResultsCard.buyFromAirlineLink.ada">
										<format:param>
											<span class="offscreen">
												${airlineHiddenParam}
											</span>
										</format:param>
									</format:sysText>
								</div>
							</c:when>
							<c:otherwise>
								<c:set var="agent" value="${search.ar.slice == 0 ? 'air-search-by-slice' : 'agent-Interstitial'}" />
								<c:set var="dataWtTi" value="airCard-select" />
								<%-- BEGIN GOF-1013 MVT --%>
								<c:if test="${renderParam.eventKeepFlightChangeCar}">
									<c:set var="eventId" value="&_eventId=changeCar" />
									<c:set var="dataWtTi" value="airCard-changeCar" />
								</c:if>
								<%-- END GOF-1013 MVT --%>
								<a class="buttons-primary buttons-compact ${search.ar.slice != null ? 'select-slice' : ''}" href="${searchResult.selectUrl}${eventId}" data-context="selectButton" data-wt-ti="${dataWtTi}" data-agent="${agent}">
									<format:sysText key="airResultsCard.selectLink.label" />
									<%-- a11y text: airlines + flight numbers + total price --%>
									<span class="offscreen">
										${airlineHiddenParam}
										<format:money value="${searchResult.primaryPrice}" fractionDigitsDisplayed="${fractionsDisplay}" />
									</span>
								</a>
							</c:otherwise>
						</c:choose>
					</div>
				</c:if>

			</div>
		</c:otherwise>
	</c:choose>

	<%-- View details link --%>
	<render:include src="/WEB-INF/module/zero/itinerary/include/airResultDetailsToggle.jsp">
		<render:attribute name="price" value="${searchResult.userDisplayedRate.price}" />
		<render:attribute name="key" value="${searchResult.key}" />
		<c:choose>
			<c:when test="${search.type == 'air'}">
				<render:attribute name="showFlightDetails" value="ar.showFlightDetails" />
			</c:when>
			<c:when test="${search.type == 'aph'}">
				<render:attribute name="showFlightDetails" value="aph.showFlightDetails" />
			</c:when>
			<c:when test="${search.type == 'ahc'}">
				<render:attribute name="showFlightDetails" value="ahc.showFlightDetails" />
			</c:when>
			<c:when test="${search.type == 'apc'}">
				<render:attribute name="showFlightDetails" value="apc.showFlightDetails" />
			</c:when>
		</c:choose>
		<render:attribute name="solutionSummary" value="${searchResult.solutionSummary}" />
	</render:include>

	<%-- Display flight details, empty by default --%>
	<div class="airDetails"></div>

	<%-- Selected flight --%>
	<c:if test="${showContinueWithSelectedFlightButton}">
		<div class="continue-selected-button col-float-right">
			<url:link classes="buttons-primary buttons-compact" url="${flowExecutionUrl}" dataContext="keepCurrentFlightButton" agent="agent-Interstitial">
				<url:linkBody>
					<format:sysText key="changeAirResultsCardPrice.continueButton.label" />
				</url:linkBody>
				<url:linkAddParam name="_eventId" value="keepCurrentFlight" />
			</url:link>
		</div>
	</c:if>
</div>
