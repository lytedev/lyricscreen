<?php 

// If you're hosting this on a PHP webserver, we can let PHP handle the
// routing!

if (!isset($_GET['q'])) {
  $_GET['q'] = 'display';
}

$_GET['q'] = strtolower($_GET['q']);

if ($_GET['q'] == "display") {
  include('display.html');
} elseif ($_GET['q'] == "console") {
  include('console.html');
} else {
  echo "Coming soon!";
}

