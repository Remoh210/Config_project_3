<?php
if( !isset($_POST['email']) ) error();
if( !isset($_POST['password']) ) error();
function error(){
    header('HTTP/1.1 400 Bad Request');
    exit();
}
define('LICENSE_PREFFIX', 'CNDP3');
define('LICENSE_SERIAL', 'BONDARENKOBOGDAN');


$email = $_POST['email'];
$password = $_POST['password'];

echo getLicense($email, $password);

function getLicense($email, $password) {
    $hardcodedValidUsers = [
        'bogdan@mail.com' => 'superpassword123',
        'oscar@mail.com' => 'superpassword321',
    ];
    if( !array_key_exists($email, $hardcodedValidUsers) ){
        return 'INVALID';
    }
    if( $hardcodedValidUsers[$email] != $password ){
        return 'INVALID';
    }
    return LICENSE_PREFFIX . LICENSE_SERIAL;
}