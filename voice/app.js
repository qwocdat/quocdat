"use strict";

/*
 * V-TTS Browser ONNX
 * Vietnamese Text-to-Speech
 *
 * Pipeline:
 *
 * Text
 *  ↓
 * Vietnamese G2P
 *  ↓
 * Text Encoder
 *  ↓
 * Duration Predictor
 *  ↓
 * Flow
 *  ↓
 * Decoder
 *  ↓
 * WAV
 */


const MODEL_URL =
    "https://huggingface.co/letrggghieu/v-tts-onnx/resolve/main/";


const MODEL_SIZE_TEXT = "~165 MB";


let textEncoder = null;
let durationPredictor = null;
let flow = null;
let decoder = null;

let ttsConfig = null;

let modelReady = false;

let currentAudioURL = null;


/* =========================================================
   DOM
========================================================= */

const $ = (id) => document.getElementById(id);


const statusDot = $("statusDot");
const statusText = $("statusText");

const progress = $("progress");
const progressBar = $("progressBar");

const textInput = $("text");
const speakerInput = $("speaker");
const speedInput = $("speed");
const speedValue = $("speedValue");

const generateBtn = $("generateBtn");

const loading = $("loading");
const loadingText = $("loadingText");

const message = $("message");

const result = $("result");
const audio = $("audio");
const download = $("download");


/* =========================================================
   ONNX Runtime configuration
========================================================= */

if (typeof ort !== "undefined") {

    /*
     * ONNX Runtime Web WASM files.
     *
     * Keeping these on jsDelivr makes the GitHub repository
     * smaller and avoids manually uploading runtime binaries.
     */

    ort.env.wasm.wasmPaths =
        "https://cdn.jsdelivr.net/npm/onnxruntime-web@1.17.0/dist/";

    ort.env.logLevel = "warning";
}


/* =========================================================
   UI helpers
========================================================= */

function setStatus(text, state = "loading") {

    statusText.textContent = text;

    statusDot.className = "dot";

    if (state === "ready") {
        statusDot.classList.add("ready");
    }

    if (state === "error") {
        statusDot.classList.add("error");
    }
}


function setProgress(value) {

    const safeValue =
        Math.max(0, Math.min(100, value));

    progressBar.style.width =
        safeValue + "%";
}


function setLoading(text) {

    loadingText.textContent = text;
}


function showMessage(text, type = "success") {

    message.textContent = text;

    message.className =
        "message show " + type;
}


function hideMessage() {

    message.className =
        "message";
}


function sleep(ms) {

    return new Promise(resolve =>
        setTimeout(resolve, ms)
    );
}


/* =========================================================
   Speed
========================================================= */

speedInput.addEventListener("input", () => {

    const value =
        Number(speedInput.value);

    speedValue.textContent =
        value.toFixed(2) + "x";
});


/* =========================================================
   Load one ONNX model
========================================================= */

async function loadSession(filename) {

    const url =
        MODEL_URL + filename;

    return await ort.InferenceSession.create(
        url,
        {
            executionProviders: ["wasm"],

            graphOptimizationLevel:
                "all"
        }
    );
}


/* =========================================================
   Load all models
========================================================= */

async function loadModels() {

    if (typeof ort === "undefined") {

        setStatus(
            "Không tải được ONNX Runtime Web",
            "error"
        );

        showMessage(
            "Không tìm thấy ONNX Runtime Web.",
            "error"
        );

        return;
    }


    if (
        typeof VietnameseG2P === "undefined"
    ) {

        setStatus(
            "Không tải được Vietnamese G2P",
            "error"
        );

        showMessage(
            "Không tải được bộ chuyển tiếng Việt sang phoneme.",
            "error"
        );

        return;
    }


    try {

        generateBtn.disabled = true;

        progress.classList.remove("hidden");


        /* -------------------------------------------------
           Text Encoder
        ------------------------------------------------- */

        setStatus(
            "Đang tải Text Encoder..."
        );

        setProgress(10);

        textEncoder =
            await loadSession(
                "text_encoder.onnx"
            );


        /* -------------------------------------------------
           Duration Predictor
        ------------------------------------------------- */

        setStatus(
            "Đang tải Duration Predictor..."
        );

        setProgress(30);

        durationPredictor =
            await loadSession(
                "duration_predictor.onnx"
            );


        /* -------------------------------------------------
           Flow
        ------------------------------------------------- */

        setStatus(
            "Đang tải Flow model..."
        );

        setProgress(55);

        flow =
            await loadSession(
                "flow.onnx"
            );


        /* -------------------------------------------------
           Decoder
        ------------------------------------------------- */

        setStatus(
            "Đang tải Audio Decoder..."
        );

        setProgress(75);

        decoder =
            await loadSession(
                "decoder.onnx"
            );


        /* -------------------------------------------------
           Config
        ------------------------------------------------- */

        setStatus(
            "Đang tải cấu hình..."
        );

        setProgress(90);

        const response =
            await fetch(
                MODEL_URL + "tts_config.json",
                {
                    cache: "force-cache"
                }
            );


        if (!response.ok) {

            throw new Error(
                "Không tải được tts_config.json"
            );
        }


        ttsConfig =
            await response.json();


        setProgress(100);

        await sleep(300);


        modelReady = true;

        progress.classList.add("hidden");

        generateBtn.disabled = false;


        setStatus(
            `Model sẵn sàng • ${MODEL_SIZE_TEXT}`,
            "ready"
        );


        showMessage(
            "V-TTS đã sẵn sàng. Có thể tạo giọng nói.",
            "success"
        );


    } catch (error) {

        console.error(
            "V-TTS model loading error:",
            error
        );


        modelReady = false;

        generateBtn.disabled = true;

        setStatus(
            "Lỗi tải model",
            "error"
        );


        showMessage(
            getReadableError(error),
            "error"
        );
    }
}


/* =========================================================
   Error message
========================================================= */

function getReadableError(error) {

    const raw =
        error?.message ||
        String(error);


    if (
        raw.includes("fetch") ||
        raw.includes("Failed")
    ) {

        return (
            "Không tải được model. " +
            "Kiểm tra Internet hoặc thử tải lại trang."
        );
    }


    if (
        raw.includes("WebAssembly") ||
        raw.includes("wasm")
    ) {

        return (
            "Trình duyệt không hỗ trợ WebAssembly cần thiết."
        );
    }


    return "Lỗi V-TTS: " + raw;
}


/* =========================================================
   Vietnamese G2P
========================================================= */

function textToPhonemes(text) {

    if (
        !ttsConfig ||
        !ttsConfig.symbol_to_id
    ) {

        throw new Error(
            "Thiếu tts_config.json"
        );
    }


    if (
        !ttsConfig.language_id_map ||
        typeof ttsConfig.language_id_map.VI ===
            "undefined"
    ) {

        throw new Error(
            "Không tìm thấy VI language ID"
        );
    }


    const symbolToId =
        ttsConfig.symbol_to_id;


    const viLanguageId =
        ttsConfig.language_id_map.VI;


    const result =
        VietnameseG2P.textToPhonemes(
            text,
            symbolToId,
            viLanguageId
        );


    return VietnameseG2P.addBlanks(
        result,
        viLanguageId
    );
}


/* =========================================================
   Create int64 tensor
========================================================= */

function createInt64Tensor(
    values,
    dims
) {

    const data =
        new BigInt64Array(
            values.length
        );


    for (
        let i = 0;
        i < values.length;
        i++
    ) {

        data[i] =
            BigInt(values[i]);
    }


    return new ort.Tensor(
        "int64",
        data,
        dims
    );
}


/* =========================================================
   Main synthesis
========================================================= */

async function synthesize() {

    if (!modelReady) {

        showMessage(
            "Model chưa sẵn sàng.",
            "error"
        );

        return;
    }


    const text =
        textInput.value.trim();


    if (!text) {

        showMessage(
            "Vui lòng nhập văn bản.",
            "error"
        );

        return;
    }


    if (text.length > 3000) {

        showMessage(
            "Văn bản tối đa 3000 ký tự.",
            "error"
        );

        return;
    }


    hideMessage();


    generateBtn.disabled = true;

    loading.classList.add("show");

    result.classList.remove("show");


    try {

        /* -------------------------------------------------
           Step 1
        ------------------------------------------------- */

        setLoading(
            "Bước 1/4 • Phân tích tiếng Việt..."
        );


        await sleep(30);


        const g2p =
            textToPhonemes(text);


        const phonemes =
            g2p.phonemes;

        const tones =
            g2p.tones;

        const languages =
            g2p.languages;


        const seqLen =
            phonemes.length;


        if (seqLen <= 0) {

            throw new Error(
                "Không tạo được phoneme từ văn bản."
            );
        }


        console.log(
            "V-TTS phoneme length:",
            seqLen
        );


        /* -------------------------------------------------
           Step 2
        ------------------------------------------------- */

        setLoading(
            "Bước 2/4 • Encoding văn bản..."
        );


        const phoneIds =
            createInt64Tensor(
                phonemes,
                [1, seqLen]
            );


        const phoneLengths =
            createInt64Tensor(
                [seqLen],
                [1]
            );


        const toneIds =
            createInt64Tensor(
                tones,
                [1, seqLen]
            );


        const languageIds =
            createInt64Tensor(
                languages,
                [1, seqLen]
            );


        /*
         * The published browser pipeline expects
         * empty BERT / JA-BERT feature tensors.
         */

        const bert =
            new ort.Tensor(
                "float32",
                new Float32Array(
                    1024 * seqLen
                ),
                [1, 1024, seqLen]
            );


        const jaBert =
            new ort.Tensor(
                "float32",
                new Float32Array(
                    768 * seqLen
                ),
                [1, 768, seqLen]
            );


        const speakerId =
            Number(
                speakerInput.value
            );


        const speaker =
            createInt64Tensor(
                [speakerId],
                [1]
            );


        const encoderOutput =
            await textEncoder.run({

                phone_ids:
                    phoneIds,

                phone_lengths:
                    phoneLengths,

                tone_ids:
                    toneIds,

                language_ids:
                    languageIds,

                bert:
                    bert,

                ja_bert:
                    jaBert,

                speaker_id:
                    speaker
            });


        const xEncoded =
            encoderOutput.x_encoded;


        const mP =
            encoderOutput.m_p;


        const logsP =
            encoderOutput.logs_p;


        const xMask =
            encoderOutput.x_mask;


        const g =
            encoderOutput.g;


        /* -------------------------------------------------
           Step 3
        ------------------------------------------------- */

        setLoading(
            "Bước 3/4 • Tính thời lượng giọng..."
        );


        const durationOutput =
            await durationPredictor.run({

                x:
                    xEncoded,

                x_mask:
                    xMask,

                g:
                    g
            });


        const logw =
            durationOutput.logw;


        const logwData =
            logw.data;


        const maskData =
            xMask.data;


        const durations =
            [];


        let totalFrames = 0;


        for (
            let i = 0;
            i < logwData.length;
            i++
        ) {

            const mask =
                Number(maskData[i]);


            let duration =
                Math.ceil(
                    Math.exp(
                        Number(logwData[i])
                    ) * mask
                );


            /*
             * Prevent zero-duration tokens.
             */

            if (mask > 0) {

                duration =
                    Math.max(
                        1,
                        duration
                    );

            } else {

                duration = 0;

            }


            durations.push(
                duration
            );


            totalFrames +=
                duration;
        }


        if (totalFrames <= 0) {

            throw new Error(
                "Duration predictor trả về 0 frame."
            );
        }


        /*
         * Safety limit.
         *
         * Prevent accidental huge browser allocations.
         */

        if (totalFrames > 12000) {

            throw new Error(
                "Văn bản quá dài đối với trình duyệt. " +
                "Hãy chia nhỏ nội dung."
            );
        }


        /* -------------------------------------------------
           Expand m_p / logs_p
        ------------------------------------------------- */

        const mPData =
            mP.data;


        const logsPData =
            logsP.data;


        const channels =
            mP.dims[1];


        const expandedMP =
            new Float32Array(
                channels * totalFrames
            );


        const expandedLogsP =
            new Float32Array(
                channels * totalFrames
            );


        let frameIndex = 0;


        for (
            let token = 0;
            token < durations.length;
            token++
        ) {

            const duration =
                durations[token];


            for (
                let d = 0;
                d < duration;
                d++
            ) {

                for (
                    let channel = 0;
                    channel < channels;
                    channel++
                ) {

                    const sourceIndex =
                        channel * seqLen +
                        token;


                    const targetIndex =
                        channel * totalFrames +
                        frameIndex;


                    expandedMP[targetIndex] =
                        mPData[sourceIndex];


                    expandedLogsP[targetIndex] =
                        logsPData[sourceIndex];
                }


                frameIndex++;
            }
        }


        /*
         * Sample latent representation.
         */

        const zP =
            new Float32Array(
                channels * totalFrames
            );


        const noiseScale =
            0.667;


        for (
            let i = 0;
            i < zP.length;
            i++
        ) {

            const noise =
                (
                    Math.random() * 2 - 1
                ) * noiseScale;


            zP[i] =
                expandedMP[i] +
                Math.exp(
                    expandedLogsP[i]
                ) * noise;
        }


        /*
         * Apply speed.
         *
         * In this VITS pipeline,
         * duration is the timing control.
         *
         * > 1 = slower
         * < 1 = faster
         */

        const speed =
            Number(
                speedInput.value
            );


        /*
         * We already generated durations.
         * To change speed, rescale frame count.
         */

        let targetFrames =
            Math.round(
                totalFrames / speed
            );


        targetFrames =
            Math.max(
                1,
                targetFrames
            );


        /*
         * If speed != 1, resize latent.
         */

        let finalZP;


        if (
            targetFrames ===
            totalFrames
        ) {

            finalZP = zP;

        } else {

            finalZP =
                resizeLatent(
                    zP,
                    channels,
                    totalFrames,
                    targetFrames
                );
        }


        const finalFrames =
            targetFrames;


        /* -------------------------------------------------
           Step 4
        ------------------------------------------------- */

        setLoading(
            "Bước 4/4 • Sinh audio..."
        );


        const zPTensor =
            new ort.Tensor(
                "float32",
                finalZP,
                [
                    1,
                    channels,
                    finalFrames
                ]
            );


        const yMaskData =
            new Float32Array(
                finalFrames
            );


        yMaskData.fill(1);


        const yMask =
            new ort.Tensor(
                "float32",
                yMaskData,
                [
                    1,
                    1,
                    finalFrames
                ]
            );


        const flowOutput =
            await flow.run({

                z_p:
                    zPTensor,

                y_mask:
                    yMask,

                g:
                    g
            });


        const z =
            flowOutput.z;


        const decoderOutput =
            await decoder.run({

                z:
                    z,

                g:
                    g
            });


        const generatedAudio =
            decoderOutput.audio;


        const audioData =
            generatedAudio.data;


        if (
            !audioData ||
            audioData.length === 0
        ) {

            throw new Error(
                "Decoder không trả về audio."
            );
        }


        /* -------------------------------------------------
           WAV
        ------------------------------------------------- */

        const sampleRate =
            Number(
                ttsConfig.sample_rate ||
                24000
            );


        const wavBlob =
            audioToWav(
                audioData,
                sampleRate
            );


        showAudio(
            wavBlob
        );


        const durationSeconds =
            audioData.length /
            sampleRate;


        showMessage(
            `Đã tạo ${durationSeconds.toFixed(2)} giây audio.`,
            "success"
        );


    } catch (error) {

        console.error(
            "V-TTS synthesis error:",
            error
        );


        showMessage(
            getReadableError(error),
            "error"
        );

    } finally {

        generateBtn.disabled = false;

        loading.classList.remove(
            "show"
        );
    }
}


/* =========================================================
   Resize latent for speed
========================================================= */

function resizeLatent(
    input,
    channels,
    oldLength,
    newLength
) {

    const output =
        new Float32Array(
            channels * newLength
        );


    for (
        let c = 0;
        c < channels;
        c++
    ) {

        for (
            let i = 0;
            i < newLength;
            i++
        ) {

            /*
             * Linear interpolation.
             */

            const sourcePosition =
                (
                    i /
                    Math.max(
                        1,
                        newLength - 1
                    )
                ) *
                Math.max(
                    1,
                    oldLength - 1
                );


            const left =
                Math.floor(
                    sourcePosition
                );


            const right =
                Math.min(
                    oldLength - 1,
                    left + 1
                );


            const amount =
                sourcePosition - left;


            const leftValue =
                input[
                    c * oldLength +
                    left
                ];


            const rightValue =
                input[
                    c * oldLength +
                    right
                ];


            output[
                c * newLength +
                i
            ] =
                leftValue +
                (
                    rightValue -
                    leftValue
                ) * amount;
        }
    }


    return output;
}


/* =========================================================
   WAV encoder
========================================================= */

function audioToWav(
    samples,
    sampleRate
) {

    const buffer =
        new ArrayBuffer(
            44 +
            samples.length * 2
        );


    const view =
        new DataView(buffer);


    writeString(
        view,
        0,
        "RIFF"
    );


    view.setUint32(
        4,
        36 + samples.length * 2,
        true
    );


    writeString(
        view,
        8,
        "WAVE"
    );


    writeString(
        view,
        12,
        "fmt "
    );


    view.setUint32(
        16,
        16,
        true
    );


    /*
     * PCM
     */

    view.setUint16(
        20,
        1,
        true
    );


    /*
     * Mono
     */

    view.setUint16(
        22,
        1,
        true
    );


    view.setUint32(
        24,
        sampleRate,
        true
    );


    view.setUint32(
        28,
        sampleRate * 2,
        true
    );


    view.setUint16(
        32,
        2,
        true
    );


    view.setUint16(
        34,
        16,
        true
    );


    writeString(
        view,
        36,
        "data"
    );


    view.setUint32(
        40,
        samples.length * 2,
        true
    );


    let offset = 44;


    for (
        let i = 0;
        i < samples.length;
        i++
    ) {

        let sample =
            Number(samples[i]);


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
                ? sample * 0x8000
                : sample * 0x7FFF;


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


/* =========================================================
   Write WAV string
========================================================= */

function writeString(
    view,
    offset,
    value
) {

    for (
        let i = 0;
        i < value.length;
        i++
    ) {

        view.setUint8(
            offset + i,
            value.charCodeAt(i)
        );
    }
}


/* =========================================================
   Show audio
========================================================= */

function showAudio(blob) {

    if (currentAudioURL) {

        URL.revokeObjectURL(
            currentAudioURL
        );
    }


    currentAudioURL =
        URL.createObjectURL(blob);


    audio.src =
        currentAudioURL;


    download.href =
        currentAudioURL;


    result.classList.add(
        "show"
    );


    /*
     * Don't autoplay on mobile.
     * Browsers enjoy preventing useful things.
     */

    audio.load();
}


/* =========================================================
   Generate button
========================================================= */

generateBtn.addEventListener(
    "click",
    synthesize
);


/* =========================================================
   Enter shortcut
========================================================= */

textInput.addEventListener(
    "keydown",
    (event) => {

        if (
            event.ctrlKey &&
            event.key === "Enter"
        ) {

            event.preventDefault();

            if (!generateBtn.disabled) {

                synthesize();
            }
        }
    }
);


/* =========================================================
   Start
========================================================= */

window.addEventListener(
    "load",
    () => {

        loadModels();

    }
);
