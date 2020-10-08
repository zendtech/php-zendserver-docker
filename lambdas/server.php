<?php
/**
 * If you change this file, the server needs to be restarted
 *
 * Requests that we expect here are something like:
 *
 * POST - http://lambda:9501/post/function-name (with simple string data in POST payload)
 * GET  - http://lambda:9501/get/function-name?param=one&param-two&etc
 * HEAD - http://lambda:9501/head/function-name
 *
 * These requests would refer to the file function-name.function.php in the same directory
 *
 * */

$server = new Swoole\Http\Server("0.0.0.0", 9501);
$server->set(['worker_num' => 3]);

$server->on('request', 
    function (Swoole\Http\Request $request, Swoole\Http\Response $response) use ($server) {
        // The whole 'action' logic makes no sense - HTTP verb would be enough. Adding it because we can.
        $action = explode('/', $request->server['request_uri']);

        if ($request->server['request_method'] == 'POST') {
            // POST
            if ($action[1] != 'post') {
                $response->status('400');
                $response->end("Surprised by this action: '{$action[1]}'. \nWe were expecting 'post'. \nHTTP 400");
                return;
            } else if ($request->header['content-type'] != 'application/json') {
                $response->status('406');
                $response->end("Expecting explicit content type 'application/json' in a POST request. \nHTTP 406");
                return;
            } else {
                $call_data = $request->rawContent();
            }
        } else if ($request->server['request_method'] == 'GET') {
            // GET
            if ($action[1] != 'get') {
                $response->status('400');
                $response->end("Surprised by this action: '{$action[1]}'. \nWe were expecting 'get'. \nHTTP 400");
                return;
            } else {
                $call_params = $request->get;
            }
        } else if ($request->server['request_method'] == 'HEAD') {
            // HEAD
            if (file_exists($action[2] . '.function.php')) {
                $response->status('200');
            } else {
                $response->status('404');
            }
            $response->end('');
            return;
        } else {
            // neither of POST, GET or HEAD
            $response->status('400');
            $response->end("Unexpected method. \nWe only like GET or POST... well, also HEAD, but that's it. \nHTTP 400");
            return;
        }

        // if POST then the included file can use the    string $call_data
        // if GET then the included file can use the     array  $call_params
        include $action[2] . '.function.php';
    }
);

$server->start();
