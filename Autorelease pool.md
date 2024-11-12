
## Autorelease pool 
автоосвобождение объектов пула

#### Наследние Objective - C
В objc для удаления объектов из памяти использовались ключевые слова:
* release - сразу же освобождает объект из памяти.
* autorelease - маркирует объект как "объект временного хранения".

**Autorelease pool** - контейнер, куда добавляются все "объект временного хранения".
* Очищается в момент окончания цикла RunLoop (objc + swift)
* В момент выхода из блока кода `autoreleasepool { }` (swift)

#### Зачем это нужно в Swift?
В Swift используется ARC для управления памятью. Однако, часть системных фреймворков до сих пор опирается на objc код (UIKit, Foundation).

При использовании таких фреймворков нужно учитывать, что объекты временного хранения будут очищаться в момент сброса (drain) дефолтного autorelease pool, а это происходит в конце / начале цикла [[RunLoop]]. 

Мы можем создать собственный autorelease pool, 
что бы удалять временные объекты раньше, чем закончится цикл run loop. 

#### Пример 1: autoreleasepool
На каждой итерации цикла создаётся и удаляется 1 объект типа UIImage.
```
for i in 0..<1000 { 
	autoreleasepool {
		let image = UIImage(named: "hello") 
	} 
}
```

На каждой итерации цикла создаётся 1 объект типа UIImage.
При выходе из цикла удаляется 1000 объектов типа UIImage.
```
for i in 0..<1000 { 
	let image = UIImage(named: "hello") 
}
```

#### Пример 2: RunLoop + autoreleasepool
Здесь RunLoop автоматически создаёт и очищает autorelease pool в начале и конце каждой итерации, освобождая временный объект.

```
let runLoop = RunLoop.current

Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    let temporaryObject = UIImage(named: "example.png")

}

while runLoop.run(mode: .default, before: .distantFuture) {
    // RunLoop управляет и освобождает память автоматически в конце каждой итерации.
}

```