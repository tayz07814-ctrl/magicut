#include <jni.h>
#include <string>
#include <vector>
#include <android/log.h>

#define LOG_TAG "SilentCutJNI"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Whisper.cpp forward declarations (when integrated)
// #include "whisper.h"

extern "C" {

/**
 * Initialize Whisper model
 * @param env JNI environment
 * @param thiz Java object
 * @param modelPath Path to the Whisper model file
 * @return true if initialization successful
 */
JNIEXPORT jboolean JNICALL
Java_com_silentcut_silentcut_WhisperTranscriber_initModel(JNIEnv* env, jobject thiz, jstring modelPath) {
    LOGD("Initializing Whisper model");
    
    const char* path = env->GetStringUTFChars(modelPath, nullptr);
    LOGD("Model path: %s", path);
    
    // TODO: Initialize whisper_context with whisper_init_from_file(path, params)
    
    env->ReleaseStringUTFChars(modelPath, path);
    
    return JNI_TRUE;
}

/**
 * Transcribe audio file
 * @param env JNI environment
 * @param thiz Java object
 * @param audioPath Path to the audio file
 * @return JSON string with transcription results
 */
JNIEXPORT jstring JNICALL
Java_com_silentcut_silentcut_WhisperTranscriber_transcribe(JNIEnv* env, jobject thiz, jstring audioPath) {
    LOGD("Starting transcription");
    
    const char* path = env->GetStringUTFChars(audioPath, nullptr);
    LOGD("Audio path: %s", path);
    
    // TODO: Implement transcription using whisper_full()
    
    env->ReleaseStringUTFChars(audioPath, path);
    
    // Return placeholder result
    std::string result = R"({
        "segments": [
            {
                "id": 0,
                "start": 0.0,
                "end": 3.0,
                "text": "Sample transcription result",
                "words": [
                    {"word": "Sample", "start": 0.0, "end": 0.5},
                    {"word": "transcription", "start": 0.5, "end": 1.5},
                    {"word": "result", "start": 1.5, "end": 2.0}
                ]
            }
        ],
        "language": "en"
    })";
    
    return env->NewStringUTF(result.c_str());
}

/**
 * Free Whisper model resources
 */
JNIEXPORT void JNICALL
Java_com_silentcut_silentcut_WhisperTranscriber_freeModel(JNIEnv* env, jobject thiz) {
    LOGD("Freeing Whisper model");
    
    // TODO: Call whisper_free(ctx)
}

/**
 * Detect silence in audio using FFmpeg
 * This is a wrapper that calls FFmpeg command line
 */
JNIEXPORT jstring JNICALL
Java_com_silentcut_silentcut_VideoProcessor_detectSilenceNative(
    JNIEnv* env, jobject thiz, jstring videoPath, jdouble threshold, jint minDuration) {
    
    LOGD("Detecting silence in video");
    
    const char* path = env->GetStringUTFChars(videoPath, nullptr);
    LOGD("Video path: %s, threshold: %f, minDuration: %d", path, threshold, minDuration);
    
    env->ReleaseStringUTFChars(videoPath, path);
    
    // Return JSON array of silence segments
    std::string result = "[]";
    return env->NewStringUTF(result.c_str());
}

} // extern "C"
