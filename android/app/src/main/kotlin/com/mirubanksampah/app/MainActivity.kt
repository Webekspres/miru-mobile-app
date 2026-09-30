package com.mirubanksampah.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android 12+: hilangkan animasi fade-out native splash supaya handoff
        // ke Flutter SplashScreen (logo penuh) tidak berkedip / terlewat.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splashScreenView ->
                splashScreenView.remove()
            }
        }
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    /** Channel prioritas tinggi supaya push MIRU muncul sebagai popup (heads-up). */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            "miru_utama",
            "Info penting MIRU",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Status penjemputan, saldo, penarikan, dan jadwal jemput"
            enableVibration(true)
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }
}
