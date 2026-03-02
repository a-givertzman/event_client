# Event-Driven Operation Architecture v1.0

## 1. Общая модель

- Архитектура основана на event-driven взаимодействии.
- Построена на принципах Rich Domain Model.
- Отказываемся от анемичных DTO и UI-слоев с доменной логикой в пользу атомарных объектов Operation, инкапсулирующих поведение.

> - **Принцип**: Публикуй поведение (Operation.render), скрывай данные (_map).
> - **Цель**: Минимизация кода, локализация логики, скорость разработки.

---

## 2. Структура Пайплайна (Pipeline)

Обработка данных идет по конвейеру, где каждый слой решает одну задачу:

- Connect: Управление TCP-сокетом и реконнектами.
- Message: Фрейминг (поиск начала пакета) и сборка буфера.
- Operation.factory: Выбор экземпляра по OperationId.
- Operation.variant: Преобразование payload байтов в конкретный экземпляр Operation.
- EventClient: Диспетчеризация по подписчикам и кэширование.
- UiWidget: Подписка на экземпляр(ы) Operation по имени.

---

## 3. Operation (Атомарная Сущность)

Operation — единственный публичный контракт, атомарная проекция состояния, способная отрисовать себя


```dart
abstract class Operation {
  Widget render(BuildContext context);
}
```

- Отвечает за одну сущность.
- Operation immutable и не изменяет своё внутреннее состояние после создания.
- Мутация через Intent → backend round-trip.
- Не публикует сырые данные (`_map['key']` - приватна).
- Ключи не хардкодятся вне Operation
- Публикует поведение (методы, виджеты, 3d-сущности) - соответствующее сущщности.

### 3.1 Отказ от DTO и Контроль Качества

Вместо написания DTO-классов используется стратегия "Fail Fast & Audit"

1. **Contract Linter (Test)**: Автоматический скрипт (Unit Test), который:
  - Проверяет только Operation-классы
  - Запрашивает эталонную схему у Бэкенда.
  - Сканирует код всех Operation на использование ключей (`_map['key']`).
  - Сверяет структуры и ключи, падает при несовпадении как unit-test.
  - Блокирует git.merge.

2. **Runtime Safety**:
  - **Debug**: assert на наличие ключа -> Crash (сразу видно ошибку).
  - **Release**: `_map['key'] ?? ErrorWidget` -> приложение живет, юзер видит сбойный блок.

### 3.2 Компромиссы

Допустимы отклонения при:

* высокой математической нагрузке
* специфических структурных задачах
* интеграционных ограничениях

Компромисс не должен приводить к раскрытию состояния Operation.

---

## 4. EventClient (Управление Подписками и Памятью)

- **Role**: Владелец подписок и "горячего" кэша.
- **Cache Strategy**: Хранит последние актуальные экземпляры Operation.
- **Garbage Collection**:
  - StreamController.onCancel: Удаление подписки при dispose виджета.
  - DeadStreamScanner: Фоновая задача для очистки "повисших" стримов (страховка).
- **Observability**: Метрики стабильности
  - JitterEventRate (нагрузка при шуме/дребезге)
  - DeadStreamCount (утечки - потерянные подписки).
- **Heartbeats Keep-alive**: ContentKind::Empty, Cot::Req - для поддержания TCP соединения
- **Безопасность** (не MVP): Если это «голый» сокет, то стоит убедиться, что Size проверяется на сервере (чтобы не словить Buffer Overflow атаку, прислав Size = 2GB).

---

## 5. Мутация состояния (Intents)

Изменение состояния — только через сервер round-trip.

- **Запрещено**: Менять `_map` внутри Operation's
- **Запрещено** Вызывать Intent внутри render().
- **Flow**: UI -> Operation.Intent -> Backend -> EventClient -> New Operation -> UI.
- **Типизация**: Известно какой тип мы ожидаем при Operation.intent(client).request()
  * Request декларирует ожидаемый тип ответа.
  * Финальная типизация производится Operation.factory на основании OperationId.

```dart
class OperationIntent<T extends Operation> {
  final EventClient client;
  final T operation;

  OperationIntent(this.client, this.operation);

  void send() {
    client.send(operation);
  }

  Future<Operation> request() {
    return client.request(operation);
  }
}
```

Extension:

```dart
extension OperationIntentExt on Operation {
  OperationIntent intent(EventClient client) {
    return OperationIntent(client, this);
  }
}
```

Использование:

```dart
op.intent(client).send();
```

---

## 6. Виды взаимодействия UI с данными

| Сценарий | Протокол (Cot Flow) | UI Поведение (Widget) |
| --- | --- | --- |
| 1. Long Calc (Затяжной расчет) | Req -> Inf (Прогресс %) -> ReqCon/ReqErr (Итог). | Non-Blocking Monitor. Кнопка отжалась, появился статус "Расчет: 45%...". Пользователь может уйти на другой экран. |
| 2. Mass Update (Транзакция) | Req -> Lock -> ReqCon/ReqErr (Итог). | Modal Blocking Overlay. Интерфейс "замерзает", чтобы предотвратить конфликты данных. |
| 3. Fast Action (+/-) | Cmd -> Inf (Stream) | UI отправляет Cmd, UI не блокируется. Нет ожидания ответов. Stream<Inf> через EventClient пересоздают актуальную Operation. |

---

## 7. Backend (Справочно)

- Хранит оперативный кэш
- Исполняет бизнес-логику
- Генерирует события
- Сохраняет события в БД
- Транслирует изменения в EventStream

---

## 8. Расширяемость

Архитектура допускает:

* декомпозицию Operation
* добавление lint-правил
* статический авто-сканер требований
* расширение render-вариантов
* внедрение headless режима

Рост не требует изменения базовых принципов.

---
