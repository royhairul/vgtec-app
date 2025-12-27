package com.roaddetection.vgtec_app

import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class SecurityPlugin(private val context: Context) {
    companion object {
        private const val CHANNEL = "com.roaddetection.security"
    }

    fun registerWith(flutterEngine: FlutterEngine) {
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getSignature" -> {
                    val signature = getAppSignature()
                    result.success(signature)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getAppSignature(): String? {
        try {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNATURES
                )
            }

            val signatures: Array<Signature> = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.signingInfo?.apkContentsSigners ?: emptyArray()
            } else {
                @Suppress("DEPRECATION")
                packageInfo.signatures ?: emptyArray()
            }

            if (signatures.isEmpty()) return null

            val signature = signatures[0]
            val md = MessageDigest.getInstance("SHA1")
            md.update(signature.toByteArray())
            val digest = md.digest()

            val hexString = StringBuilder()
            for (byte in digest) {
                val hex = Integer.toHexString(0xFF and byte.toInt())
                if (hex.length == 1) {
                    hexString.append('0')
                }
                hexString.append(hex)
            }

            return "SHA1: ${hexString.toString().uppercase()}"
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }
}
