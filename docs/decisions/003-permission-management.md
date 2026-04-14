# ADR 003: 権限管理設計（Permission Management）
**設計判断の記録 (Architecture Decision Record)**

## 📅 ステータス (Status)
**承認済み (Accepted)**: 2026-03-25

## 🔗 関連ADR
- **前提**: [ADR 002: 人事・組織構造](./002-personnel-and-organization-structure.md)（`assignments`, `org_units` の設計）
- **変更**: ADR 002 Section 5 で検討した `users.system_role` (enum) 案を本 ADR にて変更。

## 💡 背景 (Context)
ADR 002 では `users.system_role` としてシステム権限をユーザーに直接持たせる案を検討していた。
しかし、製造現場における以下の現実的な要件により、より柔軟な権限管理設計が必要と判断した。

- **人事異動が激しい**: ユーザーごとに権限を手動で設定・剥奪するコストとミスリスクが高い。
- **兼務が発生する**: 1人が複数の部署（OrgUnit）に同時に所属する場合、それぞれの組織が持つ権限を**すべて有効**にしたい。
- **権限の粒度が多様**: 「システム管理者」という一つの権限ではなく、「人事管理ができる」「在庫を閲覧できる」「発注を承認できる」など、機能単位での細かい権限制御が将来必要になる。

## 🏹 検討した選択肢 (Options Considered)

### 案A: `users.system_role` (integer/enum)
- **Pros**: シンプル。実装が速い。
- **Cons**: 兼務ユーザーへの複数権限の合算ができない。異動時に手動で権限を変更する運用が必要。

### 案B: `org_unit_permissions` 中間テーブル（採用）
- **Pros**: 組織に権限を紐付けることで、配属（Assignment）によって権限が自動付与・剥奪される。兼務時は自動でユニオン（合算）。
- **Cons**: 実装がやや複雑。ただし、Pundit との組み合わせで整理可能。

## 💡 決定 (Decision)
**`org_unit_permissions` テーブルを新設し、OrgUnit（組織単位）に権限を紐付ける**設計を採用する。

## 🗂️ テーブル設計

```
org_unit_permissions
  - id
  - org_unit_id  (FK → org_units)  # どの組織に紐付くか
  - permission   (integer/enum)     # どの権限か
  - created_at / updated_at
```

### permission の enum 定義（予定）
| 値 | 権限名 | 説明 |
| :--- | :--- | :--- |
| 0 | `system_admin` | 全機能へのフルアクセス（最上位） |
| 1 | `manage_users` | ユーザーマスターの作成・編集 |
| 2 | `manage_hr` | 人事・配属履歴の管理 |
| 3 | `view_inventory` | 在庫の閲覧 |
| 4 | `manage_inventory` | 在庫の編集・移動 |
| 5 | `approve_orders` | 発注の承認 |
※ 値は拡張可能。必要に応じて追加する。

## ⚙️ 権限解決ロジック（Effective Permission）

```
ユーザーの実質権限 =
  現在有効な assignments（end_date が NULL または未来）
    → それぞれの org_unit_id
      → それぞれの org_unit_permissions
        → 全権限の UNION（合算）
```

### 具体例：兼務ユーザーの場合
```
田中さん
  ├── Assignment A（人事部 → manage_hr, manage_users）
  └── Assignment B（製造部 → view_inventory, manage_inventory）
                         ↓
      実質権限 = manage_hr + manage_users + view_inventory + manage_inventory
```

### `system_admin` の扱い
- `system_admin` も他の権限と同じく `org_unit_permissions` の一項目として定義する。
- 「システム管理部」などの OrgUnit に `system_admin` 権限を付与しておけば、そこに配属されたユーザーは全員管理者になる。

## 🔄 UX への影響（管理者の操作フロー）

**以前（手動）**:
1. ユーザーを人事異動させる
2. 別途権限設定画面を開く
3. 権限を手動で更新する（← ミスや忘れが発生しやすい）

**今後（自動追従）**:
1. 配属（Assignment）を登録・更新する
2. → 権限が自動で切り替わる（管理者の追加操作ゼロ）

## ✅ 決定事項 (Decisions)
1. **`org_unit_permissions` テーブルの新設**: OrgUnit に permission を多対多で紐付ける。
2. **兼務時の権限はユニオン（合算）**: 複数の OrgUnit の権限をすべて有効にする。
3. **`users.system_role` マイグレーションの破棄**: `AddSystemRoleToUsers` マイグレーションは作成済みだが、本設計採用により不要となったため削除する。
4. **権限判定の一元化**: Pundit Policy 内で `user.effective_permissions` メソッドを通じて権限を解決し、全 Policy で再利用可能にする。

## 📈 期待される効果 (Consequences)
- 人事異動の登録だけで権限が自動追従し、管理ミス（剥奪し忘れ等）がゼロになる。
- 兼務ユーザーが複数の画面・機能にアクセスできるという製造現場の現実に対応できる。
- 将来的な権限の粒度の追加（例：「見積の閲覧だけ可能」等）も、enum に値を追加するだけで対応可能。
