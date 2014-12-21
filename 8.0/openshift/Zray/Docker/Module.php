<?php

namespace Docker;

class Module extends \ZRay\ZRayModule {
	
	public function config() {
	    return array(
	        'extension' => array(
				'name' => 'zraydocker',
			),
	        // Prevent those default panels from being displayed
	        'defaultPanels' => array(
	        ),
	        // configure all custom panels
	        'panels' => array(
	            'ci' => array(
	                'display'       => true,
			'alwaysShow' => true,
	                'logo'          => 'logo.png',
	                'menuTitle' 	=> 'Docker',
	                'panelTitle'	=> 'Docker',
	                //'searchId' 		=> 'samples-custom-table-search',
	                //'pagerId'		=> 'samples-custom-table-pager',
	            ),
	         )
	    );
	}	
}
