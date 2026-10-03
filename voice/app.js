const $ = id =>
    document.getElementById(id);

const modelProgress =
    $("modelProgress");

const modelPercent =
    $("modelPercent");

const modelStatus =
    $("modelStatus");

const storageInfo =
    $("storageInfo");

const loadModelBtn =
    $("loadModelBtn");

const generateBtn =
    $("generateBtn");

const speed =
    $("speed");

const speedValue =
    $("speedValue");

const resultCard =
    $("resultCard");

const audio =
    $("audio");

const downloadBtn =
    $("downloadBtn");


function setProgress(value, text) {

    const percent =
        Math.round(value * 100);

    modelProgress.style.width =
        percent + "%";

    modelPercent.textContent =
        percent + "%";

    modelStatus.textContent =
        text;
}


async function updateStorageInfo() {

    const estimate =
        await modelLoader.storageEstimate();

    if (!estimate)
        return;

    const used =
        estimate.usage || 0;

    const quota =
        estimate.quota || 0;

    const mb =
        n => (n / 1024 / 1024)
            .toFixed(1);

    storageInfo.textContent =
        `Bộ nhớ model: ${mb(used)} MB / ` +
        `${mb(quota)} MB`;
}


async function boot() {

    try {

        await modelLoader.init();

        const exists =
            await modelLoader.hasModels();

        await updateStorageInfo();

        if (exists) {

            setProgress(
                1,
                "✓ Model đã có trên thiết bị"
            );

            loadModelBtn.textContent =
                "✓ Dữ liệu đã sẵn sàng";

            const engine =
                await ttsEngine.load();

            modelStatus.textContent =
                `✓ Sẵn sàng • ${engine.backend}`;

            generateBtn.disabled = false;

            return;
        }

        setProgress(
            0,
            "Chưa có dữ liệu model"
        );

        loadModelBtn.disabled = false;

    } catch (error) {

        console.error(error);

        modelStatus.textContent =
            "Không thể khởi tạo model";
    }
}


loadModelBtn.addEventListener(
    "click",
    async () => {

        loadModelBtn.disabled = true;

        try {

            await modelLoader
                .requestPersistentStorage();

            await modelLoader.downloadAll(
                (progress, text) => {

                    setProgress(
                        progress,
                        text
                    );
                }
            );

            await updateStorageInfo();

            const engine =
                await ttsEngine.load();

            modelStatus.textContent =
                `✓ Sẵn sàng • ${engine.backend}`;

            loadModelBtn.textContent =
                "✓ Đã cài dữ liệu";

            generateBtn.disabled = false;

        } catch (error) {

            console.error(error);

            modelStatus.textContent =
                "❌ " + error.message;

            loadModelBtn.disabled = false;
        }
    }
);


speed.addEventListener(
    "input",
    () => {

        speedValue.textContent =
            Number(speed.value)
                .toFixed(2) + "x";
    }
);


generateBtn.addEventListener(
    "click",
    async () => {

        const text =
            $("text").value.trim();

        if (!text)
            return alert(
                "Nhập nội dung trước đã."
            );

        generateBtn.disabled = true;

        generateBtn.textContent =
            "Đang tạo giọng...";

        try {

            const result =
                await ttsEngine.synthesize(
                    text,
                    {
                        voice:
                            $("voice").value,

                        speed:
                            Number(speed.value)
                    }
                );

            /*
             * result dự kiến:
             *
             * {
             *   wavBlob: Blob
             * }
             */

            const url =
                URL.createObjectURL(
                    result.wavBlob
                );

            audio.src = url;

            resultCard.classList
                .remove("hidden");

            downloadBtn.onclick = () => {

                const a =
                    document.createElement("a");

                a.href = url;

                a.download =
                    "digitalsmod-tts.wav";

                a.click();
            };

        } catch (error) {

            console.error(error);

            alert(
                "TTS chưa chạy được:\n\n" +
                error.message
            );

        } finally {

            generateBtn.disabled = false;

            generateBtn.textContent =
                "Tạo giọng nói";
        }
    }
);


boot();
