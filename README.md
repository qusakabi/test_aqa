# LiveCoding — UI Tests (Pytest, Selenium, Allure, Docker)

[![UI Tests](https://github.com/qusakabi/test_aqa/actions/workflows/config.yml/badge.svg?branch=master)](https://github.com/qusakabi/test_aqa/actions/workflows/config.yml)

End‑to‑end UI тесты на Python (pytest + selenium) с отчётами Allure. Запуск как локально, так и в GitHub Actions с автогенерацией отчёта и деплоем истории отчётов в gh-pages.

Основные файлы/каталоги:
- Workflow CI: [.github/workflows/config.yml](.github/workflows/config.yml)
- Docker Compose: [docker-compose.yml](docker-compose.yml)
- Docker image: [Dockerfile](Dockerfile)
- Тесты: [tests/](tests/)
- Страницы (PageObjects): [pages/](pages/)
- Базовая обвязка: [base/](base/)
- Конфиги/данные/ссылки: [config/](config/)

## Быстрый старт (локально с Docker Compose)

Требования:
- Docker + Docker Compose v2 (docker compose)
- Учетные данные тестового пользователя (переменные окружения)

1) Установите переменные окружения:
```bash
export LOGIN="your_login"
export PASSWORD="your_password"
```

2) Запустите тесты в контейнере:
```bash
docker compose up --build --exit-code-from regression
```

3) Сгенерируйте Allure-отчёт:
```bash
docker compose run --rm regression /bin/sh -c 'allure generate allure-results --clean -o allure-report'
```

4) Откройте статический отчёт локально (файл-проводник/браузер):
- Откройте файл: allure-report/index.html

Примечание:
- Контейнер и хост связаны бинд-монтом (./ -> /usr/workspace), Allure-артефакты появятся в каталоге проекта: allure-results и allure-report.
- В [docker-compose.yml](docker-compose.yml) сервис запускается от UID/GID хоста (через переменные HOST_UID/HOST_GID), чтобы не возникало проблем с правами.

## Запуск без Docker (опционально)

Требования:
- Python 3.12+
- Установленный браузер/драйвер для Selenium (или webdriver-manager из зависимостей)

Команды:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest -sv --alluredir=allure-results
# Если установлен Allure CLI локально:
allure generate allure-results --clean -o allure-report
```

## CI/CD: GitHub Actions

Workflow: [.github/workflows/config.yml](.github/workflows/config.yml)

Триггеры:
- push (ветки: master, main)
- pull_request
- ручной запуск (workflow_dispatch)

Основные шаги:
- Проверка Docker/Compose версий
- Запуск тестов через docker compose
- Перенос истории Allure из ветки gh-pages (если есть)
- Генерация Allure-отчёта
- Обновление истории отчётов и деплой на gh-pages

Секреты репозитория:
- LOGIN — логин тестового пользователя
- PASSWORD — пароль тестового пользователя
- CI_TOKEN — токен для деплоя на gh-pages (альтернатива: использовать встроенный GITHUB_TOKEN c permissions: contents: write)

Ветка gh-pages:
- Workflow делает дополнительный checkout ветки gh-pages в ./.github/gh-pages.
- История отчётов хранится в ./.github/gh-pages/history и переиспользуется между запусками.

## Структура проекта

- [base/](base/): базовые классы страниц и тестов
  - [base/base_page.py](base/base_page.py)
  - [base/base_test.py](base/base_test.py)
- [pages/](pages/): Page Object’ы (экран логина, дашборд, профиль и т.п.)
  - [pages/login_page.py](pages/login_page.py)
  - [pages/dashboard_page.py](pages/dashboard_page.py)
  - [pages/personal_page.py](pages/personal_page.py)
- [tests/](tests/): сами тесты
  - [tests/feature_profile_test.py](tests/feature_profile_test.py)
- [config/](config/): тестовые данные и ссылки
  - [config/data.py](config/data.py)
  - [config/links.py](config/links.py)

## Типичные проблемы и их решение

- Workflow не появляется в Actions:
  - Убедитесь, что в [.github/workflows/config.yml](.github/workflows/config.yml) есть триггеры push/pull_request, и изменения запушены в default-ветку (master/main).
- Ошибка “docker-compose: command not found”:
  - Используйте Docker Compose v2: команды вида docker compose ... (без дефиса).
- Ошибки прав (Permission denied) для allure-results:
  - Сервис запускается от HOST_UID/HOST_GID, а каталог создаётся на хосте до запуска; это решает проблемы прав. См. [docker-compose.yml](docker-compose.yml) и workflow.
- Ошибка копирования истории “cp: cannot stat ... gh-pages/history/*” на первом запуске:
  - Шаги в CI теперь условные: если истории нет, копирование пропускается без падения.
- Деплой на gh-pages падает из‑за токена:
  - Проверьте, что задан CI_TOKEN, или переключите шаг деплоя на GITHUB_TOKEN и добавьте permissions: contents: write.

## Лицензия

Проект предоставляется "как есть". При необходимости добавьте файлы лицензии и/или правок в README.
