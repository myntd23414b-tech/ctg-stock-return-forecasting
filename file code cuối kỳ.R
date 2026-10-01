# cài thư viện
library(readxl)
library(dplyr)
library(stringr)
library(lubridate)
library(fBasics)
library(tseries)
library(lmtest)
library(car)
library(forecast)
library(FinTS)
library(ggplot2)
# thêm dữ liệu
ctg_raw <- read_excel("CTG.xlsx")
vni_raw <- read_excel("VNINDEX.xlsx")
fx_raw  <- read_excel("Tỷ giá.xlsx")
# chuyển đúng định dạng cho dữ liệu
ctg <- ctg_raw %>%
  transmute(
    Date = dmy(Date),  # vì đang là "31/12/2024"
    CTG_Price = as.numeric(str_replace(Price, ",", ".")) * 1000,  # đổi sang VND
    CTG_Volume = as.numeric(Volume)
  ) %>%
  arrange(Date)

vnindex <- vni_raw %>%
  transmute(
    Date = dmy(Date),
    VNI_Price = as.numeric(str_replace(Price, ",", ".")),
    VNI_Volume = as.numeric(Volume)
  ) %>%
  arrange(Date)

fx <- fx_raw %>%
  transmute(
    Date = as.Date(trimws(Date), format = "%d/%m/%Y"),
    FX_Price = as.numeric(gsub(",", "", trimws(Price)))
  ) %>%
  filter(!is.na(Date)) %>%
  arrange(Date)
# gộp dữ liệu
data_full <- merge(ctg, vnindex, by = "Date")
data_full <- merge(data_full, fx, by = "Date")
data_full <- data_full[order(data_full$Date), ]
# kiểm tra dữ liệu sau gộp
nrow(data_full)
colSums(is.na(data_full))
sum(duplicated(data_full))
sum(duplicated(data_full$Date))
head(data_full)
tail(data_full)
# tạo biến lợi suất
data_model <- data_full %>%
  mutate(
    R_CTG = log(CTG_Price / lag(CTG_Price)),
    R_VNI = log(VNI_Price / lag(VNI_Price)),
    D_FX  = log(FX_Price / lag(FX_Price))
  ) %>%
  na.omit()
# kiểm tra bộ dữ liệu mô hình
nrow(data_model)
colSums(is.na(data_model))
sum(duplicated(data_model))
sum(duplicated(data_model$Date))
head(data_model)
summary(data_model[, c("R_CTG", "R_VNI", "D_FX")])

# thống kê mô tả
basicStats(data_model[, c("R_CTG", "R_VNI", "D_FX")])
# biểu đồ các chuỗi 
library(tidyr)
library(ggplot2)

data_plot <- data_model[, c("Date", "R_CTG", "R_VNI", "D_FX")] |>
  pivot_longer(
    cols = c(R_CTG, R_VNI, D_FX),
    names_to = "Bien",
    values_to = "GiaTri"
  )

data_plot$Bien <- factor(
  data_plot$Bien,
  levels = c("R_CTG", "R_VNI", "D_FX"),
  labels = c("Loi suat CTG", "Loi suat VNINDEX", "Bien dong ty gia")
)

ggplot(data_plot, aes(x = Date, y = GiaTri)) +
  geom_line() +
  facet_wrap(~Bien, ncol = 1, scales = "free_y") +
  labs(
    title = "Bieu do chuoi thoi gian cua cac bien trong mo hinh",
    x = "Date",
    y = NULL
  ) +
  theme_minimal()
# kiểm định tính dừng adf
adf_ctg <- adf.test(data_model$R_CTG)
adf_vni <- adf.test(data_model$R_VNI)
adf_fx  <- adf.test(data_model$D_FX)
adf_ctg
adf_vni
adf_fx
# kiểm định nhân quả granger
granger_vni <- grangertest(R_CTG ~ R_VNI, order = 2, data = data_model)
granger_fx  <- grangertest(R_CTG ~ D_FX, order = 2, data = data_model)
granger_vni
granger_fx
# kiểm định đa cộng tuyến
model_vif <- lm(R_CTG ~ R_VNI + D_FX, data = data_model)
vif(model_vif)
# arima và arimax
xreg_matrix <- as.matrix(data_model[, c("R_VNI", "D_FX")])
fit_arima <- auto.arima(data_model$R_CTG, stationary = TRUE)
fit_arimax <- auto.arima(data_model$R_CTG, xreg = xreg_matrix, stationary = TRUE)
fit_arima
fit_arimax
summary(fit_arimax)
# kiểm định phần dư arimax
res_arimax <- residuals(fit_arimax)
Box.test(res_arimax, lag = 10, type = "Ljung-Box")
jarque.bera.test(res_arimax)
ArchTest(res_arimax, lags = 5)
# biểu đồ phần dư
tsdisplay(res_arimax, main = "ACF PACF cua phan du ARIMAX")
qqnorm(res_arimax)
qqline(res_arimax, col = 2)
acf(res_arimax^2, main = "ACF cua binh phuong phan du")
qqnorm(res_arimax, main = "Biểu đồ Q-Q của phần dư mô hình ARIMAX")
qqline(res_arimax, col = "red", lwd = 2)
# dự báo giá 10 phiên cuối bằng arimax
n_test <- 10
train_data <- head(data_model, nrow(data_model) - n_test)
test_data  <- tail(data_model, n_test)
xreg_train <- as.matrix(train_data[, c("R_VNI", "D_FX")])
xreg_test  <- as.matrix(test_data[, c("R_VNI", "D_FX")])
fit_arimax_bt <- auto.arima(train_data$R_CTG, xreg = xreg_train, stationary = TRUE)
fc_arimax <- forecast(fit_arimax_bt, xreg = xreg_test, h = n_test)
# bảng dự báo lợi suất
forecast_return <- data.frame(
  Date = test_data$Date,
  R_CTG_ThucTe = test_data$R_CTG,
  R_CTG_DuBao = as.numeric(fc_arimax$mean)
)
forecast_return
# bảng dự báo giá
last_price <- tail(train_data$CTG_Price, 1)
ret_forecast <- as.numeric(fc_arimax$mean)

price_forecast <- last_price * exp(cumsum(ret_forecast))

forecast_price <- data.frame(
  Date = test_data$Date,
  Gia_ThucTe = test_data$CTG_Price,
  Gia_DuBao = price_forecast
)
forecast_price
# biểu đồ giá thực tế và giá dự báo
plot(
  test_data$Date, test_data$CTG_Price,
  type = "l", col = "red", lwd = 2,
  xlab = "Date", ylab = "Gia CTG (VND)",
  main = "So sanh gia CTG thuc te va gia du bao"
)
lines(test_data$Date, price_forecast, col = "blue", lwd = 2)
legend(
  "topleft",
  legend = c("Gia thuc te", "Gia du bao"),
  col = c("red", "blue"),
  lwd = 2,
  bty = "n")
# chỉ tiêu sai số dự báo giá
MAE <- mean(abs(forecast_price$Gia_ThucTe - forecast_price$Gia_DuBao))
MAPE <- mean(abs((forecast_price$Gia_ThucTe - forecast_price$Gia_DuBao) / forecast_price$Gia_ThucTe)) * 100
MAE
MAPE



