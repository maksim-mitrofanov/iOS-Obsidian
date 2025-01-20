# Copy on механизмы в Swift
механизмы копирования ValueType объектов

### Что такое и зачем нужны Copy on механизмы?
В Swift объекты типа ValueType передаются через копии, а не по ссылке.
Можно выделить три способа копирования ValueType:
* Копирование примитивных типов (int, bool, float).
* Копирование enum и struct.
* Копирование коллекций.

### Копирование примитивных типов: Copy on Assign.
Размер примитивных value type - всегда небольшой и всегда известен заранее, 
а значит они точно поместятся в стэк. 

Поэтому, копия примитивного value type создаётся сразу же при присовении.
```
let value1 = 54
let value2 = value1
	создана копия value1.
```

Что бы понять, что копия дейстиветльно создана, посмотрим на LLVM IR[^1]
```
call void @llvm.memcpy.p0.p0.i64(
	ptr align 8 @"$s5test16value2Sivp",
	ptr align 8 @"$s5test16value1Sivp", 
i64 8, i1 false)
```

`llvm.memcpy` - копирование данных.
`ptr align 8 @"$s5test16value2Sivp` - копируем 8 байт в переменную value2
`ptr align 8 @"$s5test16value2Sivp` - копируем 8 байт из переменной value1
---
### Копирование enum и struct: Copy on Assign с подвохом.
Условно говоря, enum и struct могут быть двух типов:
	- Без ссылок на reference type.
	- С вложенными reference type.

#### Пример 1: Без ссылок на reference type.
Обычные «чистые» valueTypе, которые не содержит ссылок на reference type - копируются при присовении, как и примитивные valueType.

#### Пример 2: С вложенными reference type.
Если же struct или enum хранят указатель на ReferenceType, то:
	- сам ValueType копируется при присовении.
	- вложенный ReferenceType **не копируeтся**, а передаётся по ссылке.
```
let value1 = MyStruct(object: MyClass(data: 1))
let value2 = value1

value2.object.data = 8
print(value1.object.data) // видим 8
```

**LLVM IR** (упрощённая версия)
```
%4 = call swiftcc ptr @"$s21struct_with_reference12CustomObject"(i64 1) 
	создание CustomObject с начальным значением 1.

%5 = call swiftcc ptr @"$s21struct_with_reference12CustomStruct"(ptr %4)
	создание CustomStruct с объектом из регистра %4 (создали выше).

store ptr %5, ptr @"$s21struct_with_reference6value1", align 8
	храним объект из регистра %4 в переменную value1
		
%6 = load ptr, ptr @"$s21struct_with_reference6value1", align 8
	запишем объект из переменной value1 в регистр %6

%7 = call ptr @swift_retain(ptr returned %6) #2
	вызов метода retain для объекта в регистре %6

store ptr %6, ptr @"$s21struct_with_reference6value2", align 8
	запишем объект из регистра %6 в value2
```

#### Важно!
При вызове метода `retain` для valueType происходит вызов этого же метода 
для всех вложенных referenceType.
- - -
### Копирование коллекций: Copy on Write.
Отдельный механизм работы с ValueType - копирование коллекций. 
О реализации коллекций в Swift можно прочитать: [[Коллекции в Swift]].

Кратко про коллекции в Swift:
* Коллекция имеет управляющую структуру и буфер памяти.
* Управляющая структура управляет содержимым при помощи буфера памяти.
* Буфер памяти может определить, сколько на него ссылок (одна или больше).

При присовении коллекции к перемнной происходит:
1. В переменную передаётся указатель на управляющую структуру.
2. В буфере управляющей структуры поле `isKnownUniquelyReferenced` равно `false`.
3. Сама управляющая структура и содержимое коллекции не копируются.

При мутации коллекции, чей буфер возвращает `false` для  `isKnownUniquelyReferenced`:
1. Создаётся копия управляющей структуры и всего её содержимого.
2. У скопированной коллекции поле `isKnownUniquelyReferenced` теперь на `true`
3. Содержимое коллекции меняется согласно мутации.

#### Пример кода:
```
var collection1 = [1, 2, 3]
var collection2 = collection1
	// на текущий момент collection1 хранит указатель на collection2

collection1.insert(4, at: 0)
	// до выполнения insert видим, что управляю
```

**Разбор работы: Copy on Write**
О том, что при работе массива используется Copy On Write, можно узнать из source файлов Swift.
![](Copy%20on%20%D0%BC%D0%B5%D1%85%D0%B0%D0%BD%D0%B8%D0%B7%D0%BC%D1%8B%20%D0%B2%20Swift/image.png)

Видим функции `beginCOWMutation` и `endCOWMutation` в исходниках ArrayBuffer.swift.
![](Copy%20on%20%D0%BC%D0%B5%D1%85%D0%B0%D0%BD%D0%B8%D0%B7%D0%BC%D1%8B%20%D0%B2%20Swift/image%202.png)
![](Copy%20on%20%D0%BC%D0%B5%D1%85%D0%B0%D0%BD%D0%B8%D0%B7%D0%BC%D1%8B%20%D0%B2%20Swift/image%203.png)
#writing

[^1]: LLVM IR - промежуточное представление Swift кода при компиляции. В примерах используестя компиляция без оптимизаций: `swiftc -emit-ir -Onone`
