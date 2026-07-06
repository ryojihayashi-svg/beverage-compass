# 林ファミリー English

家族みんなで使う英語学習 PWA。美しく、楽しく、毎日続く。

## アーキテクチャ

**単一HTMLファイル** (`HayashiFamilyEnglish.html`) に全コードを収める。

- React 18 + ReactDOM を CDN から読み込み
- JSX不使用: `React.createElement` を `e` にエイリアスして手書き
- ビルドツール不要: `node serve.js` でローカルサーバ起動 → ブラウザで開くだけ
- 本番は GitHub Pages: `https://ryojihayashi-svg.github.io/beverage-compass/HayashiFamilyEnglish.html`
- `index.html` は英語アプリへのリダイレクトのみ

## バージョン管理 (重要)

リリースのたびに **2 箇所を必ず同時に** 上げる:

1. `HayashiFamilyEnglish.html` 内の `APP_VERSION` (数字)
2. `sw.js` 内の `CACHE_VERSION` (`hfe-v<数字>-<日付>`)

プロフィール画面右下に `v◯◯` と表示され、端末側で新バージョン確認ができる。

## データ構造

学習コンテンツはすべて HTML 内の JS 配列に直書き:

| 配列 | 内容 |
|---|---|
| `VOCAB` | 単語 + イディオム (~2,000 語、例文 2 つずつ) |
| `SENTENCES` | 瞬間英作文の短文 (文法タグ付き) |
| `SHADOWING_QA` | シャドーイング単文・Q&A・必修フレーズ |
| `SHADOWING_PASSAGES` | 長文 (スピーチ・English lessons ①〜④) |
| `CONVO_PATTERNS` + `CONVO_SECTIONS` | 定型構文 (Section 1〜4、200 構文) |
| `NATIVECAMP_QA` | NativeCamp Q&A (質問 + OREO 4 文回答) |
| `USEFUL_PHRASE_SETS` | NativeCamp用 定型フレーズ 15 セット |
| `ENGLISH_LESSONS` | 1分英語解説 + 5問クイズ |
| `LISTENING_QUIZ` / `READING_QUESTIONS` | リスニング / リーディング 4 択 |

### 進捗データ (localStorage)
- `hfe_v1_<memberId>` — 学習進捗 (vocab/composition/mistakes/覚えた)
- `hfe_hidden_items_v1` — × で外した問題 (家族共有)
- Supabase `member_state` テーブルに JSONB で同期 (last-write-wins)
- `member_id='family'` の行に家族共有データ (hiddenItems, 名前, 写真)

### 個人カスタムデータ (削除・変更禁止)
- `NATIVECAMP_QA` / `USEFUL_PHRASE_SETS` — 亮治さん本人が作成・添削した内容
- `SHADOWING_PASSAGES` の English lessons ①〜④ — 本人のスピーチ原稿
- これらはユーザー本人の指示なしに書き換えないこと

## プロフィールとレベル

`PROFILES` に家族 5 人。level 1=英検5/4級 〜 5=準1級。
`comfort` 値 (localStorage) が正解率に応じて出題レベルを自動調整。

## コーディング規約

### React パターン
```javascript
const [state, setState] = useState(initialValue);
// JSXではなく createElement
e("div", { style: { ... } },
  e("span", null, "テキスト"),
  condition && e(Component, { prop: value })
);
```

### スタイリング
- CSS-in-JS (inline style objects)
- カラー定数: `C.bg`, `C.card`, `C.text`, `C.sub`, `C.line`, `C.brand`, `C.success`, `C.danger`
- フォント: `SERIF` (見出し), `SERIF_READ` (本文英語), `SANS_UI` (UIラベル)

### 音声 (TTS)
- `speak(text)` — 単発読み上げ。`getBestVoice()` が端末の最高品質ボイスを自動選択
- 自動再生シーケンスは `playSeq` ref + cancelled フラグのパターンで競合を防ぐ
- iOS PWA では**タップハンドラ内で空発話**して TTS を解錠してから自動再生に入る

## 開発の進め方

1. `node serve.js` でローカルサーバ起動
2. 編集後: `node -e` で `new Function(script)` による構文チェック
3. APP_VERSION + CACHE_VERSION を bump
4. ブランチ → コミット → PR → main へマージ (squash)
5. main マージ後 数分で GitHub Pages に反映

## 目指すもの

- 家族全員 (小6〜大人) がレベルに合わせて使える
- 「今日の学習パス」で迷わず毎日続けられる
- 子供が楽しく学べる仕掛け (ご褒美・演出・達成感)
- オフライン対応: localStorage 完結、サーバ不要
