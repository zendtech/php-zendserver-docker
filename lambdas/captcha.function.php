<?php
/**
 * This file can be changed "on the fly".
 */

 
/*
// With POST we could get here an integer in form '{"sum": 98}'.
$sum = json_decode($call_data, true)['sum'];
*/

// With GET, it's usually a map. We expect 'array(1) { ["sum"]=>string(2) "98" }'.
$sum = $call_params['sum'] + 0;

$a = rand(0, $sum);
$b = $sum - $a;


$img = imagecreate(700, 100);

$textbgcolor = imagecolorallocate($img, 170, 180, 230);
$textcolor = imagecolorallocate($img, 199, 255, 0);

// GapSansBold - https://github.com/Interstices-/GapSans
imagettftext($img, 70, 0, 20, 90, $textcolor, './GapSansBold.ttf', " $a + $b = ");

ob_start();
imagepng($img);
$imgRaw = ob_get_clean();


/*
// HTML output
$response->end('<img src="data:image/png;base64,' . base64_encode($imgRaw) . '"/>');
*/

// Raw output
$response->header('Content-type', 'image/png');
$response->end($imgRaw);


imagedestroy($img);
