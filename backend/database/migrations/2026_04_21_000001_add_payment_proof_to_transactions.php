<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->string('proof_path')->nullable()->after('payment_reference');
            $table->timestamp('approved_at')->nullable()->after('paid_at');
            $table->unsignedBigInteger('approved_by')->nullable()->after('approved_at');
            $table->foreign('approved_by')->references('id')->on('users')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            if (Schema::hasColumn('transactions', 'approved_by')) {
                $table->dropForeign(['approved_by']);
                $table->dropColumn('approved_by');
            }
            if (Schema::hasColumn('transactions', 'approved_at')) {
                $table->dropColumn('approved_at');
            }
            if (Schema::hasColumn('transactions', 'proof_path')) {
                $table->dropColumn('proof_path');
            }
        });
    }
};
