<%@page import="DAO.Constants_General"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.google.appengine.api.users.User"%>
<%@ page import="com.google.appengine.api.users.UserService"%>
<%@ page import="com.google.appengine.api.users.UserServiceFactory"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.List"%>
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
<script type="text/javascript"
	src="http://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=false"></script>
<link rel="alternate icon" type="image/png" href="assets/i/favicon.png">
<link rel="stylesheet" type="text/css"
	href="http://cdn.amazeui.org/amazeui/2.2.1/css/amazeui.css">
<script type="text/javascript"
	src="http://cdn.amazeui.org/amazeui/2.2.1/js/amazeui.min.js"></script>
<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=false&libraries=places"></script>


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
	function initialize() {
		var mapOptions = {
			center : new google.maps.LatLng(43.663076, -79.395626),
			zoom : 13,
			mapTypeId : google.maps.MapTypeId.ROADMAP
		};
		var map = new google.maps.Map(document.getElementById("map_canvas"),
				mapOptions);
		
		// this is for autocomplete address
		var input = "";
		var autocomplete = new google.maps.places.Autocomplete(input);
		autocomplete.bindTo('bounds', map);
		
		// set marker and its infowindow
		var infowindow = new google.maps.InfoWindow();
		var marker = new google.maps.Marker(
				{
					map : map,
				    anchorPoint: new google.maps.Point(0, -29)
				});//Get list of rows in the table
				


		// add event listener to table rows
		var rows = document.getElementById("availableEventTableBody").getElementsByTagName("tr").length;
		var el;
		for (var i = 0; i < rows; i++) { 
			el = document.getElementById("singleAvailableEvent_"+i);
			el.addEventListener("click", putLocationOnMap , false);
		}
	}
	
	google.maps.event.addDomListener(window, 'load', initialize);
	
	function putLocationOnMap() {
		var address = document.getElementById ("loc_" + event.currentTarget.id).innerText;
		alert (address);
		var autocomplete = new google.maps.places.Autocomplete(address);
		autocomplete.bindTo('bounds', map);
		
		
				
		infowindow.close();
	    marker.setVisible(false);
	    var place = autocomplete.getPlace();
	    if (!place.geometry) {
	      return;
	    }

	    // If the place has a geometry, then present it on a map.
	    if (place.geometry.viewport) {
	      map.fitBounds(place.geometry.viewport);
	    } else {
	      map.setCenter(place.geometry.location);
	      map.setZoom(17);  // Why 17? Because it looks good.
	    }
	    marker.setPosition(place.geometry.location);
	    marker.setVisible(true);

	    var address = '';
	    if (place.address_components) {
	      address = [
	        (place.address_components[0] && place.address_components[0].short_name || ''),
	        (place.address_components[1] && place.address_components[1].short_name || ''),
	        (place.address_components[2] && place.address_components[2].short_name || '')
	      ].join(' ');
	    }

	    infowindow.setContent('<div><strong>' + place.name + '</strong><br>' + address);
	    infowindow.open(map, marker);
	}
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
						<div class="am-panel-hd">Joined Activities</div>
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
									<tr>
										<td><button class="am-btn am-btn-danger am-btn-xs">Quit</button></td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td><button class="am-btn am-btn-danger am-btn-xs">Quit</button></td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td><button class="am-btn am-btn-danger am-btn-xs">Quit</button></td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>
									<tr>
										<td>Canc</td>
										<td>L.A.C v.s. Boston</td>
										<td>2015-3-10 6:00pm to 10:00pm</td>
										<td>11Dunbloor Rd, Concert Center</td>
										<td>wyang.lau@gmail.com</td>
									</tr>

								</tbody>

							</table>

						</div>
					</div>

					<div class="am-panel am-panel-green">
						<div class="am-panel-hd">
							Available Activities <i
								class="am-icon-right am-icon-refresh am-icon-spin"></i>
						</div>

						<table class="am-table">
							<tbody>
								<tr>
									<td><select
										data-am-selected="{btnWidth: 120, btnSize: 'sm', maxHeight: '1000px'}">
											<option value="a">In 7 Days</option>
											<option value="b">In a month</option>
											<option value="o">Today</option>
											<option value="m">Others</option>
									</select></td>
									<td><select
										data-am-selected="{btnWidth: 180, btnSize: 'sm', maxHeight: '1000px'}">
											<option value="a">Downtown Toronto</option>
											<option value="b">North York</option>
											<option value="o">Mississauga</option>
											<option value="m">Scarborough</option>
											<option value="e">Others</option>
									</select></td>
									<td><select
										data-am-selected="{btnWidth: 120, btnSize: 'sm', maxHeight: '1000px'}">
											<option value="study"><%=Constants_General.EVENTCATEGORY_STUDY%></option>
											<option value="sport"><%=Constants_General.EVENTCATEGORY_SPORT%></option>
											<option value="party"><%=Constants_General.EVENTCATEGORY_PARTY%></option>
											<option value="other"><%=Constants_General.EVENTCATEGORY_OTHER%></option>
									</select></td>


								</tr>
							</tbody>
						</table>
						<div class="am-scrollable-vertical-large">

							<table
								class="am-table am-table-striped am-table-hover am-text-sm"
								>
								
								<thead>
									<tr>
										<th></th>
										<th>Title</th>
										<th>Schedule</th>
										<th>Location</th>
									</tr>
								</thead>
								<tbody 
								id = "availableEventTableBody">
									<%
										List<Event> allEvents = Services.parse(Services.getAllEvents());
										DateFormat fmt = new SimpleDateFormat("hh:mma,MMM.d");
										for (int i = 0; i < allEvents.size(); i++) {
										Event e = allEvents.get(i);
									%>
									<tr id = "singleAvailableEvent_<%=i%>">
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
															<li>Contact: <u><%=e.getContact()%></u></li>
															<li><%=e.getDescription()%></li>
														</ul>
													</div>
												</div>
												<button class="am-btn am-btn-success am-btn-xs">I'm
													in</button>
											</div>
										</td>
										<td><%=e.getTitle()%></td>
										<td>From:<%=fmt.format(e.getStartDateTime())%> <br>To:
											<%=fmt.format(e.getEndDateTime())%></td>
										<td id = loc_singleAvailableEvent_<%=i%>><%=e.getLocation()%></td>
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