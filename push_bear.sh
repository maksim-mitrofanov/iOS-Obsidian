#!/bin/zsh

# Укажи адреса исходного файла и папки назначения
SOURCE_PATH="/Users/maksim/Library/Group Containers/9K33E3U3T4.net.shinyfrog.bear/Application Data/database.sqlite"
DESTINATION_PATH="/Users/maksim/iOS-Database"

# Функция для проверки существования адресов
check_paths() {
    if [ ! -e "$SOURCE_PATH" ]; then
        echo "Исходный файл не найден: $SOURCE_PATH"
        exit 1
    fi

    if [ ! -d "$DESTINATION_PATH" ]; then
        echo "Папка назначения не найдена: $DESTINATION_PATH"
        exit 1
    fi
    }

# Функция копирования файла
copy_file() {
    # Выполняем копирование
    cp "$SOURCE_PATH" "$DESTINATION_PATH"

    # Проверяем успешность копирования
    if [ $? -eq 0 ]; then
        echo "Файл успешно скопирован в $DESTINATION_PATH"
    else
        echo "Ошибка при копировании файла"
        exit 1
    fi
}

# Удаление существующего файла
delete_existing_file() {
    local DEST_FILE="${DESTINATION_PATH}/$(basename "$SOURCE_PATH")"
    if [ -e "$DEST_FILE" ]; then
        echo "Файл уже существует в папке назначения: $DEST_FILE. Удаляем..."
        rm "$DEST_FILE"
        if [ $? -eq 0 ]; then
            echo "Файл успешно удалён."
        else
            echo "Ошибка при удалении файла!"
            exit 1
        fi
    fi
}

# Обновление git.
git_add_and_push() {
    echo "Выполняю синхронизацию git."
    current_date=$(date "+%Y-%m-%d %H:%M:%S")

    git add .
    git commit -m "Update database at: $current_date."
    git push
}

# Переход в destination directory.
go_to_destination_dir() {
    if [ -d "$DESTINATION_PATH" ]; then
        cd "$DESTINATION_PATH"
        echo "Перешёл в директорию: $DESTINATION_PATH"
    else
        echo "Ошибка: Папка $DESTINATION_PATH не существует!"
        exit 1
    fi
}

# Основная программа
check_paths
delete_existing_file
copy_file
go_to_destination_dir
git_add_and_push
