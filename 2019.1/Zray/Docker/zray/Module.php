<?php

namespace Docker;

class Module extends \ZRay\ZRayModule {
	
	public function config() {
	    return array(
	        'extension' => array(
				'name' => 'Docker',
			),
	        'defaultPanels' => array(
	        ),
	        'panels' => array(
	            'info' => array(
	                'display'       => true,
			'alwaysShow' => true,
	                'logo'          => 'logo.png',
	                'menuTitle' 	=> 'Docker',
	                'panelTitle'	=> 'Docker',
	            ),
	         )
	    );
	}	
}
