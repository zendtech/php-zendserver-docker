<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="description" content="Simple index page based on Pure.css landing page example. See https://purecss.io/ ">
	<title>Dockerized ZS Index</title>
	<link rel="stylesheet" href="css.css">
</head>
<body>
<div class="header">
	<div class="home-menu pure-menu pure-menu-horizontal pure-menu-fixed">
		<span class="pure-menu-heading" style="text-transform:none">Server: <?php echo gethostname();?> @ <?php echo gethostbyname(gethostname());?></span>

		<ul class="pure-menu-list">
			<li class="pure-menu-item"><a target="_blank" href="https://www.zend.com/products/zend-server" class="pure-menu-link">Zend Server</a></li>
			<li class="pure-menu-item"><a target="_blank" href="https://hub.docker.com/_/php-zendserver/" class="pure-menu-link">Docker Hub</a></li>
			<li class="pure-menu-item"><a target="_blank" href="https://github.com/zendtech/php-zendserver-docker" class="pure-menu-link">GitHub</a></li>
		</ul>
	</div>
</div>

<div class="splash-container">
	<div class="splash">
		<p class="splash-subhead">
			The 'admin' password for <a target="_blank" href="http://127.0.0.1:10081/ZendServer/" class="pure-button pure-button-primary">Zend Server UI</a> is: <strong><?php readfile('/var/zs-xchange/ui_admin_pw');?></strong>
		</p>
		<h1 class="splash-head">Zend Server Cluster</h1>
		<p class="splash-subhead">
			Here are a couple of examples that you could try:
		</p>
		<p class="splash-subhead">
			an example of a <a target="_blank" href="/example.html" class="pure-button pure-button-primary">CAPTCHA</a> delivered by "lambda"
		</p>
		<p class="splash-subhead">
			and an <a target="_blank" href="http://127.0.0.1:3000/" class="pure-button pure-button-primary">On-Line Editor</a> to go with it.
		</p>
	</div>
</div>
<!-- YES! It is a very bad style - mixing HTML and PHP. Try to un-see this... -->
</body>
</html>