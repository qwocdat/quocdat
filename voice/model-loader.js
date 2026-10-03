/*
 * DIGITALSMOD MODEL LOADER
 *
 * Model được lưu bằng Cache Storage.
 *
 * Lần đầu:
 *     Network -> Cache
 *
 * Lần sau:
 *     Cache -> RAM
 *
 * Không tải lại nếu model đã tồn tại.
 */

const MODEL_VERSION = "korva-v1";

const MODEL_FILES = [
    /*
     * Các URL model thật sẽ được khai báo ở đây
     * sau khi xác nhận chính xác artifact browser
     * của KorvaTTS/Supertonic.
     *
     * Không tự đoán URL vì một file ONNX sai tên
     * là cả app nằm đất.
     */
];

const MODEL_CACHE =
    `digitalsmod-tts-${MODEL_VERSION}`;

class ModelLoader {

    constructor() {
        this.cache = null;
    }

    async init() {

        this.cache =
            await caches.open(MODEL_CACHE);

        return this;
    }

    async hasModels() {

        if (!this.cache)
            await this.init();

        if (!MODEL_FILES.length)
            return false;

        for (const url of MODEL_FILES) {

            const response =
                await this.cache.match(url);

            if (!response)
                return false;
        }

        return true;
    }

    async get(url) {

        if (!this.cache)
            await this.init();

        const cached =
            await this.cache.match(url);

        if (cached)
            return cached;

        return null;
    }

    async downloadAll(onProgress) {

        if (!this.cache)
            await this.init();

        if (!MODEL_FILES.length) {
            throw new Error(
                "Chưa cấu hình artifact model Web."
            );
        }

        let total = MODEL_FILES.length;
        let done = 0;

        for (const url of MODEL_FILES) {

            const existing =
                await this.cache.match(url);

            if (existing) {

                done++;

                onProgress?.(
                    done / total,
                    "Đã có: " + this.fileName(url)
                );

                continue;
            }

            onProgress?.(
                done / total,
                "Đang tải: " + this.fileName(url)
            );

            const response =
                await fetch(url);

            if (!response.ok) {
                throw new Error(
                    `Không tải được ${url}`
                );
            }

            await this.cache.put(
                url,
                response.clone()
            );

            done++;

            onProgress?.(
                done / total,
                "Đã tải: " + this.fileName(url)
            );
        }

        onProgress?.(
            1,
            "Đã tải xong toàn bộ model"
        );
    }

    async clear() {

        await caches.delete(MODEL_CACHE);

        this.cache =
            await caches.open(MODEL_CACHE);
    }

    fileName(url) {

        try {
            return new URL(url).pathname
                .split("/")
                .pop();
        } catch {
            return url;
        }
    }

    async storageEstimate() {

        if (!navigator.storage?.estimate)
            return null;

        return navigator.storage.estimate();
    }

    async requestPersistentStorage() {

        if (!navigator.storage?.persist)
            return false;

        return navigator.storage.persist();
    }
}

window.modelLoader =
    new ModelLoader();
