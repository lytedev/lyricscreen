<?php 

// If you're hosting this on a PHP webserver, we can let PHP handle the
// routing!

if (!isset($_GET['q'])) {
  $_GET['q'] = 'kill_me';
}

$_GET['q'] = trim(strtolower($_GET['q']), " \t\n\r\0\x0B/");

if ($_GET['q'] == "display") {
  include('display.html');
} elseif ($_GET['q'] == "console") {
  include('console.html');
} else {
  echo "Coming soon!";
}

