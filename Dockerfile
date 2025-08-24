FROM python:3.12-alpine3.17

# Установим системные зависимости
RUN apk update && apk add --no-cache \
    chromium \
    chromium-chromedriver \
    tzdata \
    openjdk11-jre \
    curl \
    tar \
    gcc \
    musl-dev \
    python3-dev \
    libffi-dev \
    bash \
    wget

# Установим allure (репорты)
RUN curl -o allure-2.13.8.tgz -Ls https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/2.13.8/allure-commandline-2.13.8.tgz && \
    tar -zxvf allure-2.13.8.tgz -C /opt/ && \
    ln -s /opt/allure-2.13.8/bin/allure /usr/bin/allure && \
    rm allure-2.13.8.tgz

WORKDIR /usr/workspace

# Скопируем зависимости
COPY requirements.txt .

# Установим Python-зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Скопируем остальной проект
COPY . .

CMD ["pytest", "-sv", "--alluredir=allure-results"]
