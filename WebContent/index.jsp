<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="DAO.Constants_General"%>
<!DOCTYPE html>
<html>
<head lang="en">
<meta charset="UTF-8">
<title><%=Constants_General.SITE_LOGO%> | <%=Constants_General.SITE_SLOGAN%></title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport"
	content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta name="format-detection" content="telephone=no">
<meta name="renderer" content="webkit">
<meta http-equiv="Cache-Control" content="no-siteapp" />
<link rel="alternate icon" type="image/png" href="assets/i/favicon.ico">
<link rel="stylesheet" type="text/css"
	href="http://cdn.amazeui.org/amazeui/2.2.1/css/amazeui.css">
<script type="text/javascript"
	src="http://cdn.amazeui.org/amazeui/2.2.1/js/amazeui.min.js"></script>
<script type="text/javascript"
	src="http://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=false"></script>
<style>
.header {
	text-align: center;
}

.header h1 {
	font-size: 200%;
	color: #333;
	margin-top: 30px;
}

.header p {
	font-size: 14px;
}

#map_canvas {
	height: 100%
}
</style>

<script type="text/javascript">
	function initialize() {

		var myLatlng_1 = new google.maps.LatLng(43.663187, -79.401211); // AC
		var myLatlng_2 = new google.maps.LatLng(43.666063, -79.396056); // football

		var myLatlng_3 = new google.maps.LatLng(43.662852, -79.395814); //front campus
		var myLatlng_4 = new google.maps.LatLng(43.664827, -79.357620);// some river side
		var myLatlng_5 = new google.maps.LatLng(43.657062, -79.474202);// high park north

		var mapOptions = {
			center : new google.maps.LatLng(43.663076, -79.395626),
			zoom : 13,
			mapTypeId : google.maps.MapTypeId.ROADMAP
		};
		var map = new google.maps.Map(document.getElementById("map_canvas"),
				mapOptions);

		var marker1 = new google.maps.Marker(
				{
					position : myLatlng_1,
					map : map,
					title : 'BLue Jays v.s. Red Mocking Bird, Saturday Night 6pm - 9pm!'
				});

		google.maps.event.addListener(marker1, 'click', function() {
			new google.maps.InfoWindow({
				content : marker1.title
			}).open(map, marker1);
		});

		var marker3 = new google.maps.Marker({
			position : myLatlng_3,
			map : map,
			title : 'Football at front campus, join us this Saturday!'
		});
		google.maps.event.addListener(marker3, 'click', function() {
			new google.maps.InfoWindow({
				content : marker3.title
			}).open(map, marker3);
		});
		var marker4 = new google.maps.Marker({
			position : myLatlng_4,
			map : map,
			title : 'Go fishing this weekend, join us!'
		});
		google.maps.event.addListener(marker4, 'click', function() {
			new google.maps.InfoWindow({
				content : marker4.title
			}).open(map, marker4);
		});
		var marker5 = new google.maps.Marker({
			position : myLatlng_5,
			map : map,
			title : 'Holding a ENGINEERING picnic at high park, check it out!'
		});
		google.maps.event.addListener(marker5, 'click', function() {
			new google.maps.InfoWindow({
				content : marker5.title
			}).open(map, marker5);
		});
	}

	google.maps.event.addDomListener(window, 'load', initialize);
</script>


</head>
<body>
	<div class="header">
		<div class="am-g">
			<div id="map_canvas" style="height: 180px"></div>
		</div>
		<hr />
	</div>
	<div class="am-g">
		<div class="am-u-lg-6 am-u-md-8 am-u-sm-centered">
			<h2>Login</h2>
			<hr>
			<div class="am-btn-group">
				<a href="LoginServlet" class="am-btn am-btn-success am-btn-sm"><i
					class="am-icon-google-plus-square am-icon-sm"></i> Google+</a>
			</div>
			<br> <br>
			<form action="" method="post" class="am-form">
				<label for="email">E-Mail:</label> <input type="email" name=""
					id="email" value="" required/> <br> <label for="password">PASSWORD:</label>
				<input type="password" name="" id="password" value="" required/> <br>
				<label for="remember-me"> <input id="remember-me"
					type="checkbox"> Remember Me
				</label> <br />
				<div class="am-cf">
					<input type="submit" name="" value="Login"
						class="am-btn am-btn-primary am-btn-sm am-fl"> <input
						type="submit" name="" value="Forget Password? "
						class="am-btn am-btn-default am-btn-sm am-fr">
				</div>
			</form>
			<hr>
			<div align=center>
				<small><%=Constants_General.SITE_FOOTER%></small>
			</div>
		</div>
	</div>
</body>
</html>