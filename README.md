# waziIOS

一个只卖一款袜子的极简 iOS 商店 App。

当前版本使用 SwiftUI 实现用户端购买流程与本地后台演示，后端目标是 Supabase + PostgreSQL，支付方式按 MVP 方案采用支付宝收款码展示，不接官方支付 SDK。

## 产品定位

- 只卖一款基础袜
- 只提供三种颜色：黑 / 白 / 灰
- 固定价格：`15 元 / 5 双`
- 用户先支付，再填写收货地址
- 一个订单只包含一件商品

## 已完成页面

- 入口页：品牌、理念、主视觉、进入商店
- 商品页：袜子展示、颜色选择、固定价格、库存展示
- 支付页：订单摘要、支付宝收款码弹层、付款确认
- 地址填写页：姓名、手机、详细地址
- 订单页：订单状态、订单信息、收货信息
- 后台订单管理页：订单列表、物流单号填写、发货状态切换、基础统计、未填地址筛选

## 当前技术结构

- `waziIOS/ContentView.swift`
  入口页与应用主导航
- `waziIOS/ProductDetailView.swift`
  商品页与颜色选择
- `waziIOS/CheckoutView.swift`
  支付页与二维码流程
- `waziIOS/AddressFormView.swift`
  地址填写
- `waziIOS/SuccessView.swift`
  订单详情
- `waziIOS/AdminDashboardView.swift`
  后台管理演示页
- `waziIOS/ShopModels.swift`
  商品、订单、状态与 `ShopStore`
- `waziIOS/OrderRepository.swift`
  数据仓储协议与本地 mock 实现
- `waziIOS/SupabaseConfig.swift`
  Supabase 环境占位与后端模式切换

## 运行方式

1. 用 Xcode 打开 `waziIOS.xcodeproj`
2. 选择 iPhone 模拟器
3. 直接运行

如果 Xcode 曾经缓存过旧报错，可以先执行：

1. `Product -> Clean Build Folder`
2. 再重新运行

## Supabase 接入

当前工程已经内置了一个不依赖第三方 SDK 的 Supabase REST 仓储：

- `waziIOS/SupabaseOrderRepository.swift`
- `waziIOS/SupabaseConfig.swift`
- `supabase/schema.sql`

只要给 App 配置下面两个环境变量，就会自动从本地 mock 切到 Supabase：

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

你可以在 Xcode 的 Scheme 里配置：

1. `Product -> Scheme -> Edit Scheme`
2. 选择 `Run`
3. 打开 `Arguments`
4. 在 `Environment Variables` 里新增上面两个值

## 当前数据层说明

当前版本默认使用 `LocalOrderRepository`，也就是本地内存数据，适合做页面演示和交互验证。

如果检测到 `SUPABASE_URL` 和 `SUPABASE_ANON_KEY`，应用会自动切到 `SupabaseOrderRepository`。

`ShopStore` 已经改成依赖 `OrderRepository` 协议，所以页面层不需要因为后端切换而重写。

首页和后台页都会显示当前数据来源状态，方便区分是本地演示数据还是 Supabase 真实数据。

## 下一步建议

1. 给后台页增加订单详情和物流单号输入框
2. 收紧 Supabase RLS，把匿名更新改成 service role 或 Edge Function
3. 把支付宝收款码替换为真实静态图片资源
4. 接入真实支付确认机制
5. 增加库存表而不是写死库存数

## 建议的 Supabase 表结构

### `orders`

- `id uuid primary key`
- `order_number text unique not null`
- `product_name text not null`
- `color text not null`
- `amount integer not null`
- `pack_description text not null`
- `payment_state text not null`
- `shipping_state text not null`
- `receiver_name text`
- `receiver_phone text`
- `receiver_address text`
- `tracking_number text`
- `created_at timestamptz default now()`

### `stats`（可选）

第一版也可以不单独建统计表，直接从 `orders` 聚合出订单数和销售额。

## 备注

当前版本没有安装 `supabase-swift`，而是先用 REST API 直连 Supabase，这样改动更轻，也更容易先跑通 MVP。
