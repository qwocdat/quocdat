import {
    pipeline,
    env
} from "https://cdn.jsdelivr.net/npm/@huggingface/transformers@3.8.1/+esm";

/*
 * DIGITALSMOD TTS
 * Browser-only Supertonic TTS
 *
 * Không cần API key.
 * Không cần VPS.
 * Không cần backend.
 *
 * Model:
 * onnx-community/Supertonic-TTS-ONNX
 */

const MODEL_ID = "onnx-community/Supertonic-TTS-ONNX";

const VOICE_BASE =
    "https://huggingface.co/onnx-community/Supertonic-TTS-ONNX/resolve/main/voices/";

class TTSEngine {

    constructor() {

        this.pipe = null;

        this.ready = false;

        this.loading = false;

        this.backend = "unknown";

        this.currentVoice = null;

        this.onProgress = null;

        /*
         * Quan trọng:
         *
         * Transformers.js sẽ dùng Browser Cache API.
         * Vì vậy model không phải tải lại toàn bộ
         * mỗi lần mở trang.
         */
        env.allowRemoteModels = true;

        env.allowLocalModels = false;

        env.useBrowserCache = true;

        env.useWasmCache = true;

        /*
         * Cache riêng cho website này.
         */
        env.cacheKey = "digitalsmod-tts-cache-v1";

        /*
         * Giảm log không cần thiết.
         */
        if (env.LogLevel) {
            env.logLevel = env.LogLevel.ERROR;
        }
    }

    setProgress(callback) {
        this.onProgress = callback;
    }

    progress(data) {

        if (typeof this.onProgress !== "function") {
            return;
        }

        try {
            this.onProgress(data);
        } catch (error) {
            console.warn(
                "Progress callback error:",
                error
            );
        }
    }

    async detectBackend() {

        /*
         * Transformers.js hỗ trợ:
         *
         * WebGPU nếu browser hỗ trợ.
         * WASM nếu không có WebGPU.
         */

        if (
            typeof navigator !== "undefined" &&
            navigator.gpu
        ) {

            try {

                const adapter =
                    await navigator.gpu.requestAdapter();

                if (adapter) {
                    return "webgpu";
                }

            } catch (error) {

                console.warn(
                    "WebGPU detection failed:",
                    error
                );

            }
        }

        return "wasm";
    }

    async load() {

        if (this.ready && this.pipe) {
            return {
                backend: this.backend,
                cached: true
            };
        }

        if (this.loading) {

            while (this.loading) {
                await new Promise(
                    resolve => setTimeout(resolve, 100)
                );
            }

            if (this.ready && this.pipe) {
                return {
                    backend: this.backend,
                    cached: true
                };
            }
        }

        this.loading = true;

        try {

            this.progress({
                status: "loading",
                progress: 1,
                message: "Kiểm tra trình duyệt..."
            });

            this.backend =
                await this.detectBackend();

            this.progress({
                status: "loading",
                progress: 5,
                message:
                    this.backend === "webgpu"
                        ? "Đang dùng WebGPU..."
                        : "WebGPU không khả dụng, dùng WASM..."
            });

            /*
             * Transformers.js tự tải:
             *
             * - tokenizer
             * - ONNX models
             * - external ONNX data
             * - config
             *
             * và cache chúng trong Browser Cache.
             */

            this.pipe = await pipeline(
                "text-to-speech",
                MODEL_ID,
                {
                    device:
                        this.backend === "webgpu"
                            ? "webgpu"
                            : "wasm",

                    /*
                     * Supertonic model được tối ưu
                     * để chạy trong browser.
                     */
                    dtype:
                        this.backend === "webgpu"
                            ? "fp32"
                            : "q8",

                    progress_callback: (info) => {

                        let percent = 0;

                        if (
                            typeof info.progress ===
                            "number"
                        ) {
                            percent =
                                Math.max(
                                    0,
                                    Math.min(
                                        100,
                                        info.progress
                                    )
                                );
                        }

                        let file =
                            info.file ||
                            info.name ||
                            "";

                        if (file.length > 55) {
                            file =
                                file.slice(0, 52) +
                                "...";
                        }

                        this.progress({
                            status: "loading",
                            progress: percent,
                            message:
                                file
                                    ? `Đang tải ${file}`
                                    : "Đang tải model..."
                        });
                    }
                }
            );

            this.ready = true;

            this.progress({
                status: "ready",
                progress: 100,
                message:
                    "Model đã sẵn sàng."
            });

            return {
                backend: this.backend,
                cached: false
            };

        } catch (error) {

            this.ready = false;
            this.pipe = null;

            this.progress({
                status: "error",
                progress: 0,
                message:
                    error?.message ||
                    "Không thể tải model."
            });

            throw error;

        } finally {

            this.loading = false;
        }
    }

    getVoiceUrl(voice) {

        const allowed = [
            "F1",
            "F2",
            "F3",
            "F4",
            "F5",
            "M1",
            "M2",
            "M3",
            "M4",
            "M5"
        ];

        if (!allowed.includes(voice)) {
            throw new Error(
                `Voice không hợp lệ: ${voice}`
            );
        }

        return `${VOICE_BASE}${voice}.bin`;
    }

    async synthesize(
        text,
        options = {}
    ) {

        if (!this.ready || !this.pipe) {
            await this.load();
        }

        const cleanText =
            String(text || "").trim();

        if (!cleanText) {
            throw new Error(
                "Chưa nhập nội dung."
            );
        }

        if (cleanText.length > 5000) {
            throw new Error(
                "Nội dung tối đa 5000 ký tự."
            );
        }

        const voice =
            options.voice || "F1";

        const speed =
            Number(options.speed || 1.05);

        const steps =
            Number(
                options.steps || 5
            );

        const lang =
            options.lang || "vi";

        const speakerEmbeddings =
            this.getVoiceUrl(voice);

        this.progress({
            status: "generating",
            progress: 0,
            message:
                "Đang chuẩn bị giọng đọc..."
        });

        /*
         * Tách text thành các đoạn vừa phải.
         *
         * Việc này giúp điện thoại không bị ngốn RAM
         * khi người dùng paste cả một bài văn dài.
         */

        const chunks =
            this.splitText(
                cleanText,
                650
            );

        const audioParts = [];

        const total =
            chunks.length;

        for (
            let i = 0;
            i < total;
            i++
        ) {

            const chunk =
                chunks[i];

            this.progress({
                status: "generating",
                progress:
                    (i / total) * 100,
                message:
                    `Đang tạo đoạn ${i + 1}/${total}...`
            });

            const output =
                await this.pipe(
                    chunk,
                    {
                        speaker_embeddings,

                        num_inference_steps:
                            steps,

                        speed,

                        /*
                         * Supertonic hỗ trợ 31 ngôn ngữ,
                         * trong đó có Vietnamese.
                         */
                        language: lang
                    }
                );

            if (!output) {
                throw new Error(
                    "Model không trả về audio."
                );
            }

            audioParts.push(output);
        }

        this.progress({
            status: "generating",
            progress: 100,
            message:
                "Đang ghép audio..."
        });

        const finalAudio =
            this.mergeAudio(
                audioParts
            );

        const wavBlob =
            this.audioToWavBlob(
                finalAudio,
                44100
            );

        this.progress({
            status: "ready",
            progress: 100,
            message:
                "Đã tạo giọng nói."
        });

        return {
            blob: wavBlob,
            sampleRate: 44100,
            duration:
                finalAudio.length / 44100
        };
    }

    splitText(
        text,
        maxLength = 650
    ) {

        if (text.length <= maxLength) {
            return [text];
        }

        /*
         * Ưu tiên cắt theo:
         * .
         * !
         * ?
         * xuống dòng
         */
        const sentences =
            text
                .replace(
                    /\r\n/g,
                    "\n"
                )
                .split(
                    /(?<=[.!?。！？])\s+|\n+/
                )
                .map(
                    x => x.trim()
                )
                .filter(Boolean);

        const chunks = [];

        let current = "";

        for (
            const sentence of sentences
        ) {

            if (
                sentence.length >
                maxLength
            ) {

                if (current) {
                    chunks.push(
                        current
                    );

                    current = "";
                }

                for (
                    let i = 0;
                    i < sentence.length;
                    i += maxLength
                ) {

                    chunks.push(
                        sentence.slice(
                            i,
                            i + maxLength
                        )
                    );
                }

                continue;
            }

            const candidate =
                current
                    ? `${current} ${sentence}`
                    : sentence;

            if (
                candidate.length >
                maxLength
            ) {

                if (current) {
                    chunks.push(
                        current
                    );
                }

                current = sentence;

            } else {

                current = candidate;

            }
        }

        if (current) {
            chunks.push(
                current
            );
        }

        return chunks.length
            ? chunks
            : [text];
    }

    mergeAudio(parts) {

        if (!parts.length) {
            throw new Error(
                "Không có audio để ghép."
            );
        }

        const arrays =
            parts.map(
                part => {

                    if (
                        part.audio &&
                        typeof part.audio.length ===
                        "number"
                    ) {
                        return part.audio;
                    }

                    if (
                        part instanceof Float32Array
                    ) {
                        return part;
                    }

                    if (
                        ArrayBuffer.isView(part)
                    ) {
                        return new Float32Array(
                            part.buffer,
                            part.byteOffset,
                            part.byteLength /
                            Float32Array.BYTES_PER_ELEMENT
                        );
                    }

                    throw new Error(
                        "Định dạng audio không hợp lệ."
                    );
                }
            );

        /*
         * Khoảng nghỉ 0.18 giây giữa các chunk.
         */
        const silenceLength =
            Math.floor(
                44100 * 0.18
            );

        const totalLength =
            arrays.reduce(
                (sum, arr) =>
                    sum + arr.length,
                0
            ) +
            silenceLength *
            Math.max(
                0,
                arrays.length - 1
            );

        const output =
            new Float32Array(
                totalLength
            );

        let offset = 0;

        for (
            let i = 0;
            i < arrays.length;
            i++
        ) {

            output.set(
                arrays[i],
                offset
            );

            offset +=
                arrays[i].length;

            if (
                i <
                arrays.length - 1
            ) {
                offset +=
                    silenceLength;
            }
        }

        return output;
    }

    audioToWavBlob(
        audio,
        sampleRate
    ) {

        /*
         * PCM 16-bit mono WAV
         */

        const numChannels = 1;
        const bitsPerSample = 16;

        const bytesPerSample =
            bitsPerSample / 8;

        const dataSize =
            audio.length *
            bytesPerSample;

        const buffer =
            new ArrayBuffer(
                44 + dataSize
            );

        const view =
            new DataView(buffer);

        this.writeString(
            view,
            0,
            "RIFF"
        );

        view.setUint32(
            4,
            36 + dataSize,
            true
        );

        this.writeString(
            view,
            8,
            "WAVE"
        );

        this.writeString(
            view,
            12,
            "fmt "
        );

        view.setUint32(
            16,
            16,
            true
        );

        view.setUint16(
            20,
            1,
            true
        );

        view.setUint16(
            22,
            numChannels,
            true
        );

        view.setUint32(
            24,
            sampleRate,
            true
        );

        view.setUint32(
            28,
            sampleRate *
            numChannels *
            bytesPerSample,
            true
        );

        view.setUint16(
            32,
            numChannels *
            bytesPerSample,
            true
        );

        view.setUint16(
            34,
            bitsPerSample,
            true
        );

        this.writeString(
            view,
            36,
            "data"
        );

        view.setUint32(
            40,
            dataSize,
            true
        );

        let offset = 44;

        for (
            let i = 0;
            i < audio.length;
            i++
        ) {

            let sample =
                Number(audio[i]);

            if (!Number.isFinite(sample)) {
                sample = 0;
            }

            sample =
                Math.max(
                    -1,
                    Math.min(
                        1,
                        sample
                    )
                );

            const pcm =
                sample < 0
                    ? sample * 32768
                    : sample * 32767;

            view.setInt16(
                offset,
                pcm,
                true
            );

            offset += 2;
        }

        return new Blob(
            [buffer],
            {
                type: "audio/wav"
            }
        );
    }

    writeString(
        view,
        offset,
        string
    ) {

        for (
            let i = 0;
            i < string.length;
            i++
        ) {

            view.setUint8(
                offset + i,
                string.charCodeAt(i)
            );
        }
    }
}

export {
    TTSEngine,
    MODEL_ID
};
