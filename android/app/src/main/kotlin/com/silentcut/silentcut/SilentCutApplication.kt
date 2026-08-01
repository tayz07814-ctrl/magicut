package com.silentcut.silentcut

import io.flutter.app.FlutterApplication
import android.util.Log

class SilentCutApplication : FlutterApplication() {
    
    companion object {
        private const val TAG = "SilentCutApp"
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "SilentCut application started")
        
        // Initialize any global state here
    }
}
