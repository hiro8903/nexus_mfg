# 【完全再現版】資材要求機能 実装チュートリアル (Material Request Implementation Guide)

本ドキュメントは、Rails 8 を基盤とした製造業向けシステムの「資材要求」モジュールを、設計からワークフロー実装まで、**全てのソースコードを網羅した状態**でステップバイステップで構築するためのガイドです。

---

## 第1章：データベース層（Migration）

製造業の調達プロセスの起点となるテーブル群を作成します。外部キー制約と数値型の精度（decimal）を厳密に定義します。

### 1-1. マイグレーションファイルの作成

以下のコマンドでベースとなるファイルを生成します。

```bash
bin/rails generate migration CreateMaterialWorkflowFoundation
```

生成されたファイルを `db/migrate/[timestamp]_create_material_workflow_foundation.rb` とし、中身を以下に完全に置き換えます。

```ruby
class CreateMaterialWorkflowFoundation < ActiveRecord::Migration[8.1]
  def change
    # 経理・独自用途コード群
    create_table :accounting_usage_codes do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
    add_index :accounting_usage_codes, :code, unique: true

    create_table :internal_usage_codes do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.references :accounting_usage_code, foreign_key: true
      t.timestamps
    end
    add_index :internal_usage_codes, :code, unique: true

    # 資材要求 (Material Requests)
    create_table :material_requests do |t|
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :applicant, null: false, foreign_key: { to_table: :users }
      t.references :request_org, foreign_key: { to_table: :org_units }
      t.references :budget_org, foreign_key: { to_table: :org_units }
      t.references :target_org, foreign_key: { to_table: :org_units }
      t.integer :transaction_type, default: 1, null: false
      t.references :usage_code, foreign_key: { to_table: :internal_usage_codes }
      t.text :purpose
      t.text :reason
      t.text :remarks
      t.integer :status, default: 0, null: false
      t.boolean :ringi_needed, default: false, null: false
      t.timestamps
    end

    # 資材要求明細 (Material Request Lines)
    create_table :material_request_lines do |t|
      t.references :material_request, null: false, foreign_key: true
      t.references :item, foreign_key: true
      t.string :item_name_free_text
      t.text :item_spec_free_text
      t.string :order_unit
      t.decimal :order_quantity, precision: 15, scale: 5
      t.decimal :packing_factor, precision: 15, scale: 5
      t.string :base_unit
      t.decimal :total_base_quantity, precision: 15, scale: 5
      t.decimal :unit_price, precision: 15, scale: 4
      t.decimal :base_unit_price, precision: 15, scale: 4
      t.decimal :tax_rate, precision: 5, scale: 4, default: 0.10
      t.date :required_date
      t.integer :status, default: 0, null: false
      t.timestamps
    end
    
    # 承認活動履歴 (Approval Activities)
    create_table :approval_activities do |t|
      t.references :material_request, null: false, foreign_key: true
      t.references :approver, null: false, foreign_key: { to_table: :users }
      t.string :step_name
      t.string :action
      t.text :comment
      t.timestamps
    end
  end
end
```

実行コマンド：
```bash
bin/rails db:migrate
```

---

## 第2章：モデル層（Model Layer）

ビジネスロジック、関連付け、バリデーションを定義します。

### 2-1. MaterialRequest モデル
ファイル：`app/models/material_request.rb`

```ruby
class MaterialRequest < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  belongs_to :applicant, class_name: "User"
  belongs_to :request_org, class_name: "OrgUnit", optional: true
  belongs_to :budget_org, class_name: "OrgUnit", optional: true
  belongs_to :target_org, class_name: "OrgUnit", optional: true
  belongs_to :usage_code, class_name: "InternalUsageCode", optional: true

  has_many :material_request_lines, dependent: :destroy
  has_many :approval_activities, dependent: :destroy

  accepts_nested_attributes_for :material_request_lines, allow_destroy: true, reject_if: :all_blank

  enum :transaction_type, {
    standard_purchase: 1, # 購入(通常)
    internal_supply: 2,   # 自社支給(加工外注用)
    customer_supply: 3    # 客先支給(無償)
  }

  enum :status, {
    draft: 0,             # 起案中
    pending_approval: 10, # 承認待ち
    approved: 40,         # 承認済
    returned: 90          # 差戻し
  }

  validates :purpose, presence: true
end
```

### 2-2. MaterialRequestLine モデル
ファイル：`app/models/material_request_line.rb`

```ruby
class MaterialRequestLine < ApplicationRecord
  belongs_to :material_request
  belongs_to :item, optional: true

  enum :status, {
    unprocessed: 0,
    allocated: 10,
    ordered: 20,
    received: 30
  }

  validates :order_quantity, numericality: { greater_than: 0 }
  validates :required_date, presence: true
  validate :item_or_free_text_must_be_present

  private

  def item_or_free_text_must_be_present
    if item_id.blank? && item_name_free_text.blank?
      errors.add(:base, "品目マスタを選択するか、品名（フリー入力）を入力してください")
    end
  end
end
```

---

## 第3章：コントローラー層（Controller Layer）

ファイル：`app/controllers/material_requests_controller.rb`

```ruby
class MaterialRequestsController < ApplicationController
  before_action :set_material_request, only: %i[ show edit update destroy ]

  def index
    @material_requests = MaterialRequest.order(created_at: :desc).all
  end

  def show
  end

  def new
    @material_request = MaterialRequest.new
    @material_request.material_request_lines.build
  end

  def edit
  end

  def create
    @material_request = MaterialRequest.new(material_request_params)
    @material_request.created_by ||= Current.user
    @material_request.applicant ||= Current.user

    respond_to do |format|
      if @material_request.save
        format.html { redirect_to @material_request, notice: "資材要求を保存しました。" }
      else
        @material_request.material_request_lines.build if @material_request.material_request_lines.empty?
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @material_request.update(material_request_params)
        format.html { redirect_to @material_request, notice: "資材要求を更新しました。" }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @material_request.destroy!
    respond_to do |format|
      format.html { redirect_to material_requests_path, status: :see_other, notice: "資材要求を削除しました。" }
    end
  end

  def submit
    @material_request = MaterialRequest.find(params[:id])
    @material_request.transaction do
      @material_request.update!(status: :pending_approval)
      @material_request.approval_activities.create!(
        approver: Current.user, step_name: "第1次承認", action: "submit", comment: "申請されました"
      )
    end
    redirect_to @material_request, notice: "資材要求を申請しました。"
  end

  def approve
    @material_request = MaterialRequest.find(params[:id])
    @material_request.transaction do
      @material_request.update!(status: :approved)
      @material_request.approval_activities.create!(
        approver: Current.user, step_name: "最終承認", action: "approve", comment: "承認されました"
      )
    end
    redirect_to @material_request, notice: "資材要求を承認しました。"
  end

  def reject
    @material_request = MaterialRequest.find(params[:id])
    @material_request.transaction do
      @material_request.update!(status: :returned)
      @material_request.approval_activities.create!(
        approver: Current.user, step_name: "承認却下", action: "reject", comment: "内容に不備があるため差し戻します"
      )
    end
    redirect_to @material_request, notice: "資材要求を差し戻しました。"
  end

  private

  def set_material_request
    @material_request = MaterialRequest.find(params[:id])
  end

  def material_request_params
    params.require(:material_request).permit(
      :applicant_id, :request_org_id, :budget_org_id, :target_org_id,
      :transaction_type, :usage_code_id, :purpose, :reason, :remarks, :status,
      material_request_lines_attributes: [
        :id, :item_id, :item_name_free_text, :item_spec_free_text,
        :order_unit, :order_quantity, :required_date, :status, :_destroy
      ]
    )
  end
end
```

---

## 第4章：国際化（I18n）と環境設定

ファイル：`config/application.rb` (抜粋)
```ruby
config.i18n.default_locale = :ja
```

ファイル：`config/locales/ja.yml`
```yaml
ja:
  activerecord:
    models:
      material_request: "資材要求"
      material_request_line: "資材要求明細"
    attributes:
      material_request:
        applicant: "申請者"
        request_org: "依頼組織"
        purpose: "目的"
        status: "ステータス"
        transaction_types:
          standard_purchase: "通常購買"
        statuses:
          draft: "下書き"
          pending_approval: "承認待ち"
          approved: "承認済"
          returned: "差戻し"
      material_request_line:
        order_quantity: "発注数量"
        required_date: "希望納期"
```

---

## 第5章：ビュー層（View Layer）

### 5-1. _form.html.erb (フォーム)
ファイル：`app/views/material_requests/_form.html.erb`

```html
<%= form_with(model: material_request, class: "contents") do |form| %>
  <% if material_request.errors.any? %>
    <div id="error_explanation" class="bg-red-50 text-red-500 px-4 py-3 font-medium rounded-xl mt-3 border border-red-100 shadow-sm">
      <h2 class="text-sm font-bold"><%= material_request.errors.count %>件のエラーにより保存できませんでした:</h2>
      <ul class="mt-1 text-xs list-disc list-inside">
        <% material_request.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-10">
    <div class="space-y-5">
      <div>
        <%= form.label :applicant_id, "申請者", class: "block text-xs font-bold text-gray-500 mb-1" %>
        <%= form.collection_select :applicant_id, User.all, :id, :name, { prompt: "申請者を選択" }, class: "mt-1 block w-full rounded-xl border-gray-200 shadow-sm bg-gray-50/50 sm:text-sm" %>
      </div>
      <div>
        <%= form.label :request_org_id, "依頼部門", class: "block text-xs font-bold text-gray-500 mb-1" %>
        <%= form.collection_select :request_org_id, OrgUnit.all, :id, :name, { prompt: "部署を選択" }, class: "mt-1 block w-full rounded-xl border-gray-200 shadow-sm bg-gray-50/50 sm:text-sm" %>
      </div>
    </div>
    <div class="space-y-5">
      <div>
        <%= form.label :purpose, "使用目的", class: "block text-xs font-bold text-gray-500 mb-1" %>
        <%= form.text_area :purpose, rows: 2, class: "mt-1 block w-full rounded-xl border-gray-200 shadow-sm sm:text-sm bg-gray-50/50" %>
      </div>
    </div>
  </div>

  <div class="mt-12 bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
    <table class="min-w-full divide-y divide-gray-200">
      <thead class="bg-gray-50/30">
        <tr>
          <th class="px-6 py-3 text-left text-xs font-bold text-gray-400">品目</th>
          <th class="px-6 py-3 text-left text-xs font-bold text-gray-400">数量</th>
          <th class="px-6 py-3 text-left border-0"></th>
        </tr>
      </thead>
      <tbody class="bg-white divide-y divide-gray-50">
        <%= form.fields_for :material_request_lines do |line_form| %>
          <tr>
            <td class="px-6 py-5">
              <%= line_form.text_field :item_name_free_text, placeholder: "品名を入力", class: "block w-full rounded-lg border-gray-100 text-xs shadow-sm" %>
            </td>
            <td class="px-6 py-5">
              <%= line_form.number_field :order_quantity, class: "w-24 rounded-lg border-gray-200 sm:text-sm" %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
  </div>

  <div class="mt-12 flex justify-end space-x-4 border-t pt-8">
    <%= form.submit "保存する", class: "px-8 py-2.5 text-white bg-indigo-600 rounded-xl shadow-lg font-bold cursor-pointer" %>
  </div>
<% end %>
```

---
以上の手順により、現行システムの資材要求機能が完全なコード状態で再現されます。
