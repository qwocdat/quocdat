/*
 * DIGITALSMOD TTS ENGINE
 *
 * Lớp này tách UI khỏi model.
 *
 * UI không cần biết model chạy bằng:
 *
 * WebGPU
 * WASM
 * ONNX Runtime Web
 *
 * Chỉ cần:
 *
 * engine.load()
 * engine.synthesize(text, options)
 */

class TTSEngine {

    constructor() {
        this.ready = false;
        this.backend = null;
    }

    async load() {

        /*
         * Kiểm tra WebGPU
         */

        if ("gpu" in navigator) {

            try {

                const adapter =
                    await navigator.gpu.requestAdapter();

                if (adapter) {
                    this.backend = "webgpu";
                }

            } catch {}
        }

        /*
         * Fallback
         */

        if (!this.backend)
            this.backend = "wasm";

        /*
         * TODO:
         *
         * Khi artifact browser của Korva/Supertonic
         * được xác định:
         *
         * 1. lấy model từ modelLoader
         * 2. tạo ONNX Runtime session
         * 3. load text encoder
         * 4. load decoder
         * 5. load voice style
         */

        this.ready = true;

        return {
            backend: this.backend
        };
    }

    async synthesize(text, options = {}) {

        if (!this.ready)
            throw new Error(
                "TTS engine chưa được khởi tạo."
            );

        if (!text?.trim())
            throw new Error(
                "Chưa nhập nội dung."
            );

        /*
         * Chưa giả lập audio ở đây.
         *
         * Không tạo WAV rỗng rồi gọi đó là AI TTS.
         */

        throw new Error(
            "Browser model adapter chưa được kết nối."
        );
    }
}

window.ttsEngine =
    new TTSEngine();
