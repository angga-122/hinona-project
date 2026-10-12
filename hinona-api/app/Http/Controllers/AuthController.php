<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // DEBUG SEMENTARA: tulis ke file sendiri (hapus kalau login sudah beres)
                // DEBUG SEMENTARA: hapus kalau login sudah beres
        file_put_contents(
            base_path('debug_login.txt'),
            date('H:i:s') . ' | email=[' . $data['email'] . ']'
                . ' | password_hex=' . bin2hex($data['password'])
                . ' | cocok=' . (Hash::check($data['password'], optional(User::where('email', $data['email'])->first())->password ?? '') ? 'YA' : 'TIDAK')
                . PHP_EOL,
            FILE_APPEND
        );

        $user = User::where('email', $data['email'])->first();

        if (!$user || !Hash::check($data['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah',
            ], 401);
        }

        $token = $user->createToken('hinona-pos')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                ],
                'token' => $token,
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
        ]);
    }
}