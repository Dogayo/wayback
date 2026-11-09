package com.dogayo.wayback

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        openSharedTextAsImport(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        openSharedTextAsImport(intent)
        super.onNewIntent(intent)
    }

    /**
     * Text shared to the app becomes an ordinary deep link, so Flutter routes
     * it like any other and no platform channel is needed.
     */
    private fun openSharedTextAsImport(intent: Intent) {
        if (intent.action != Intent.ACTION_SEND) return
        val text = intent.getStringExtra(Intent.EXTRA_TEXT) ?: return
        intent.data = Uri.parse(IMPORT_LINK)
            .buildUpon()
            .appendQueryParameter(TEXT_PARAMETER, text.take(MAX_TEXT_LENGTH))
            .build()
    }

    private companion object {
        const val IMPORT_LINK = "wayback://app/import"
        const val TEXT_PARAMETER = "text"

        /** Far more than a point needs, far less than a link can carry. */
        const val MAX_TEXT_LENGTH = 2000
    }
}
