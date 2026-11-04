<?php
// Variabel opsional: $pageTitle, $active
require_once __DIR__ . '/auth.php';
require_login();
require_once __DIR__ . '/actions.php'; // proses formulir (POST) sebelum ada output HTML
$user   = current_user();
$alerts = budget_alerts(db(), (int) $user['id']);
$initial = mb_strtoupper(mb_substr($user['name'], 0, 1));
include __DIR__ . '/head.php';
?>
<body class="bg-paper text-forest font-sans antialiased">
<a href="#konten" class="sr-only focus:not-sr-only focus:absolute focus:z-50 focus:m-3 focus:rounded-xl focus:bg-forest focus:px-4 focus:py-2 focus:text-white">Lewati ke konten</a>
<div class="min-h-screen lg:flex">
    <?php include __DIR__ . '/sidebar.php'; ?>
    <div class="flex-1 min-w-0 pb-24 lg:pb-0">
        <header class="sticky top-0 z-20 flex items-center gap-3 bg-paper/90 px-4 py-3 backdrop-blur sm:px-6 lg:px-8">
            <a href="<?= h(app_url('pages/dashboard.php')) ?>" class="flex items-center gap-2 lg:hidden">
                <?= logo_mark('w-8 h-8') ?>
            </a>
            <div class="ml-auto flex items-center gap-2">
                <div class="relative">
                    <button type="button" class="icon-btn relative bg-white border border-forest/10" data-dropdown-toggle="dd-notif" aria-label="Notifikasi anggaran" aria-expanded="false">
                        <?= icon('bell', 'w-5 h-5') ?>
                        <?php if ($alerts): ?><span class="absolute right-2 top-2 h-2 w-2 rounded-full bg-expense"></span><?php endif; ?>
                    </button>
                    <div id="dd-notif" class="dropdown hidden w-80" role="menu">
                        <p class="px-4 pt-3 pb-2 font-display font-bold">Peringatan anggaran</p>
                        <?php if (!$alerts): ?>
                            <p class="px-4 pb-4 text-sm text-forest/60">Semua anggaran masih aman bulan ini.</p>
                        <?php else: foreach ($alerts as $a): ?>
                            <a href="<?= h(app_url('pages/budgets.php')) ?>" class="flex items-start gap-3 px-4 py-3 hover:bg-sage-50">
                                <span class="mt-1 h-2.5 w-2.5 shrink-0 rounded-full <?= status_class($a['status']) ?>"></span>
                                <span class="text-sm">
                                    <strong><?= h($a['category']) ?></strong>
                                    <?= $a['over'] > 0 ? 'melebihi limit ' . h(rupiah($a['over'])) : 'sudah ' . (int) round($a['pct']) . '% terpakai' ?>
                                </span>
                            </a>
                        <?php endforeach; endif; ?>
                    </div>
                </div>

                <div class="relative">
                    <button type="button" class="flex items-center gap-2 rounded-full border border-forest/10 bg-white py-1 pl-1 pr-3" data-dropdown-toggle="dd-profile" aria-expanded="false">
                        <span class="flex h-8 w-8 items-center justify-center rounded-full bg-forest font-display text-sm font-bold text-sage"><?= h($initial) ?></span>
                        <span class="hidden text-sm font-semibold sm:block max-w-[8rem] truncate"><?= h($user['name']) ?></span>
                        <?= icon('chevron-down', 'w-4 h-4 text-forest/50') ?>
                    </button>
                    <div id="dd-profile" class="dropdown hidden w-56" role="menu">
                        <div class="border-b border-forest/10 px-4 py-3">
                            <p class="font-semibold truncate"><?= h($user['name']) ?></p>
                            <p class="text-xs text-forest/60 truncate"><?= h($user['email']) ?></p>
                        </div>
                        <a href="<?= h(app_url('pages/profile.php')) ?>" class="dd-item"><?= icon('settings', 'w-4 h-4') ?> Pengaturan</a>
                        <a href="<?= h(app_url('auth/logout.php')) ?>" class="dd-item text-expense"><?= icon('logout', 'w-4 h-4') ?> Keluar</a>
                    </div>
                </div>
            </div>
        </header>
        <main id="konten" class="px-4 pb-10 sm:px-6 lg:px-8">
