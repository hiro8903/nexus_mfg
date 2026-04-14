# フェーズ2 実装トラブルシューティング件忘録

資材要求（Material Request）機能の実装中に発生した主な課題、その原因、および解決方法を記録します。

## 1. 明細行（MaterialRequestLine）が保存されない問題

### 【事象】
資材要求のヘッダ領域は保存されるが、ネストされた明細行（MaterialRequestLine）がデータベースに保存されず、エラーも表示されない。

### 【原因】
`MaterialRequest` モデルにおける `accepts_nested_attributes_for` の設定、具体的には `reject_if: :all_blank` の挙動によるものでした。
フォーム送信時に明細行の全てのフィールドが空（または空文字 `""`）だった場合、Rails はその明細行の処理を「静かにスキップ（reject）」します。

### 【解消方法】
- **開発時の対応**: ブラウザからの入力時に、少なくとも一つの必須項目（品名や数量など）を確実に入力するようにしました。
- **コードでの対応**: `MaterialRequestLine` にバリデーション（`order_quantity > 0` 等）を追加し、空で送信された場合には「単に無視される」のではなく「エラーとしてフィードバックされる」ように調整しました。

## 2. ブラウザツール等での日付入力エラー

### 【事象】
`required_date` (希望納期) に値を入力しているにもかかわらず、保存に失敗し、明細行が作成されない。

### 【原因】
HTML5 の `date_field` において、入力が「日（Day）」のみで「年（Year）」や「月（Month）」が欠落している場合、ブラウザからは不完全なデータが送信されます。
Rails のサーバ側ではこれを `nil` または不正な形式として扱い、バリデーションエラー（`presence: true`）を引き起こしていました。

### 【解消方法】
- **入力の徹底**: ブラウザ上での入力時に、カレンダーピッカーを介して完全な日付（YYYY-MM-DD）を選択・入力することを徹底しました。
- **検証**: Rails コンソール（`bin/rails runner`）を用いて、正しい日付オブジェクトが渡された際に正常に保存されることを確認し、コード自体の不備ではないことを切り分けました。

## 3. 日本語化（I18n）における Enum の定義ミス

### 【事象】
`material_request.transaction_type` などの Enum の値が、ビューで期待通り日本語（「通常購買」等）に翻訳されない。

### 【原因】
`ja.yml` における Enum の定義階層が、Rails の慣習（`activerecord.attributes.モデル名.属性名s.値名`）と一致していませんでした。単数形（`transaction_type`）ではなく複数形（`transaction_types`）のキーが必要です。

### 【解消方法】
`ja.yml` を以下のように修正しました：
```yaml
ja:
  activerecord:
    attributes:
      material_request:
        transaction_types: # ここが複数形
          standard_purchase: "通常購買"
```
これにより、`MaterialRequest.human_attribute_name("transaction_type.standard_purchase")` などの呼び出しで正しく翻訳されるようになりました。
