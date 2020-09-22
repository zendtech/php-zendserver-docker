<?php
echo <<<EOF
<html>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Application Container Created | Zend Server Docker Container</title>
	<style type="text/css">
		h3 { color: #265974; }
		
		#congrats-banner { 
			width: 560px;
			height: 440px;	
			position: relative;
			left: 150px;
			padding: 44px 60px 15px 53px;
			line-height: normal; 
		}
		
		#congrats-banner h2 {
			color: #265974;
    		        line-height: 1em;
			font-size: 28pt;
			font-weight: normal;
			font-variant: small-caps;
			margin: 0;
			padding: 0;
			float: left;
			width: 230px;
		}
		
		#upload-code { 
			position: relative;
			top: 49px;
			left: 20px;
			line-height: 22px;
		}
		
		#upload-code h3 {
			font-size: 18px;
		}
		
		#whats-this {
			font-size: 11px;
			clear: both;
			position: relative;
			top: 105px;	
		}
		
		#whats-this h3 { 
			font-weight: normal;
		}
	</style>
</head>

<body>
	<div id="main-container">
		<div id="congrats-banner">
			<h2>your new application container is <strong>up</strong> and <strong>running</strong></h2>
			<div id="upload-code">
				<h3>Now it's time to visit the Zend Server User Interface:</h3>
				<p>Navigate to your container IP on port 10081 or to the redirected port (if applicable) to login.</p>
			</div>
			
			<div id="whats-this">
				<h3>What's this?</h3>
				<p>
					This default message is displayed because the owner of this Zend Server container did not upload any code yet. If you are not the owner of this 
					application container, there is not a lot for you to see here... sorry.
				</p>
			</div>
		</div>
	</div>
</body>

</html>
EOF;
