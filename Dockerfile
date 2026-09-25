# ---- Этап 1: Сборка приложения ----
FROM rust:1-slim AS builder
WORKDIR /app
# Копируем файлы с зависимостями
COPY Cargo.toml Cargo.lock ./
# Создаём фиктивный main.rs для сборки зависимостей
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
# Удаляем закэшированную пустышку (Cargo меняет дефисы на подчеркивания)
RUN rm -rf target/release/deps/my_rust_app*
# Копируем реальный исходный код
COPY src ./src
# Принудительно обновляем время файла, чтобы Cargo точно пересобрал его
RUN touch src/main.rs
RUN cargo build --release

# ---- Этап 2: Минимальный образ для запуска ----
FROM debian:stable-slim
# Создаём непривилегированного пользователя
RUN useradd --create-home appuser
WORKDIR /home/appuser
# Копируем скомпилированный бинарник
COPY --from=builder /app/target/release/my-rust-app .
# Переключаемся на пользователя
USER appuser
# Запуск приложения
CMD ["./my-rust-app"]
