
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

Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':admin'])->get('/admin-only', function (Request $request) {
    return response()->json(['message' => 'Hello Admin', 'user' => $request->user()]);
});

Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':organizer'])->get('/organizer-only', function (Request $request) {
    return response()->json(['message' => 'Hello Organizer', 'user' => $request->user()]);
});

Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':customer'])->get('/customer-only', function (Request $request) {
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
// Convenience routes for customers
Route::post('/register/customer', [AuthController::class, 'registerCustomer']);
Route::post('/login/customer', [AuthController::class, 'loginCustomer']);
Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);

// EVENT
Route::get('/events', [EventController::class, 'index']);
Route::get('/events/{id}', [EventController::class, 'show']);
// Organizer CRUD accessible at top-level routes as tests expect
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':organizer'])->post('/events', [EventController::class, 'store']);
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':organizer'])->put('/events/{id}', [EventController::class, 'update']);
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':organizer'])->delete('/events/{id}', [EventController::class, 'destroy']);

// TICKET CATEGORY (public list)
Route::get('/events/{event_id}/ticket-categories', [TicketCategoryController::class, 'index']);
// Compat routes expected by tests: /events/{event_id}/categories for organizer CRUD
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':organizer'])->post('/events/{event_id}/categories', [\App\Http\Controllers\TicketCategoryController::class, 'store']);
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':organizer'])->put('/events/{event_id}/categories/{id}', [\App\Http\Controllers\TicketCategoryController::class, 'update']);
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':organizer'])->delete('/events/{event_id}/categories/{id}', [\App\Http\Controllers\TicketCategoryController::class, 'destroy']);

// BOOKING
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':customer'])->post('/book', [BookingController::class, 'book']);
Route::middleware('auth:sanctum')->get('/my-tickets', [BookingController::class, 'myTickets']);
Route::middleware('auth:sanctum')->get('/my-tickets/{id}', [BookingController::class, 'ticketDetail']);

// CHECK-IN
Route::middleware('auth:sanctum')->post('/check-in', [CheckInController::class, 'scan']);

// TRANSACTION
Route::middleware('auth:sanctum')->get('/transactions', [TransactionController::class, 'index']);
Route::middleware('auth:sanctum')->get('/transactions/{id}', [TransactionController::class, 'show']);
// Customer upload payment proof
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':customer'])->post('/transactions/{id}/upload-proof', [TransactionController::class, 'uploadProof']);

// PROFILE
Route::middleware('auth:sanctum')->get('/profile', [AuthController::class, 'profile']);
Route::middleware('auth:sanctum')->put('/profile', [AuthController::class, 'updateProfile']);

// ORGANIZER - Event CRUD (hanya organizer)
Route::prefix('organizer')->middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':organizer'])->group(function () {
    Route::get('/events', [EventController::class, 'organizerIndex']);
    Route::post('/events', [EventController::class, 'store']);
    Route::get('/events/{id}', [EventController::class, 'show']);
    Route::put('/events/{id}', [EventController::class, 'update']);
    Route::delete('/events/{id}', [EventController::class, 'destroy']);
    Route::post('/events/{id}/publish', [EventController::class, 'publish']);
    Route::get('/events/{id}/sales', [\App\Http\Controllers\TransactionController::class, 'organizerEventSales']);
    Route::get('/events/{event_id}/transactions', [\App\Http\Controllers\TransactionController::class, 'organizerEventTransactions']);
    // Ticket categories (organizer-only)
    Route::get('/events/{event_id}/ticket-categories', [\App\Http\Controllers\TicketCategoryController::class, 'index']);
    Route::post('/events/{event_id}/ticket-categories', [\App\Http\Controllers\TicketCategoryController::class, 'store']);
    Route::put('/events/{event_id}/ticket-categories/{id}', [\App\Http\Controllers\TicketCategoryController::class, 'update']);
    Route::delete('/events/{event_id}/ticket-categories/{id}', [\App\Http\Controllers\TicketCategoryController::class, 'destroy']);
    Route::put('/transactions/{id}/approve', [\App\Http\Controllers\TransactionController::class, 'approve']);
});

// TEST ROUTE
Route::get('/test', function () {
    return response()->json(['message' => 'API works!']);
});

// ADMIN routes
Route::prefix('admin')->middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':admin'])->group(function () {
    Route::get('/users', [\App\Http\Controllers\AdminController::class, 'users']);
    Route::put('/users/{id}/role', [\App\Http\Controllers\AdminController::class, 'updateUserRole']);
    Route::delete('/users/{id}', [\App\Http\Controllers\AdminController::class, 'deleteUser']);
    Route::get('/transactions', [\App\Http\Controllers\AdminController::class, 'transactions']);
    Route::post('/events/purge', [\App\Http\Controllers\AdminController::class, 'purgeEvents']);
    // Organizer management
    Route::get('/organizers', [\App\Http\Controllers\AdminController::class, 'organizers']);
    Route::put('/organizers/{id}', [\App\Http\Controllers\AdminController::class, 'updateOrganizer']);
    Route::delete('/organizers/{id}', [\App\Http\Controllers\AdminController::class, 'deleteOrganizer']);
});