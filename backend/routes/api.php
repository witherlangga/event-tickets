
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\EventController;
use App\Http\Controllers\TicketCategoryController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\CheckInController;
use App\Http\Controllers\TransactionController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware(['auth:sanctum', 'role:admin'])->get('/admin-only', function (Request $request) {
    return response()->json(['message' => 'Hello Admin', 'user' => $request->user()]);
});

Route::middleware(['auth:sanctum', 'role:organizer'])->get('/organizer-only', function (Request $request) {
    return response()->json(['message' => 'Hello Organizer', 'user' => $request->user()]);
});

Route::middleware(['auth:sanctum', 'role:customer'])->get('/customer-only', function (Request $request) {
    return response()->json(['message' => 'Hello Customer', 'user' => $request->user()]);
});


// Endpoint booking tiket (hanya customer)
// Sudah didefinisikan di bawah, tidak perlu dua kali

// Route default user
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// AUTH
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);

// EVENT
Route::get('/events', [EventController::class, 'index']);
Route::get('/events/{id}', [EventController::class, 'show']);

// TICKET CATEGORY
Route::get('/events/{event_id}/ticket-categories', [TicketCategoryController::class, 'index']);

// BOOKING
Route::middleware(['auth:sanctum', 'role:customer'])->post('/book', [BookingController::class, 'book']);
Route::middleware('auth:sanctum')->get('/my-tickets', [BookingController::class, 'myTickets']);
Route::middleware('auth:sanctum')->get('/my-tickets/{id}', [BookingController::class, 'ticketDetail']);

// CHECK-IN
Route::middleware('auth:sanctum')->post('/check-in', [CheckInController::class, 'scan']);

// TRANSACTION
Route::middleware('auth:sanctum')->get('/transactions', [TransactionController::class, 'index']);
Route::middleware('auth:sanctum')->get('/transactions/{id}', [TransactionController::class, 'show']);

// PROFILE
Route::middleware('auth:sanctum')->get('/profile', [AuthController::class, 'profile']);
Route::middleware('auth:sanctum')->put('/profile', [AuthController::class, 'updateProfile']);

// TEST ROUTE
Route::get('/test', function () {
    return response()->json(['message' => 'API works!']);
});