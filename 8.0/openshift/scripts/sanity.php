<?php
while(1) {
$date = gmdate('D, d M Y H:i:s') . ' GMT';
$host = 'admin';
$useragent = 'Zend_Http_Client/1.10';
$accept = 'application/vnd.zend.serverapi+xml;version=1.5';
$apiKey = $argv[1];
$serverUrl = 'http://localhost:10081';
$path = '/ZendServer/Api/daemonsProbe';

$sign =  $host . '; ' . hash_hmac('sha256', $host . ":" . $path . ":" . $useragent . ":" . $date, $apiKey);



$ch = curl_init($serverUrl . $path);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
curl_setopt($ch,CURLOPT_HTTPHEADER,
array(
'Host: ' . $host,
'Date: ' . $date,
'User-agent: ' . $useragent,
'Accept: ' . $accept,
'X-Zend-Signature: ' . $sign
)
);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'GET');
$output = curl_exec($ch); 
curl_close($ch);
if(preg_match('/error/', $output)) {
	exec("/usr/local/zend/bin/zs-manage restart -N $host -K $apiKey");
}
sleep(5);
}
