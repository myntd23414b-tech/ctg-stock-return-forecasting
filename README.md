# PHÂN TÍCH VÀ DỰ BÁO LỢI SUẤT CỔ PHIẾU CTG BẰNG MÔ HÌNH ARIMAX

## 1. Giới thiệu dự án

Dự án ứng dụng mô hình chuỗi thời gian ARIMAX để phân tích và dự báo lợi suất cổ phiếu CTG (Ngân hàng TMCP Công Thương Việt Nam), có xem xét tác động của biến động VN-Index và tỷ giá USD/VND.

Mục tiêu của dự án là xử lý và phân tích dữ liệu tài chính, xây dựng mô hình dự báo, kiểm định các giả định thống kê và đánh giá khả năng dự báo của mô hình.

## 2. Công nghệ sử dụng

- **Ngôn ngữ lập trình:** R
- **Xử lý dữ liệu:** dplyr, readxl, lubridate, stringr, tidyr
- **Phân tích thống kê:** fBasics, tseries, lmtest, car, FinTS
- **Mô hình dự báo:** forecast (ARIMA, ARIMAX)
- **Trực quan hóa dữ liệu:** ggplot2

## 3. Dữ liệu nghiên cứu

Dự án sử dụng ba nhóm dữ liệu:

- Giá cổ phiếu CTG.
- Chỉ số VN-Index.
- Tỷ giá USD/VND.

Các biến được xây dựng phục vụ phân tích gồm:

- **R_CTG:** Lợi suất logarit của cổ phiếu CTG.
- **R_VNI:** Lợi suất logarit của VN-Index.
- **D_FX:** Biến động logarit của tỷ giá USD/VND.

## 4. Quy trình thực hiện

### Bước 1: Thu thập và xử lý dữ liệu

- Đọc dữ liệu từ các file Excel.
- Chuẩn hóa định dạng ngày tháng và dữ liệu số.
- Ghép ba bộ dữ liệu theo ngày giao dịch.
- Kiểm tra giá trị thiếu và dữ liệu trùng lặp.
- Tính toán các biến lợi suất và biến động tỷ giá.

### Bước 2: Phân tích khám phá dữ liệu

- Thống kê mô tả các biến nghiên cứu.
- Trực quan hóa dữ liệu chuỗi thời gian.
- Phân tích đặc điểm biến động của các biến.

### Bước 3: Kiểm định thống kê

- Kiểm định tính dừng bằng ADF.
- Kiểm định nhân quả Granger.
- Kiểm tra đa cộng tuyến bằng VIF.

### Bước 4: Xây dựng mô hình

- Xây dựng mô hình ARIMA làm cơ sở so sánh.
- Xây dựng mô hình ARIMAX với hai biến ngoại sinh là lợi suất VN-Index và biến động tỷ giá.
- Sử dụng hàm auto.arima để lựa chọn cấu trúc mô hình.

### Bước 5: Kiểm định phần dư

Thực hiện các kiểm định:

- Ljung-Box.
- Jarque-Bera.
- ARCH.

Đồng thời trực quan hóa phần dư thông qua biểu đồ ACF, PACF và Q-Q Plot.

### Bước 6: Dự báo và đánh giá

- Chia dữ liệu thành tập huấn luyện và 10 phiên giao dịch cuối để kiểm tra dự báo.
- Dự báo lợi suất cổ phiếu CTG bằng ARIMAX.
- Chuyển đổi lợi suất dự báo thành giá cổ phiếu dự báo.
- So sánh giá thực tế và giá dự báo bằng biểu đồ.
- Đánh giá sai số dự báo thông qua MAE và MAPE.

## 5. Kỹ năng thể hiện qua dự án

- Lập trình và phân tích dữ liệu bằng R.
- Làm sạch và tích hợp dữ liệu từ nhiều nguồn.
- Kiểm tra chất lượng dữ liệu.
- Phân tích thống kê và chuỗi thời gian.
- Xây dựng mô hình dự báo ARIMA, ARIMAX.
- Trực quan hóa và đánh giá kết quả dự báo.

## 6. Mã nguồn

Toàn bộ mã nguồn phân tích và xây dựng mô hình được trình bày trong file R của repository.

**Lưu ý:** Dữ liệu Excel gốc không được công khai trong repository. Vì vậy, cần có dữ liệu đầu vào tương ứng để chạy lại toàn bộ chương trình.

---

*Dự án được thực hiện phục vụ mục đích học tập và nghiên cứu, không phải khuyến nghị đầu tư.*
