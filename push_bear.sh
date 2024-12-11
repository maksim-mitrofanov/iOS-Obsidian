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
}

update_git() {
    echo "Обновляю репозиторий из удалённого источника..."
    cd "$DESTINATION_PATH" || exit
    git fetch && git pull

    if [ $? -eq 0 ]; then
            echo "Репозиторий успешно обновлён."
    else
            echo "Ошибка при обновлении репозитория!"
            exit 1
    fi
}

replace_file() {
    local DEST_FILE="${DESTINATION_PATH}/$(basename "$SOURCE_PATH")"

    if [ -e "$DEST_FILE" ]; then
        echo "Копирую файл из $DEST_FILE в $SOURCE_PATH..."
        cp "$DEST_FILE" "$SOURCE_PATH"

        if [ $? -eq 0 ]; then
            echo "Файл успешно заменён в $SOURCE_PATH"
        else
            echo "Ошибка при замене файла!"
            exit 1
        fi
    else
        echo "Файл для замены не найден: $DEST_FILE"
        exit 1
    fi
}

# Основная программа
check_paths
update_git
replace_file
