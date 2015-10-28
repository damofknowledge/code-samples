<c:choose> <%-- set the display type for cities, Chicago, IL, or Chicago, Illinois. --%>
	<c:when test="${featureConfig.air.displayStateAbbreviationEnabled}">
		<c:set var="cityNameStyle">city-stateProvinceCode</c:set>
	</c:when>
	<c:otherwise>
		<c:set var="cityNameStyle">city-stateProvince</c:set>
	</c:otherwise>
</c:choose>

<div class="airSliceDetails">
	<c:set var="labelMarkup">
		<c:choose>
			<c:when test="${renderParam.isMultiCityResult || search.ar.type.code == 'multiCity' || renderParam.isExchange}">
				<format:sysText key="airItinerary.flightLabel">
					<format:param value="${renderParam.sliceSummaryStatus.count}" />
				</format:sysText>:
			</c:when>
			<c:when test="${renderParam.sliceSummaryStatus.first}">
				<format:sysText key="airItinerary.leaveLabel" />:
			</c:when>
			<c:otherwise>
				<format:sysText key="airItinerary.returnLabel" />:
			</c:otherwise>
		</c:choose>
	</c:set>

	<c:set var="legDate" value="" />

	<c:forEach items="${renderParam.model.segmentDetails}" var="segment" varStatus="segmentCounter">

		<c:forEach items="${segment.legs}" var="leg" varStatus="legCounter">
			
			<c:set var="legClass" value="" />
			<c:choose>
				<c:when test="${(segmentCounter.first && legCounter.first) && (segmentCounter.last && legCounter.last)}">
					<c:set var="legClass" value="soloLeg" />
				</c:when>
				<c:when test="${segmentCounter.first && legCounter.first}">
					<c:set var="legClass" value="firstLeg" />
				</c:when>
				<c:when test="${segmentCounter.last && legCounter.last}">
					<c:set var="legClass" value="lastLeg" />
				</c:when>
			</c:choose>

			<util:dataContext name="airLeg" var="dataContextAttr" />
			<div class="leg ${legClass} timeline-container" ${dataContextAttr}>
				<%-- Departure --%>
				<div class="timeline-group">
					<div class="timeline-item timeline-date timeline-label">
						<strong>
							${labelMarkup}
							
							<c:set var="legDepartFormatted">
								<format:dateTime value="${leg.depart}" style="abbr-full-date-noyear" />
							</c:set>
							<c:if test="${legDate != legDepartFormatted}">
								<util:dataContext name="flightDepartureDate" var="dataContextAttr" />
								<span class="date" ${dataContextAttr}>${legDepartFormatted}</span>
								<c:set var="legDate">
									${legDepartFormatted}
								</c:set>
							</c:if>
						</strong>
						<%-- clear labelMarkup, only displayed once per .airSliceDetails --%>
						<c:set var="labelMarkup" value="" />
					</div>

					<div class="timeline-item timeline-time timeline-label">
						<c:if test="${leg.displayDepartTime}">
							<util:dataContext name="flightDepartureTime" var="dataContextAttr" />
							<strong class="time" ${dataContextAttr}>
								<format:dateTime value="${leg.depart}" style="short-time" />
							</strong>
						</c:if>
						<div class="timeline-marker"></div>
					</div>

					<div class="timeline-item timeline-info">

						<util:dataContext name="departureCity" var="dataContextAttr" />
						<strong class="city timeline-label" ${dataContextAttr}>
							<format:sysText key="airItinerary.departLabel" />:
							<c:choose>
								<c:when test="${leg.railOrigin && not empty leg.operatingCarrier}">
									<format:description value="${leg.operatingCarrier}" />
								</c:when>
								<c:when test="${renderParam.airResult.solutionSummary.international}">
									<formatx:location value="${leg.origin}" style="${cityNameStyle}" />, <formatx:location value="${leg.origin}" style="country" />
								</c:when>
								<c:otherwise>
									<formatx:location value="${leg.origin}" style="${cityNameStyle}" />
								</c:otherwise>
							</c:choose>
						</strong>

						<%-- Display the "Seat map" link if the model supports it, and if the link is appropriate for this view --%>
						<c:if test="${leg.displayViewSeatsLink}">
							<url:link useQueryString="true" dataContext="viewSeatsLink" rel="lightbox" classes="view-seats">
								<c:if test="${not empty renderParam.viewSeatsEventId}" >
									<url:linkAddParam name="_eventId" value="${renderParam.viewSeatsEventId}" />
								</c:if>
								<c:choose>
									<c:when test="${search.type == 'air'}">
										<url:linkAddParam name="ar.showFlightSeatMaps" value="true" />
									</c:when>
									<c:otherwise>
										<url:linkAddParam name="${search.type}.showFlightSeatMaps" value="true" />
									</c:otherwise>
								</c:choose>
								<url:linkAddParam name="tab" value="${leg.flightSeatMapNumber}" />
								<url:linkRemoveParam name="rKy" />
								<url:linkRemoveParam name="rCt" />
								<url:linkBody>
									<i class="i i-seat"></i>
									<format:sysText key="seatMaps.viewSeats" />
								</url:linkBody>
							</url:link>
						</c:if>
													
						<ul class="airport list-piped">
							<c:set var="airportCodeLegOrigin" value="${renderParam.model.originOpenJaw && segmentCounter.first ? 'airportCodeDiffer' : '' }" />
							<li class="airportCode ${airportCodeLegOrigin}">
								<formatx:location value="${leg.origin}" style="name" />
								<formatx:location value="${leg.origin}" style="code-abbr-parensTextOnly" />
							</li>
							<c:if test="${!empty leg.originTerminal}">
								<li class="terminal ${airportCodeLegOrigin}"><format:sysText key="airItinerary.terminalLabel" /> ${leg.originTerminal}</li>
							</c:if>
						</ul>
	
						<util:dataContext name="detailsFlightInfo" var="dataContextAttr" />
						<div class="timeline-flightInfo" ${dataContextAttr}>

							<ul class="list-piped">
								<li class="carrier">
									<strong>
										<format:description value="${leg.carrier}" />
										<c:if test="${!leg.railOrigin && !leg.railDestination && leg.displayMarketingFlightNumber}">
											${leg.flightNumber}
										</c:if>
									</strong>
								</li>
								<c:if test="${leg.displayFlightDistance}">
									<li class="distance">
										<format:distance value="${leg.flightDistance}" style="short" minFractionDigits="0" maxFractionDigits="0" />
									</li>
								</c:if>
								<c:if test="${leg.displayTravelTime}">
									<li class="travelTime"><format:period value="${leg.flightTime}" style="short-hr-min" /></li>
								</c:if>
							</ul>

							<c:if test="${leg.codeShare || leg.railAndFly}">
								<c:if test="${not empty leg.operatingCarrier || not empty leg.operationalDisclosure}">
									<p class="codeShare">
										<format:sysText key="airItinerary.operatedByText">
											<c:choose>
												<c:when test="${not empty leg.operationalDisclosure}">
													<format:param value="${leg.operationalDisclosure}"/>
												</c:when>
												<c:otherwise>
													<format:param><format:description value="${leg.operatingCarrier}"/></format:param>
												</c:otherwise>
											</c:choose>
										</format:sysText>
									</p>
								</c:if>
							</c:if>

							<ul class="list-piped">
								<c:if test="${not empty leg.aircraft.shortName}">
									<li class="aircraft">
										${leg.aircraft.shortName}
									</li>
								</c:if>
								
								<%-- onTimePerformance possible values are -1 ("not initialized") and 0 through 1.0 (0% through 100%) --%>
								<c:if test="${leg.onTimePerformance != -1}">
									<li class="onTime">
										<format:sysText key="flightStatus.onTimeCode.O" />:
										<format:number value="${leg.onTimePerformance}" type="percent" />
									</li>
								</c:if>
							
								<c:if test="${not empty segment.cabin}">
									<li class="cabin">
										<format:description value="${segment.cabin}" />
										<c:if test="${segment.displayMarketingCabin}">-</c:if>
										<render:include src="/WEB-INF/module/zero/itinerary/include/marketingCabin.jsp">
											<render:attribute name="segment" value="${segment}" />
										</render:include>
									</li>
								</c:if>
							</ul>

							<c:if test="${not empty leg.mealServiceType}">
								<p class="meals">
									<c:forEach items="${leg.mealServiceType}" var="meal" varStatus="mealStatus">
										<c:if test="${mealStatus.first}">
											<format:sysText key="airItinerary.mealLabel" />
										</c:if>
										<format:description value="${meal}" /><c:if test="${!mealStatus.last}">; </c:if>
									</c:forEach>
								</p>
							</c:if>

						</div>
					</div>
				</div>

				<%-- Arrival --%>
				<div class="timeline-group ${legClass == 'lastLeg' || legClass == 'soloLeg' ? 'last-child' : ''}">
					<div class="timeline-item timeline-date timeline-label">
						<c:set var="legArriveFormatted">
							<format:dateTime value="${leg.arrive}" style="abbr-full-date-noyear" />
						</c:set>
						<c:if test="${legDate != legArriveFormatted || legClass == 'lastLeg' || legClass == 'soloLeg'}">
							<util:dataContext name="flightDepartureDate" var="dataContextAttr" />
							<strong class="date" ${dataContextAttr}>${legArriveFormatted}</strong>
							<c:set var="legDate">
								${legArriveFormatted}
							</c:set>
						</c:if>
					</div>

					<div class="timeline-item timeline-time timeline-label">
						<c:if test="${leg.displayArriveTime}">
							<util:dataContext name="flightArrivalTime" var="dataContextAttr" />
							<strong class="time" ${dataContextAttr}>
								<format:dateTime value="${leg.arrive}" style="short-time" />
							</strong>
						</c:if>
						<div class="timeline-marker"></div>
					</div>

					<div class="timeline-item timeline-info">
						<util:dataContext name="arrivalCityAndAirport" var="dataContextAttr" />
						<strong class="timeline-label" ${dataContextAttr}>
							<c:choose>
								<c:when test="${!(segmentCounter.last && legCounter.last)}">
									<format:sysText key="airItinerary.stopLabel">
										<format:param value="${leg.stopNumber}" />
									</format:sysText>:
								</c:when>
								<c:otherwise>
									<format:sysText key="airItinerary.arriveLabel" />:
								</c:otherwise>
							</c:choose>

							<%-- If destination is rail, display operating carrier instead of destination city (since destination in unknown) --%>
							<c:choose>
								<c:when test="${leg.railDestination && not empty leg.operatingCarrier}">
									<format:description value="${leg.operatingCarrier}" />
								</c:when>
								<c:when test="${renderParam.airResult.solutionSummary.international}">
									<formatx:location value="${leg.destination}" style="${cityNameStyle}" />, <formatx:location value="${leg.destination}" style="country" />
								</c:when>
								<c:otherwise>
									<formatx:location value="${leg.destination}" style="${cityNameStyle}" />
								</c:otherwise>
							</c:choose>
						</strong>

						<ul class="airport list-piped">
							<c:set var="airportCodeLegDestination" value="${renderParam.model.destinationOpenJaw && segmentCounter.last ? 'airportCodeDiffer' : '' }" />
							<li class="airportCode ${airportCodeLegDestination}">
								<formatx:location value="${leg.destination}" style="name" />
								<formatx:location value="${leg.destination}" style="code-abbr-parensTextOnly" />
							</li>
							<c:if test="${not empty leg.destinationTerminal}">
								<li class="terminal ${airportCodeLegDestination}"><format:sysText key="airItinerary.terminalLabel" /> ${leg.destinationTerminal}</li>
							</c:if>
						</ul>

						<render:include src="/WEB-INF/module/zero/results/airResults-airSliceDetails-alerts.jsp">
							<render:attribute name="leg" value="${leg}" />
							<render:attribute name="segment" value="${segment}" />
						</render:include>
					</div>

				</div>
				
			</div>

		</c:forEach>
		
	</c:forEach>
</div>
