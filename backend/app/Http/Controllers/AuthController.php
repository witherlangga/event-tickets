<?php
namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Organizer;
use App\Models\Log;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // Ambil profil user (termasuk organizer jika ada)
    public function profile(Request $request)
    {
        $user = $request->user();
        $user->load('organizer');
        return response()->json(['user' => $user]);
    }

    // Update profil user (mendukung multipart avatar)
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $rules = [
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $user->id,
            'phone' => 'sometimes|string',
            'avatar' => 'sometimes|image|max:2048',
            'organization_name' => 'sometimes|string',
            'address' => 'sometimes|string',
            'contact_person' => 'sometimes|string',
            'contact_phone' => 'sometimes|string',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        if ($request->hasFile('avatar')) {
            $path = $request->file('avatar')->store('avatars', 'public');
            $user->avatar = $path;
        }

        if (isset($data['name'])) $user->name = $data['name'];
        if (isset($data['email'])) $user->email = $data['email'];
        if (array_key_exists('phone', $data)) $user->phone = $data['phone'];
        $user->save();

        if ($user->organizer) {
            $orgData = [];
            if (isset($data['organization_name'])) $orgData['organization_name'] = $data['organization_name'];
            if (isset($data['address'])) $orgData['address'] = $data['address'];
            if (isset($data['contact_person'])) $orgData['contact_person'] = $data['contact_person'];
            if (isset($data['contact_phone'])) $orgData['contact_phone'] = $data['contact_phone'];
            if (!empty($orgData)) $user->organizer->update($orgData);
        }

        $user->load('organizer');
        return response()->json(['user' => $user]);
    }

    // Register user (support role: admin, organizer, customer)
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'role' => 'required|in:admin,organizer,customer',
            'organization_name' => 'required_if:role,organizer|string|nullable',
            'address' => 'required_if:role,organizer|string|nullable',
            'phone' => 'sometimes|string|nullable',
        ], [
            'organization_name.required_if' => 'Nama organisasi wajib diisi untuk organizer.',
            'address.required_if' => 'Alamat wajib diisi untuk organizer.',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if ($request->role === 'admin' && User::where('role', 'admin')->exists()) {
            return response()->json(['message' => 'Admin sudah terdaftar.'], 403);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
            'phone' => $request->phone,
        ]);

        if ($request->hasFile('avatar')) {
            $path = $request->file('avatar')->store('avatars', 'public');
            $user->avatar = $path;
            $user->save();
        }

        if ($request->role === 'organizer') {
            Organizer::create([
                'user_id' => $user->id,
                'organization_name' => $request->organization_name ?? '',
                'address' => $request->address ?? '',
                'contact_person' => $request->input('contact_person', $user->name),
                'contact_phone' => $request->input('contact_phone', $request->phone ?? ''),
            ]);
        }

        Log::create([
            'user_id' => $user->id,
            'action' => 'register',
            'description' => 'User registered with role: ' . $user->role,
            'ip_address' => $request->ip(),
        ]);

        $token = $user->createToken('api-token')->plainTextToken;
        return response()->json(['user' => $user, 'token' => $token], 201);
    }

    // Register khusus customer
    public function registerCustomer(Request $request)
    {
        $request->merge(['role' => 'customer']);
        $request->request->remove('organization_name');
        $request->request->remove('address');
        return $this->register($request);
    }

    // Login
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
            'role' => 'sometimes|in:admin,organizer,customer',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = User::where('email', $request->email)->first();
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Email atau password salah'], 401);
        }

        if ($request->filled('role') && $user->role !== $request->role) {
            return response()->json(['message' => 'Role tidak sesuai.'], 403);
        }

        Log::create([
            'user_id' => $user->id,
            'action' => 'login',
            'description' => 'User login with role: ' . $user->role,
            'ip_address' => $request->ip(),
        ]);

        $token = $user->createToken('api-token')->plainTextToken;
        return response()->json(['user' => $user, 'token' => $token]);
    }

    // Login khusus customer
    public function loginCustomer(Request $request)
    {
        if (!$request->filled('role')) {
            $request->merge(['role' => 'customer']);
        }
        return $this->login($request);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out']);
    }
}
