# 🪙 Hũ Vàng — Gold Portfolio

Ứng dụng sổ quản lý và theo dõi danh mục tích lũy vàng cá nhân **Offline 100%**, không cần tài khoản, không máy chủ, tôn trọng tuyệt đối quyền riêng tư tài sản.

---

## ✨ Điểm nổi bật & Tính năng cốt lõi

### 1. 🏠 Màn hình Dashboard (Tổng quan tài sản)
- **Tổng lượng vàng**: Tự động quy đổi linh hoạt giữa **chỉ** và **lượng** (1 lượng = 10 chỉ = 100 phân). Ví dụ: `12.5 chỉ ≈ 1.25 lượng`.
- **Tổng giá vốn (Cost Basis)**: Tổng số tiền thực chi để sở hữu vàng.
- **Giá mua trung bình (Weighted Average Cost)**: Tính giá vốn bình quân gia quyền tự động theo từng chỉ: `Giá vốn / Tổng lượng vàng`.
- **Giá trị hiện tại**: Định giá theo giá thị trường do người dùng cập nhật.
- **Lãi/lỗ tạm tính (Unrealized PnL)**: Hiển thị cả số tiền lãi và tỷ lệ `%` với mã màu trực quan (xanh lãi, đỏ lỗ).
- **Lãi đã chốt (Realized PnL)**: Ghi nhận chính xác khoản lợi nhuận thực tế thu được từ các lần bán vàng.
- **Bảo mật tức thì 👁**: Nút ẩn/hiện số tiền và lượng vàng `••••••••` trên toàn bộ màn hình khi ở nơi đông người.

### 2. 🏺 Hũ Vàng Tương Tác & Kế Hoạch Mua Vàng
- **Chiếc Hũ Vàng phong cách Luxe**: Sử dụng `CustomPainter` mô phỏng hũ thủy tinh viền vàng với mức vàng dâng lên theo tiến độ thực tế.
- **Mục tiêu tích lũy**: Thiết lập mục tiêu tùy biến (5 chỉ, 1 lượng, 2 lượng, 5 lượng, 10 lượng, hoặc nhập tùy chỉnh).
- **Kế hoạch dự báo tương lai**: 
  - Tính toán số vàng còn thiếu.
  - Dự báo chính xác tháng/năm hoàn thành mục tiêu dựa trên kế hoạch mua định kỳ hàng tháng.
  - Ước tính số tiền cần chuẩn bị mỗi tháng theo giá vàng hiện tại.

### 3. 📜 Sổ Giao Dịch Toàn Diện (Transactions Ledger)
- Hỗ trợ đầy đủ các loại giao dịch:
  - 🟢 **Mua vào**: Tăng lượng vàng, tăng giá vốn.
  - 🔴 **Bán ra**: Giảm lượng vàng, giảm giá vốn theo phương pháp bình quân gia quyền tại thời điểm bán, tính lãi chốt lời.
  - 🟡 **Điều chỉnh / Kiểm kê**: Đồng bộ lại số lượng thực tế.
  - 🎁 **Được tặng / Cho đi**: Ghi nhận quà tặng vàng.
- Nhập liệu thông minh:
  - Chọn đơn vị nhập linh hoạt: `chỉ`, `lượng`, `phân`.
  - Tự động gợi ý đơn giá thị trường theo loại vàng đã chọn.
  - Tự động tính tổng tiền (kèm phí chế tác / tiền công).
  - Gợi ý nhanh các tiệm vàng nổi tiếng (PNJ, DOJI, SJC, Bảo Tín Minh Châu, Mi Hồng...).
- Bộ lọc theo loại giao dịch, lọc theo loại vàng và tìm kiếm ghi chú/cửa hàng.
- Xem chi tiết, chỉnh sửa và xóa giao dịch an toàn.

### 4. 🟡 Đa Dạng Loại Vàng & Danh Mục Riêng Biệt
- Cấu hình sẵn các loại vàng thông dụng:
  - 🟡 **Vàng nhẫn 9999** (99.99%)
  - 🟡 **Vàng miếng SJC** (99.99%)
  - 🟡 **Vàng 24K** (99.9%)
  - 🟡 **Vàng 18K** (75.0%)
  - 🟡 **Vàng trang sức**
  - 🟡 **Vàng khác / Tự tạo thêm**
- Từng loại vàng duy trì portfolio độc lập: số lượng, giá vốn, giá trung bình, giá thị trường, giá trị hiện tại, lãi/lỗ tạm tính và lãi đã chốt.

### 5. 📊 Thống Kê & Biểu Đồ
- **Phân bổ danh mục**: Donut/Pie Chart thể hiện cơ cấu các loại vàng với phần trăm `%` và số chỉ sở hữu.
- **Chi tiêu theo tháng**: Bar Chart thống kê số tiền thực chi tích lũy vàng qua 6 tháng gần nhất.
- Bảng tổng hợp các chỉ số tài chính quan trọng.

### 6. 🔐 Bảo Mật & Sao Lưu 100% Offline
- **Khóa ứng dụng bằng mã PIN**: Giao diện Numpad kim loại sang trọng, bảo vệ tài sản mỗi khi mở app.
- **Sao lưu dữ liệu (Backup JSON)**: Xuất toàn bộ dữ liệu ra file/clipboard để lưu trữ cá nhân (Google Drive, iCloud, USB...).
- **Khôi phục dữ liệu (Restore JSON)**: Khôi phục danh mục tài sản nguyên vẹn từ file sao lưu.
- **Xuất Excel / CSV**: Xuất danh sách sổ giao dịch sang định dạng bảng tính CSV tương thích 100% Excel / Google Sheets.

---

## 🛠 Kiến Trúc Kỹ Thuật

```
lib/
├── models/
│   ├── gold_type.dart          # Định nghĩa loại vàng & độ tinh khiết
│   ├── gold_transaction.dart   # Model giao dịch (Mua, Bán, Điều chỉnh, Tặng)
│   ├── gold_price.dart         # Bảng giá thị trường & lịch sử giá
│   ├── gold_goal.dart          # Mục tiêu Hũ Vàng & kế hoạch mua
│   ├── portfolio.dart          # Công thức tính giá vốn, PnL, tổng tài sản
│   └── app_settings.dart       # Cấu hình bảo mật, mã PIN, ẩn số tiền
├── services/
│   ├── storage_service.dart    # Lưu trữ offline SharedPreferences & Export JSON/CSV
│   └── mock_data.dart          # Dữ liệu khởi tạo mẫu chất lượng cao
├── providers/
│   └── portfolio_provider.dart # Quản lý trạng thái, tính toán giá vốn bình quân
├── utils/
│   ├── formatters.dart         # Định dạng VNĐ, Chỉ, Lượng, Ngày giờ chuẩn tiếng Việt
│   └── theme.dart              # Hệ thống bảng màu Luxe Gold & Dark Theme
├── widgets/
│   ├── gold_jar_widget.dart    # CustomPainter Hũ Vàng với mức vàng dâng lên
│   ├── metric_card.dart        # Thẻ Hero hiển thị chỉ số tài sản tổng
│   ├── transaction_tile.dart   # Thẻ giao dịch trực quan
│   └── gold_type_card.dart     # Thẻ danh mục từng loại vàng
├── screens/
│   ├── home_screen.dart        # 4 tab chính & quản lý khóa PIN
│   ├── dashboard_tab.dart      # Màn hình Tổng quan
│   ├── transactions_tab.dart   # Màn hình Sổ giao dịch
│   ├── statistics_tab.dart     # Màn hình Thống kê & Biểu đồ
│   ├── settings_tab.dart       # Màn hình Cài đặt & Sao lưu
│   ├── add_transaction_screen.dart # Form thêm/sửa giao dịch
│   ├── update_price_screen.dart    # Form cập nhật giá thị trường
│   ├── pin_lock_screen.dart        # Màn hình nhập mã PIN mở khóa
│   └── goal_detail_screen.dart     # Màn hình chi tiết mục tiêu Hũ Vàng
└── main.dart                   # Điểm khởi chạy ứng dụng
```

---

## 🚀 Hướng Dẫn Chạy Ứng Dụng

### Kiểm tra và chạy thử:
```bash
# Kiểm tra mã nguồn
flutter analyze

# Chạy unit tests
flutter test

# Chạy trên Windows Desktop
flutter run -d windows

# Hoặc chạy trên trình duyệt Web (Chrome)
flutter run -d chrome

# Hoặc chạy trên Android
flutter run -d <device-id>
```
