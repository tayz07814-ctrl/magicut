package com.silentcut.silentcut

import android.content.Context
import android.util.Log

class WhisperTranscriber(private val context: Context) {
    
    companion object {
        private const val TAG = "WhisperTranscriber"
        
        init {
            System.loadLibrary("silentcut_lib")
        }
    }
    
    private var isModelLoaded = false
    
    /**
     * Initialize the Whisper model from the given path
     */
    fun initModel(modelPath: String): Boolean {
        Log.d(TAG, "Initializing model from $modelPath")
        isModelLoaded = nativeInitModel(modelPath)
        return isModelLoaded
    }
    
    /**
     * Transcribe an audio file and return JSON result
     */
    fun transcribe(audioPath: String): String? {
        if (!isModelLoaded) {
            Log.e(TAG, "Model not loaded")
            return null
        }
        
        Log.d(TAG, "Transcribing $audioPath")
        return nativeTranscribe(audioPath)
    }
    
    /**
     * Free the model resources
     */
    fun freeModel() {
        Log.d(TAG, "Freeing model")
        nativeFreeModel()
        isModelLoaded = false
    }
    
    // Native methods
    private external fun nativeInitModel(modelPath: String): Boolean
    private external fun nativeTranscribe(audioPath: String): String
    private external fun nativeFreeModel()
}
