package com.silentcut.silentcut

import android.content.Context
import android.util.Log
import java.io.File
import java.io.FileOutputStream

class WhisperModelLoader(private val context: Context) {
    
    companion object {
        private const val TAG = "WhisperModelLoader"
        private const val MODEL_FILENAME = "ggml-base.en.bin"
    }
    
    fun loadModelFromAssets(): File? {
        return try {
            val modelFile = File(context.filesDir, MODEL_FILENAME)
            
            if (modelFile.exists()) {
                Log.d(TAG, "Model already exists at ${modelFile.absolutePath}")
                return modelFile
            }
            
            // Copy from assets
            context.assets.open(MODEL_FILENAME).use { input ->
                FileOutputStream(modelFile).use { output ->
                    input.copyTo(output)
                }
            }
            
            Log.d(TAG, "Model copied to ${modelFile.absolutePath}")
            modelFile
        } catch (e: Exception) {
            Log.e(TAG, "Error loading model", e)
            null
        }
    }
    
    fun isModelAvailable(): Boolean {
        return File(context.filesDir, MODEL_FILENAME).exists()
    }
    
    fun getModelPath(): String? {
        val modelFile = File(context.filesDir, MODEL_FILENAME)
        return if (modelFile.exists()) modelFile.absolutePath else null
    }
}
