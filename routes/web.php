<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/env', function () {
    return env('APP_KEY');
});

Route::get('/hello', function () {
    return 'Hello World!';
});
