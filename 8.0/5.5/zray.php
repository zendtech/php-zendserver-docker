<?php

namespace ZRaySamplesDemo;

class Samples {
public function mult($num1) {
        return $_SERVER[$num1];
    }

   public function getVars($context, & $storage){
	$file = "/etc/hosts";
	$data = file($file);
	$line = $data[count($data)-1];
        $storage['Docker'][] = array('Variable' => 'Container internal IP', 'Value' => $_SERVER['SERVER_ADDR']);
        $storage['Docker'][] = array('Variable' => 'Remote Address', 'Value' => $_SERVER['REMOTE_ADDR']);
        $storage['Docker'][] = array('Variable' => 'Container ID', 'Value' => gethostname());
        $storage['Docker'][] = array('Variable' => 'Linked containers', 'Value' => $line);
    }

    public function runEnter($context, &$storage) {
        $storage['defaultTree'][] = $context;

    }
    
}


$zraySamples = new Samples();
$zre = new \ZRayExtension('samples');
if(preg_grep('/docker/', file('/proc/self/cgroup'))) $zre->setEnabled();
$zre->traceFunction('wp', function() {},  array($zraySamples, 'getVars'));

$zre->setMetadata(array(
	'logo' => __DIR__ . DIRECTORY_SEPARATOR . 'logo.png',
));

