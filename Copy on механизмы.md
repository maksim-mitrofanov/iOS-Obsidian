
### Copy on механизмы
оптимизации для работы с ValueType

##### Зачем нужны?

В Swift есть условно несколько подтипов объектов ValueType. 
* коллекции `String, Array, Set`
* примитивные объекты `Bool, Int, Double` 
* структуры и перечисления.

Не все ValueType копируются одинаково. 
Механизмы copy on используются для оптимизации работы с ValueType.

#### Copy on Write:
Самый используемый механизм оптимизации в Swift. 
Откладывает создание копии структуры до момента её мутации.

**Пример кода:**
Копия arrayA создаётся только в тот момент, когда изменяется arrayB.
```
var arrayA = [1, 2, 3]
var arrayB = arrayA // оба массива указывают на одни и те же данные.

arrayB.append(4) // В этот момент создается копия данных для arrayB

arrayA - [1, 2, 3]
arrayB - [1, 2, 3, 4]
```

**Важно: баг при изменении**
Если в примере выше изменить arrayA, то arrayB также обновится. 
Оба массива будут иметь значение `[1, 2, 3, 4]`.

Получается, arrayB обновился по ссылке.
Значит мы получаем [[Поведение коллекций как reference type]].
