<%@page import="DAO.Constants_General"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.google.appengine.api.users.User"%>
<%@ page import="com.google.appengine.api.users.UserService"%>
<%@ page import="com.google.appengine.api.users.UserServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.KeyFactory"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.LinkedList"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="models.Event"%>
<%@ page import="service.Services"%>
<!DOCTYPE html>
<html>

<head lang="en">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>Home | Find a Teammate</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport"
	content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta name="format-detection" content="telephone=no">
<meta name="renderer" content="webkit">
<meta http-equiv="Cache-Control" content="no-siteapp" />
<script
	src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js"></script>
<link rel="alternate icon" type="image/png" href="assets/i/favicon.png">
<link rel="stylesheet" type="text/css"
	href="http://cdn.amazeui.org/amazeui/2.2.1/css/amazeui.css">
<script type="text/javascript"
	src="http://cdn.amazeui.org/amazeui/2.2.1/js/amazeui.min.js"></script>
<script type="text/javascript"
	src="https://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=false&libraries=places"></script>


<style>
@media only screen and (min-width: 641px) {
	.am-offcanvas {
		display: block;
		position: static;
		background: none;
	}
	.am-offcanvas-bar {
		position: static;
		width: auto;
		background: none;
		-webkit-transform: translate3d(0, 0, 0);
		-ms-transform: translate3d(0, 0, 0);
		transform: translate3d(0, 0, 0);
	}
	.am-offcanvas-bar:after {
		content: none;
	}
}

@media only screen and (max-width: 640px) {
	.am-offcanvas-bar .am-nav>li>a {
		color: #ccc;
		border-radius: 0;
		border-top: 1px solid rgba(0, 0, 0, .3);
		box-shadow: inset 0 1px 0 rgba(255, 255, 255, .05)
	}
	.am-offcanvas-bar .am-nav>li>a:hover {
		background: #404040;
		color: #fff
	}
	.am-offcanvas-bar .am-nav>li.am-nav-header {
		color: #777;
		background: #404040;
		box-shadow: inset 0 1px 0 rgba(255, 255, 255, .05);
		text-shadow: 0 1px 0 rgba(0, 0, 0, .5);
		border-top: 1px solid rgba(0, 0, 0, .3);
		font-weight: 400;
		font-size: 75%
	}
	.am-offcanvas-bar .am-nav>li.am-active>a {
		background: #1a1a1a;
		color: #fff;
		box-shadow: inset 0 1px 3px rgba(0, 0, 0, .3)
	}
	.am-offcanvas-bar .am-nav>li+li {
		margin-top: 0;
	}
}

.am-g-fixed {
	max-width: 2000px;
}

.my-head {
	margin-top: 40px;
	text-align: center;
}

.my-button {
	position: fixed;
	top: 0;
	right: 0;
	border-radius: 0;
}

.my-sidebar {
	padding-right: 0;
	border-right: 1px solid #eeeeee;
}

.my-footer {
	border-top: 1px solid #eeeeee;
	padding: 10px 0;
	margin-top: 10px;
	text-align: center;
}

.am-topbar-text {
	padding: 0 10px;
	font-size: 1.8rem;
	height: 50px;
	line-height: 50px;
}

#map_canvas {
	height: 100%
}

.am-panel-green {
	border-color: #429842;
}

.am-panel-green>.am-panel-hd {
	color: #ffffff;
	background-color: #429842;
	border-color: #429842;
}

.am-panel-green>.am-panel-hd+.am-panel-collapse>.am-panel-bd {
	border-top-color: #429842;
}

.am-panel-green>.am-panel-footer+.am-panel-collapse>.am-panel-bd {
	border-bottom-color: #429842;
}

.am-scrollable-vertical-small {
	height: 180px;
	overflow-y: scroll;
	-webkit-overflow-scrolling: touch;
	resize: vertical;
}

.am-scrollable-vertical-large {
	height: 300px;
	overflow-y: scroll;
	-webkit-overflow-scrolling: touch;
	resize: vertical;
}

.am-icon-right {
	float: right;
	margin-right: 10px;
}

.am-u-md-pull-7-5 {
	right: 59.33333333%;
}
</style>

<script type="text/javascript">
	var geocoder;
	var map;
	var infowindow;
	var marker;
	function initialize() {

		geocoder = new google.maps.Geocoder();
		var mapOptions = {
			center : new google.maps.LatLng(43.663076, -79.395626),
			zoom : 13,
			mapTypeId : google.maps.MapTypeId.ROADMAP
		};
		map = new google.maps.Map(document.getElementById('map_canvas'),
				mapOptions);

		// set marker and its infowindow
		infowindow = new google.maps.InfoWindow();
		marker = new google.maps.Marker({
			map : map,
			anchorPoint : new google.maps.Point(0, -29)
		});//Get list of rows in the table

		// add event listener to table rows
		var rows = document.getElementById("availableEventTableBody")
				.getElementsByTagName("tr").length;
		var el;
		for (var i = 0; i < rows; i++) {
			el = document.getElementById("singleAvailableEvent_" + i);
			el.addEventListener("click", codeAddress, false);
		}
	}

	function codeAddress() {
		infowindow.close();
		marker.setVisible(false);
		var place = document.getElementById("loc_" + event.currentTarget.id).innerText;
		var stringAddress = place;
		geocoder
				.geocode(
						{
							'address' : place
						},
						function(results, status) {
							if (status == google.maps.GeocoderStatus.OK) {

								// If the place has a geometry, then present it on a map.
								if (results[0].geometry.viewport) {
									map.fitBounds(results[0].geometry.viewport);
								} else {
									map.setCenter(results[0].geometry.location);

									map.setZoom(17); // Why 17? Because it looks good.
								}
								marker
										.setPosition(results[0].geometry.location);
								marker.setVisible(true);

								var address2 = '';
								if (results[0].address_components) {
									address2 = [
											(results[0].address_components[0]
													&& results[0].address_components[0].short_name || ''),
											(results[0].address_components[1]
													&& results[0].address_components[1].short_name || ''),
											(results[0].address_components[2]
													&& results[0].address_components[2].short_name || ''),
											(results[0].address_components[3]
													&& results[0].address_components[3].short_name || '') ]
											.join(' ');
								}

								// trim address2 for everything that is displayed by stringAddress
								var address3 = address2.replace(stringAddress
										.split(",")[0], "");

								infowindow.setContent('<div><strong>'
										+ stringAddress.split(",")[0]
										+ '</strong><br>' + address3);
								infowindow.open(map, marker);
							} else {
								alert('Geocode was not successful for the following reason: '
										+ status);
							}
						});
	}

	$(document).ready(
			function() {
				$("#filter_date,#filter_capacity,#filter_category").change(

						function() {
							$.ajax({
								type : "POST",
								url : "FilterServlet",
								data : {
									filter_date : $("#filter_date").find(
											"option:selected").text(),
									filter_capacity : $("#filter_capacity")
											.find("option:selected").text(),
									filter_category : $("#filter_category")
											.find("option:selected").text(),
								},
								success : function(result) {
									window.location.reload();

								}
							})

						})
			});

	function quit(key) {
		var r = confirm("Do you really want to quit this event ?");
		if (r == true) {
			$.ajax({
				type : "POST",
				url : "QuitEventServelt",
				data : {
					keyString : key
				},
				success : function(result) {
					if (result != "success") {
						alert("Error incurred. Exception message: " + result)
					} else {
						window.location.reload();
					}
				}

			})
		}
	}

	function join(key) {
		$.ajax({
			type : "POST",
			url : "JoinEventServlet",
			data : {
				keyString : key
			},
			success : function(result) {
				if (result != "success") {
					alert("Error incurred. Exception message: " + result)
				} else {
					window.location.reload();
				}
			}

		})
	}

	google.maps.event.addDomListener(window, 'load', initialize);
</script>

</head>
<body onload="initialize()">
	<%
		UserService userService = UserServiceFactory.getUserService();
		User user = userService.getCurrentUser();
	%>
	<header class="am-topbar am-topbar-fixed-top">
		<h1 class="am-topbar-brand">
			<a href="#"> Teamangine </a>
		</h1>

		<div class="am-collapse am-topbar-collapse" id="doc-topbar-collapse">
			<ul class="am-nav am-nav-pills am-topbar-nav">
				<li class="am-active"><a href="#"><%=Constants_General.TOPBAR_HOME%></a></li>
				<li><a href="create.jsp"><%=Constants_General.TOPBAR_CREATE%></a></li>
			</ul>
			<div class="am-topbar-right">
				<a href="<%=userService.createLogoutURL("/index.jsp")%>"><button
						class="am-btn am-btn-success am-topbar-btn am-btn-sm">Logout</button></a>
			</div>
			<div class=" am-topbar-right am-topbar-text">
				Hi
				<%=user.getNickname()%>, how are you doing?
			</div>


		</div>

	</header>
	<div class="am-g am-g-fixed">
		<div class="am-u-md-7 am-u-md-push-5">
			<div class="am-g">
				<div id="map_canvas" style="height: 600px; width: 99.5%"></div>
			</div>
		</div>

		<div class="am-u-md-5 am-u-md-pull-7-5 am-margin-right-xs my-sidebar"
			style="width: 40%; align: center">
			<div class="am-offcanvas" id="sidebar">
				<div class="am-offcanvas-bar">

					<div class="am-panel am-panel-primary">
						<div class="am-panel-hd"><%=Constants_General.HOME_JOINED%></div>
						<div class="am-scrollable-vertical-small">
							<table
								class="am-table am-table-striped am-table-hover am-text-sm">
								<thead>
									<tr>
										<th></th>
										<th>Title</th>
										<th>Schedule</th>
										<th>Location</th>
										<th>Contact</th>
									</tr>
								</thead>

								<tbody>
									<%
										Map<String, List<Event>> batch = Services.retrieveAllEvents(null,
												null, null);
										List<Event> availables = batch
												.get(Constants_General.AVAILABLE_EVENTS);
										List<Event> joined = batch.get(Constants_General.JOINED_EVENTS);
										DateFormat fmt = new SimpleDateFormat("HH:mma,MMM.d");
										for (Event e : joined) {
									%>
									<tr>
										<td><button class="am-btn am-btn-danger am-btn-xs"
												onclick="quit('<%=KeyFactory.keyToString(e.getKey())%>')">Quit</button></td>
										<td><%=e.getTitle()%></td>
										<td>From:<%=fmt.format(e.getStartDateTime())%> <br>To:
											<%=fmt.format(e.getEndDateTime())%></td>
										<td><%=e.getLocation()%></td>
										<td><%=e.getContact()%></td>
									</tr>
									<%
										}
									%>
								</tbody>

							</table>

						</div>
					</div>

					<div class="am-panel am-panel-green">
						<div class="am-panel-hd">
							<%=Constants_General.HOME_AVAILABLE%>
							<i class="am-icon-right am-icon-refresh am-icon-spin"></i>
						</div>

						<table class="am-table">
							<tbody>
								<tr>
									<td><select id=<%=Constants_General.FILTER_DATE_ID%>
										data-am-selected="{btnWidth: 135, btnSize: 'sm', maxHeight: '1000px'}">
											<option value="r"><%=Constants_General.FILTER_DATE_DEFAULT%></option>
											<option value="y"><%=Constants_General.SORT_DATE_ASCENDING%></option>
											<option value="a"><%=Constants_General.SORT_DATE_DESCENDING%></option>
									</select></td>
									<td><select id="<%=Constants_General.FILTER_CAPACITY_ID%>"
										data-am-selected="{btnWidth: 190, btnSize: 'sm', maxHeight: '1000px'}">
											<option value="n"><%=Constants_General.FILTER_CAPACITY_DEFAULT%></option>
											<option value="h"><%=Constants_General.FILTER_CAPACITY_LESS_THAN_10%></option>
											<option value="a"><%=Constants_General.FILTER_CAPACITY_LESS_THAN_20%></option>
											<option value="r"><%=Constants_General.FILTER_CAPACITY_LESS_THAN_50%></option>
											<option value="i"><%=Constants_General.FILTER_CAPACITY_MORE_THAN_50%></option>
									</select></td>
									<td><select id="<%=Constants_General.FILTER_CATEGORY_ID%>"
										data-am-selected="{btnWidth: 125, btnSize: 'sm', maxHeight: '1000px'}">
											<option value="s"><%=Constants_General.FILTER_CATEGORY_DEFAULT%></option>
											<option value="l"><%=Constants_General.FILTER_CATEGORY_SPORT%></option>
											<option value="i"><%=Constants_General.FILTER_CATEGORY_PARTY%></option>
											<option value="n"><%=Constants_General.FILTER_CATEGORY_SEMINAR%></option>
											<option value="g"><%=Constants_General.FILTER_OTHERS%></option>
									</select></td>


								</tr>
							</tbody>
						</table>
						<div class="am-scrollable-vertical-large">

							<table
								class="am-table am-table-striped am-table-hover am-text-sm">

								<thead>
									<tr>
										<th></th>
										<th>Title</th>
										<th>Schedule</th>
										<th>Location</th>
									</tr>
								</thead>
								<tbody id="availableEventTableBody">
									<%
										String dateFilter = (String) session
												.getAttribute(Constants_General.FILTER_DATE_ID);
										String capFilter = (String) session
												.getAttribute(Constants_General.FILTER_CAPACITY_ID);
										String cateFilter = (String) session
												.getAttribute(Constants_General.FILTER_CATEGORY_ID);
									%>
									<%
										if ((dateFilter != null) || (capFilter != null)
												|| (cateFilter != null)) {
											availables = Services.retrieveAllEvents(dateFilter, capFilter,
													cateFilter).get(Constants_General.AVAILABLE_EVENTS);

										}
										session.setAttribute(Constants_General.FILTER_DATE_ID, null);
										session.setAttribute(Constants_General.FILTER_CAPACITY_ID, null);
										session.setAttribute(Constants_General.FILTER_CATEGORY_ID, null);
										for (int i = 0; i < availables.size(); i++) {
											Event e = availables.get(i);
									%>
									<tr id="singleAvailableEvent_<%=i%>">
										<td>
											<div class="am-btn-group-stacked">
												<div class="am-dropdown top-layer" data-am-dropdown>
													<button
														class="am-btn am-btn-default am-btn-xs am-dropdown-toggle">
														Detail<span class="am-icon-caret-down"></span>
													</button>
													<div class="am-dropdown-content" style="min-width: 320px;">
														<h4>Detailed Information</h4>
														<ul>
															<li>Category:<%=e.getCategory()%></li>
															<li>Capacity: <%=e.getCapacity()%></li>
															<li>Contact: <u><%=e.getContact()%></u></li>
															<li><%=e.getDescription()%></li>
														</ul>
													</div>
												</div>
												<button class="am-btn am-btn-success am-btn-xs"
													onclick="join('<%=KeyFactory.keyToString(e.getKey())%>')">I'm
													in</button>
											</div>
										</td>
										<td><%=e.getTitle()%></td>
										<td>From:<%=fmt.format(e.getStartDateTime())%> <br>To:
											<%=fmt.format(e.getEndDateTime())%></td>
										<td id=loc_singleAvailableEvent_ <%=i%>><%=e.getLocation()%></td>
										<td></td>
									</tr>
									<%
										}
									%>
								</tbody>
							</table>
						</div>
					</div>


				</div>
			</div>
		</div>
	</div>

	<footer class="my-footer">
		<p>
			Find a teammate<br> <small>© 2015Winter | ECE1779 |
				Ryan/Harris/Ling </small>
		</p>
	</footer>
</body>
</html>