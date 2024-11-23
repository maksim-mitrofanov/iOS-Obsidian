
```
var array1 = [1, 2, 3]
var array2 = array1  // array1 и array2 ссылаются на один и тот же массив

array1.append(4) 
print(array1)        // [1, 2, 3, 4]
print(array2)        // [1, 2, 3, 4]

```

Используем Array (ValueType), но получили поведение ReferenceType.