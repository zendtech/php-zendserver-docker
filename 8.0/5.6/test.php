<?php

#$arr[ZEND_BOOTSTRAP_PRODUCTION] = boolval($arr[ZEND_BOOTSTRAP_PRODUCTION]);
#$wak="0";

if(isset($wak)) $wak=boolval($wak);

#$wak=isset($wak) ? boolval($wak) : 'unset';
var_dump($wak);


            if(isset($arr['ZEND_BOOTSTRAP_PRODUCTION'])) $arr['ZEND_BOOTSTRAP_PRODUCTION']=boolval($arr['ZEND_BOOTSTRAP_PRODUCTION']);
            if(isset($arr['ZEND_DEBUG'])) $arr['ZEND_DEBUG']=boolval($arr['ZEND_DEBUG']);
