Ниже — финальная версия архитектурного документа.
Кратко, строго, без пояснительной болтовни.

---

# Event-Driven Operation Architecture v1.0

## 1. Общая модель

Архитектура основана на event-driven взаимодействии.

Поток мутации состояния:

```
UI → Intent → Backend → EventStream → EventClient → new Operation → UI
```

Backend — единственный источник истины.
EventClient — единственный владелец клиентского состояния.
Operation — проекция состояния.

---

## 2. Operation

### 2.1 Назначение

Operation — атомарная проекция состояния, способная отрисовать себя.

```dart
abstract class Operation {
  Widget render(BuildContext context);
}
```

### 2.2 Инварианты

1. Operation immutable.
2. Operation не мутирует кэш.
3. Мутация только через Intent → backend.
4. Не хранит EventClient.
5. Не выполняет send/request.
6. Не раскрывает внутреннее состояние.
7. Доступ к внутренней Map невозможен.

---

## 3. Валидация и корректность

1. Operation либо создаётся корректной,
2. либо не создаётся (debug),
3. либо создаётся как ErrorOperation (release).

Валидация не выносится в UI.
UI не проверяет поля Operation.

---

## 4. Мутация состояния

Мутация возможна только через backend round-trip.

Локальные изменения запрещены.

Запрещено:

* менять внутреннюю Map
* изменять состояние в UI
* выполнять optimistic update

Каждое изменение приводит к созданию новой Operation.

---

## 5. OperationIntent (Mutation Layer)

Mutation вынесена в отдельный слой.

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

Запрещено вызывать intent внутри render().

---

## 6. EventClient

EventClient:

* владеет кэшем
* подписан на EventStream
* обновляет состояние
* пересоздаёт Operation

Никакой другой компонент не имеет доступа к кэшу.

---

## 7. DTO

DTO как архитектурная сущность отсутствует.

Допустимы внутренние структурные объекты,
но они:

* не являются публичным API
* не раскрывают состояние
* используются только как внутренняя реализация Operation

Публикуется поведение, а не данные.

---

## 8. Компромиссы

Допустимы отклонения при:

* высокой математической нагрузке
* специфических структурных задачах
* интеграционных ограничениях

Компромисс не должен приводить к раскрытию состояния Operation.

---

## 9. Backend

Backend:

* хранит оперативный кэш
* исполняет бизнес-логику
* генерирует события
* сохраняет события в БД
* транслирует изменения в EventStream

UI не инициирует прямые изменения состояния.

---

## 10. Расширяемость

Архитектура допускает:

* декомпозицию Operation
* добавление lint-правил
* статический авто-сканер требований
* расширение render-вариантов
* внедрение headless режима

Рост не требует изменения базовых принципов.

---
