<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.google.appengine.api.users.User"%>
<%@ page import="com.google.appengine.api.users.UserService"%>
<%@ page import="com.google.appengine.api.users.UserServiceFactory"%>
<%@page import="DAO.Constants_General"%>
<!DOCTYPE html>
<html>

<head lang="en">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>Management | Find a Teammate</title>
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
<link rel="stylesheet" type="text/css"
	href="css/amazeui.datetimepicker.css">
<script type="text/javascript"
	src="http://cdn.amazeui.org/amazeui/2.2.1/js/amazeui.min.js"></script>
<script type="text/javascript" src="js/amazeui.datetimepicker.min.js"
	charset="UTF-8"></script>
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
	height: 560px;
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

.am-u-md-left-right {
	margin-left: 6px;
	margin-right: 0px
}
</style>

<script type="text/javascript">
	function initialize() {
		// setup map
		var mapOptions = {
			center : new google.maps.LatLng(43.663076, -79.395626),
			zoom : 13,
			mapTypeId : google.maps.MapTypeId.ROADMAP
		};
		var map = new google.maps.Map(document.getElementById("map_canvas"),
				mapOptions);
		
		
		// this is for autocomplete address
		var input = /** @type {HTMLInputElement} */(
			      document.getElementById('create_location'));
		var autocomplete = new google.maps.places.Autocomplete(input);
		autocomplete.bindTo('bounds', map);
		
		// set marker and its infowindow
		var infowindow = new google.maps.InfoWindow();
		var marker = new google.maps.Marker(
				{
					map : map,
				    anchorPoint: new google.maps.Point(0, -29)
				});
		
		  google.maps.event.addListener(autocomplete, 'place_changed', function() {
			    infowindow.close();
			    marker.setVisible(false);
			    var place = autocomplete.getPlace();
			  	var stringAddress = document.getElementById ('create_location').value;
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
			    
			    
			    var address2 = '';
			    if (place.address_components) {
			      address2 = [
			        (place.address_components[0] && place.address_components[0].short_name || ''),
			        (place.address_components[1] && place.address_components[1].short_name || ''),
			        (place.address_components[2] && place.address_components[2].short_name || ''),
			        (place.address_components[3] && place.address_components[3].short_name || '')
			      ].join(' ');
			    }
			    
			 	// trim address2 for everything that is displayed by stringAddress
			    var address3 =  address2.replace(stringAddress.split(",")[0],"")

			    infowindow.setContent('<div><strong>' + stringAddress.split(",")[0] + '</strong><br>' + address3);
			    infowindow.open(map, marker);
			  });


	}
	/* initilize listener */
	google.maps.event.addDomListener(window, 'load', initialize);
	
	
	
	$(function() {
		$('.form_datetime-from').datetimepicker({
			format : 'yyyy-mm-dd hh:ii',
			autoclose : true,
			todayBtn : true,
			minuteStep : 10
		});

		$('.form_datetime-to').datetimepicker({
			format : 'yyyy-mm-dd hh:ii',
			autoclose : true,
			todayBtn : true,
			minuteStep : 10
		});

	});

	function create() {
		
		if (!$('#create_form').data('amui.validator').isFormValid()) {
			return;
		}
		document.getElementById("create_event").disabled = true;
		$.ajax({
			type : "POST",
			url : "UploadServlet",
			data : {
				creator : $("#creator").val(),
				create_title : $("#create_title").val(),
				create_category : $("#create_category").val(),
				create_capacity : $("#create_capacity").val(),
				create_from : $("#create_from").val(),
				create_to : $("#create_to").val(),
				create_location : $("#create_location").val(),
				create_contact : $("#create_contact").val(),
				create_description : $("#create_description").val(),
			},
			success : function(result) {
				if (result == "success") {
					alert("Event created successfully.")
					window.location.reload();
				} else {
					alert("Error incurred, try again later. Error message :"
							+ result);
				}
				document.getElementById("create_event").disabled = false;
			}
		})
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
				<li><a href="events.jsp"><%=Constants_General.TOPBAR_HOME%></a></li>
				<li class="am-active"><a href="#"><%=Constants_General.TOPBAR_CREATE%></a></li>
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
						<div class="am-panel-hd">Create an Event</div>
						<div class="am-scrollable-vertical-large">


							<form action="" class="am-form" method="POST" id="create_form"
								data-am-validator>
								<fieldset>
									<input type=hidden name="creator" id="creator"
										value=<%=user.getEmail()%> hidden=true>
									<div class="am-form-group">
										<input type="text" id="create_title" name="create_title"
											placeholder="Title" maxlength="30" required />
									</div>

									<div class="am-form-group">
										<select id="create_category" name="create_category">
											<option value="study"><%=Constants_General.EVENTCATEGORY_STUDY%></option>
											<option value="sport"><%=Constants_General.EVENTCATEGORY_SPORT%></option>
											<option value="party"><%=Constants_General.EVENTCATEGORY_PARTY%></option>
											<option value="other"><%=Constants_General.EVENTCATEGORY_OTHER%></option>
										</select> <span class="am-form-caret"></span>
									</div>
									<div class="am-form-group">
										<input type="number" id="create_capacity" min="2"
											name="create_capacity"
											placeholder="Recommend Number of 
											Participants. (Numbers Only)"
											required />
									</div>

									<div class="am-form-group">
										<div class="date form_datetime-from am-input-group">
											<input id="create_from" name="create_from" size="16"
												type="text" placeholder="From" class="am-form-field"
												readonly required /> <span
												class="am-input-group-label add-on"><i
												class="icon-th am-icon-calendar"></i></span>
										</div>
									</div>

									<div class="am-form-group">
										<div class="date form_datetime-to am-input-group">
											<input id="create_to" name="create_to" size="16" type="text"
												placeholder="To" class="am-form-field" readonly required />
											<span class="am-input-group-label add-on"><i
												class="icon-th am-icon-calendar"></i></span>
										</div>
									</div>


									<div class="am-form-group">
										<div class="am-input-group">
											<input type="text" id="create_location"
												name="create_location"
												placeholder="Input keywords and locate your exact address"
												required /> <span class="am-input-group-label add-on"><i
												class="icon-th am-icon-map-marker"></i></span>
										</div>
									</div>


									<div class="am-form-group">
										<input type="text" id="create_contact" name="create_contact"
											placeholder="How to contact you? Email / Mobile Phone, etc."
											required>

									</div>

									<div class="am-form-group">
										<textarea class="" rows="4" id="create_description"
											name="create_description" maxlength="200"
											placeholder="Describe details of your activity."></textarea>
									</div>
									<button id="create_event" class="am-btn am-btn-default"
										onclick="create()">Publish</button>
								</fieldset>
							</form>


						</div>
					</div>


				</div>
			</div>
		</div>

	</div>
	<div class="am-u-md-left-right">
		<div class="am-panel am-panel-green">
			<div class="am-panel-hd">Manage Events You Created</div>

			<div class="am-scrollable-vertical">
				<table class="am-table am-table-striped am-table-hover am-text-sm">
					<thead>
						<tr>

							<th>Event Title</th>
							<th>Category</th>
							<th>Capacity</th>
							<th>Start Time</th>
							<th>End Time</th>
							<th>Location</th>
							<th>Contact</th>
							<th>Description</th>
							<th>Operation</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>L.A.C v.s. Boston</td>
							<td>Sport</td>
							<td>1024</td>
							<td>2015-3-10 6:00pm</td>
							<td>2015-3-10 10:00pm</td>
							<td>11Dunbloor Rd, Concert Center</td>
							<td>wyang.lau@gmail.com</td>
							<td>We will serve BBQ and cokes.</td>
							<td><button class="am-btn am-btn-danger am-btn-xs">Abort</button></td>
						</tr>
					</tbody>
				</table>
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