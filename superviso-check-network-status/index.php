<?php require 'config.php'; ?><!DocType html>
<html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		<meta http-equiv="cleartype" content="on">
		<meta name="HandheldFriendly" content="True">
		<meta name="MobileOptimized" content="320">
		<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0">
		<meta name="keywords" content="<?php echo $Title; ?> Network Status">
		<meta name="description" content="<?php echo $Title; ?> Network Status">
		<title>Network Status &nbsp;&middot;&nbsp; <?php echo $Title; ?></title>
		<link rel="stylesheet" href="//fonts.googleapis.com/css?family=Lato:300,400,700,300italic,400italic">
		<link rel="stylesheet" href="style.css">
		<script>var jQl={q:[],dq:[],gs:[],ready:function(a){'function'==typeof a&&jQl.q.push(a);return jQl},getScript:function(a,c){jQl.gs.push([a,c])},unq:function(){for(var a=0;a<jQl.q.length;a++)jQl.q[a]();jQl.q=[]},ungs:function(){for(var a=0;a<jQl.gs.length;a++)jQuery.getScript(jQl.gs[a][0],jQl.gs[a][1]);jQl.gs=[]},bId:null,boot:function(a){'undefined'==typeof window.jQuery.fn?jQl.bId||(jQl.bId=setInterval(function(){jQl.boot(a)},25)):(jQl.bId&&clearInterval(jQl.bId),jQl.bId=0,jQl.unqjQdep(),jQl.ungs(),jQuery(jQl.unq()), 'function'==typeof a&&a())},booted:function(){return 0===jQl.bId},loadjQ:function(a,c){setTimeout(function(){var b=document.createElement('script');b.src=a;document.getElementsByTagName('head')[0].appendChild(b)},1);jQl.boot(c)},loadjQdep:function(a){jQl.loadxhr(a,jQl.qdep)},qdep:function(a){a&&('undefined'!==typeof window.jQuery.fn&&!jQl.dq.length?jQl.rs(a):jQl.dq.push(a))},unqjQdep:function(){if('undefined'==typeof window.jQuery.fn)setTimeout(jQl.unqjQdep,50);else{for(var a=0;a<jQl.dq.length;a++)jQl.rs(jQl.dq[a]); jQl.dq=[]}},rs:function(a){var c=document.createElement('script');document.getElementsByTagName('head')[0].appendChild(c);c.text=a},loadxhr:function(a,c){var b;b=jQl.getxo();b.onreadystatechange=function(){4!=b.readyState||200!=b.status||c(b.responseText,a)};try{b.open('GET',a,!0),b.send('')}catch(d){}},getxo:function(){var a=!1;try{a=new XMLHttpRequest}catch(c){for(var b=['MSXML2.XMLHTTP.5.0','MSXML2.XMLHTTP.4.0','MSXML2.XMLHTTP.3.0','MSXML2.XMLHTTP','Microsoft.XMLHTTP'],d=0;d<b.length;++d){try{a= new ActiveXObject(b[d])}catch(e){continue}break}}finally{return a}}};if('undefined'==typeof window.jQuery){var $=jQl.ready,jQuery=$;$.getScript=jQl.getScript};</script>
		<!--[if lt IE 9]>
			<script>jQl.loadjQ('//cdn.jsdelivr.net/g/modernizr,selectivizr,prefixfree,jquery@1.11.0,jquery.equalize,jquery.downboy');</script>
		<![endif]-->
		<!--[if IE 9]><!-->
			<script>jQl.loadjQ('//cdn.jsdelivr.net/g/modernizr,prefixfree,jquery,jquery.equalize,jquery.downboy');</script>
		<!--<![endif]-->
		<script>
			$(function(){
				equalize();
				downBoy();
				window.onresize = function() {
					equalize();
					downBoy();
				}
			})
		</script>
	</head>
	<body>
		<div id="skiptomain"><a href="#maincontent">skip to main content</a></div>
		<div id="headcontainer">
			<header>
				<h1>Transabadell Network Status</h1>
				<h5>by <?php echo $Title; ?></h5>
			</header>
		</div>
		<div id="maincontentcontainer">
			<div id="maincontent">
				<div class="section group">
<?

function fetch($ID, $Description, $Problem, $Key, $Count, $CustomTime) {

    // Compute Variables
	$API_URL = 'http://api.uptimerobot.com/getMonitors?logs=1&format=xml&apiKey=' . $Key . '&monitors=' . $ID . '&responseTimes=1&responseTimesAverage=1440';

	if ($CustomTime) $API_URL .= '&customUptimeRatio=' . $CustomTime;

	// Fetch from API
	$API_Fetch = curl_init($API_URL);
	curl_setopt($API_Fetch, CURLOPT_RETURNTRANSFER, true);
	$API_XML = curl_exec($API_Fetch);
	curl_close($API_Fetch);

	// Parse XML
	$ParsedXML = simplexml_load_string($API_XML);

	// Loop Monitors
	foreach($ParsedXML->monitor as $Monitor) {
		echo '<div class="col span_1_of_'.$Count.'">';
		echo '<h2>'.$Monitor['friendlyname'].'</h2>';
		if ($Monitor['status'] == 2) {
			$Direction = 'up';
			$Status = 'Online';
		} elseif ($Monitor['status'] == 9) {
			$Direction = 'down';
			$Status = 'Offline';
		} elseif ($Monitor['status'] == 8) {
			$Direction = 'level';
			$Status = 'Experiencing Difficulties';
		} elseif ($Monitor['status'] == 0) {
			$Direction = 'none';
			$Status = 'Paused';
		} elseif ($Monitor['status'] == 1) {
			$Direction = 'none';
			$Status ='Not Checked Yet';
		} else {
			$Direction = 'down';
			$Status = 'AWOL';
		}
		echo '<p class="equalize box">'.$Description;
		if ($Status != 'Online') {
			if (!empty($Description) && $Status != 'Online') echo '<br>';
			echo '<span class="red">'.$Problem.'</span>';
		}
		echo '</p>';
		echo '<h3 class="box '.$Direction.'">'.$Status.'</h3>';
		if ($CustomTime) {
			if ($Monitor['customuptimeratio'] >= 99) {
				$Direction = 'up';
			} elseif ($Monitor['customuptimeratio'] >= 90) {
				$Direction = 'level';
			} else {
				$Direction = 'down';
			} echo '<h4 class="box '.$Direction.'">'.$Monitor['customuptimeratio'].'% Uptime</h4>';
		} else {
			if ($Monitor['alltimeuptimeratio'] >= 99) {
				$Direction = 'up';
			} elseif ($Monitor['alltimeuptimeratio'] >= 90) {
				$Direction = 'level';
			} else {
				$Direction = 'down';
			} echo '<h4 class="box '.$Direction.'">'.$Monitor['alltimeuptimeratio'].'% Uptime</h4>';
		}
		echo '<div class="breaker"></div>';
		foreach($Monitor->responsetime as $Responsetime) {
			echo '<h5>Response Time</h5>';
			echo '<h6 class="box';
			if ($Responsetime['value'] > 300) echo ' down';
			else echo ' up';
			echo ' faded">'.$Responsetime['value'].' ms'.' &nbsp;&middot;&nbsp; '.$Responsetime['datetime'].'</h6>';
			echo '<div class="breaker"></div>';
		}
		echo '<h5>Events</h5>';
		foreach($ParsedXML->monitor->log as $Log) {
			if ($Log['type'] == 2) {
				$Direction = 'up';
				$Status = 'Online';
			} elseif ($Log['type'] == 1) {
				$Direction = 'down';
				$Status = 'Offline';
			} elseif ($Log['type'] == 98) {
				$Direction = 'none';
				$Status ='Started';
			} elseif ($Log['type'] == 99) {
				$Direction = 'level';
				$Status = 'Paused';
			} else {
				$Direction = 'down';
				$Status = 'AWOL';
			}
			echo '<h6 class="box '.$Direction.' faded">'.$Status.' &nbsp;&middot;&nbsp; '.$Log['datetime'].'</h6>';
		}
		echo '</div>';
	}

}

$Count = count($IDs);
for ($i=0; $i<$Count; ++$i) {
    fetch($IDs[$i], $Descriptions[$i], $Apologies[$i], $API_Key, $Count, $CustomTime);
}

// Load Footer
?>
				</div>
			</div>
		</div>
		<div id="footercontainer">
			<footer class="section group">
				<div class="col span_5_of_8">
					<p class="left">Copyright &copy; <?php echo date('Y').' '.$Title; ?></p>
				</div>
				<div class="col span_1_of_8"><p><a href="//status.example.corp/">Status</a></div>
				<div class="col span_1_of_8"><p><a href="//forum.example.corp/">Disclaimer</a></div>
				<div class="col span_1_of_8"><p><a href="//www.example.corp/legal/copyright/">Copyright</a></p></div>
			</footer>
		</div>
	</body>
</html>
