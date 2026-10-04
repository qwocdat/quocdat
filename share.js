/* shared.js - Core Module & Firebase Rate Limit Fix */
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js";
import {
  getAuth, onAuthStateChanged, signOut
} from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import {
  getFirestore, doc, getDoc, onSnapshot
} from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const firebaseConfig = {
  apiKey: "AIzaSyAUuV5euNNLHE2Cf6tXzUHV-ChKwNF593Y",
  authDomain: "quocdat-396fe.firebaseapp.com",
  databaseURL: "https://quocdat-396fe-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "quocdat-396fe",
  storageBucket: "quocdat-396fe.firebasestorage.app",
  messagingSenderId: "685476439350",
  appId: "1:685476439350:web:949054ecba7f0a0c383f97"
};

export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);

export const S = {
  user: null, profile: null, wallet: null, seller: null,
  unsubListeners: []
};

// Hàm hủy tất cả Listeners cũ tránh rò rỉ dữ liệu và spam kết nối Firebase
export function clearAllSnapshots() {
  S.unsubListeners.forEach(unsub => typeof unsub === 'function' && unsub());
  S.unsubListeners = [];
}

// Anti-spam Debounce Helper
export function debounce(fn, delay = 500) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}

// Khoá Form trong quá trình xử lý Firebase
export async function handleAsyncForm(buttonEl, asyncCallback) {
  if (!buttonEl || buttonEl.disabled) return;
  buttonEl.disabled = true;
  const originalText = buttonEl.innerHTML;
  buttonEl.innerHTML = '<span class="spinner"></span> Đang xử lý...';
  try {
    await asyncCallback();
  } catch (err) {
    console.error(err);
  } finally {
    buttonEl.disabled = false;
    buttonEl.innerHTML = originalText;
  }
}

export const $ = (s, r = document) => r.querySelector(s); export const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));
export const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
export const fmtVND = n => Number(n || 0).toLocaleString('vi-VN') + 'đ';

export function toast(msg, type = 'info') {
  let root = $('#toast-root');
  if (!root) {
    root = document.createElement('div');
    root.id = 'toast-root';
    document.body.appendChild(root);
  }
  const t = document.createElement('div');
  t.className = `toast ${type}`;
  t.innerHTML = `<span class="bar"></span><span>${esc(msg)}</span>`;
  root.appendChild(t);
  requestAnimationFrame(() => t.classList.add('show'));
  setTimeout(() => {
    t.classList.remove('show');
    setTimeout(() => t.remove(), 350);
  }, 3400);
}

export function initAuth(onUserReady) {
  onAuthStateChanged(auth, async (user) => {
    clearAllSnapshots();
    if (user) {
      S.user = user;
      try {
        const uSnap = await getDoc(doc(db, 'users', user.uid));
        S.profile = uSnap.exists() ? uSnap.data() : null;
      } catch (e) { console.error("Error fetching user profile:", e); }

      const unsubW = onSnapshot(doc(db, 'wallets', user.uid), (snap) => {
        S.wallet = snap.exists() ? snap.data() : { balance: 0 };
        if (onUserReady) onUserReady(user);
      }, err => console.error("Wallet listener error:", err));
      
      S.unsubListeners.push(unsubW);
    } else {
      S.user = null; S.profile = null; S.wallet = null;
      if (onUserReady) onUserReady(null);
    }
  });
}
