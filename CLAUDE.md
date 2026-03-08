# Beverage Compass

飲食店向けのワイン・飲料 在庫管理アプリ。美しく、便利に。

## アーキテクチャ

**単一HTMLファイル** (`BeverageCompass_v5.html`) に全コードを収める。

- React 18.2 + ReactDOM を CDN から読み込み
- JSX不使用: `React.createElement` を `e` にエイリアスして手書き
- ビルドツール不要: `node serve.js` でローカルサーバ起動 → ブラウザで開くだけ

## データ構造

### ベースデータ (ALLDATA)
- HTML内 `<script id="alldata">` に埋め込まれた巨大JSON (~824KB)
- 読み取り専用。直接編集しない
- 店舗ごとにワインリスト・在庫情報を保持

### オーバーレイ方式
ベースデータを壊さず、差分だけ localStorage に保存する:

- **`bc_overlay_v1`** — 各店舗の `edits` (フィールド上書き), `adds` (新規アイテム), `deletes` (削除ID配列)
- **`bc_history_v1`** — 操作履歴 (edit/delete/restore/add)

`getItems(storeKey)` がベースデータ＋オーバーレイをマージして返す。

### アイテムID体系
- 元データ: `orig_storeName_index`
- 追加: `add_timestamp_index_random`
- ウィッシュリスト: `wl_storeName_index`

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
- カラー定数: `C.bg`, `C.card`, `C.text`, `C.sub`, `C.accent`, `C.green`, `C.danger`
- フォント: `'Noto Sans JP'` (日本語), `'DM Sans'` (英数)
- MCC カラーパレット: カテゴリ別の色定義 `MCC` オブジェクト

### グローバル関数
- `showToast(msg, type, undoFn)` — 通知表示。undoFn指定で「元に戻す」ボタン付き
- `getStoreOverlay(store)` / `saveOverlay(ov)` — オーバーレイ読み書き
- `addHistory(entry)` — 操作履歴を追加
- `getItems(storeKey)` — マージ済みアイテム一覧取得

## 画面構成

| コンポーネント | 役割 |
|---|---|
| `App` | ルーティング・状態管理 |
| `HomePage` | 店舗一覧 |
| `ItemListPage` | 在庫一覧 (検索・フィルター) |
| `DetailModal` | アイテム詳細 (+/- 数量, 削除) |
| `EditModal` | アイテム編集 |
| `AddItemForm` | 新規追加フォーム |
| `ImportFlow` | CSV/テキストインポート |
| `TrashPage` | 削除済みアイテム (復元可) |
| `HistoryPage` | 操作履歴 |
| `SettingsPage` | 設定・データ管理・CSV出力 |
| `StockManager` | 在庫管理メニュー |
| `Toast` | 通知 (undo対応) |

## 開発の進め方

1. `serve.js` でローカルサーバ起動
2. ブラウザで確認しながら `BeverageCompass_v5.html` を編集
3. React のイベントハンドラは `dispatchEvent` では発火しない → preview_click か直接関数呼び出しでテスト
4. テストしてからコミット

## 目指すもの

- 美しいUI: アニメーション、色使い、タイポグラフィにこだわる
- 実用性: 飲食店の現場で素早く使える操作性
- オフライン対応: localStorage完結、サーバ不要
