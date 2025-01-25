FROM python:3.9-buster

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    libleveldb-dev \
    && rm -rf /var/lib/apt/lists/*

# Клонирование вашего форка ElectrumX
RUN git clone https://github.com/KuksaDV/electrumx-fb /opt/electrumx

WORKDIR /opt/electrumx

# Установка зависимостей Python
RUN pip install --no-cache-dir -r requirements.txt

# Установка ElectrumX
RUN python setup.py install

# Определение переменных окружения
ENV HOME /data
ENV ALLOW_ROOT 1
ENV EVENT_LOOP_POLICY uvloop
ENV DB_DIRECTORY /data
ENV SERVICES=tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000
ENV SSL_CERTFILE ${DB_DIRECTORY}/electrumx.crt
ENV SSL_KEYFILE ${DB_DIRECTORY}/electrumx.key
ENV HOST ""

# Создание директории для данных
RUN mkdir -p ${DB_DIRECTORY}

# Открытие необходимых портов
EXPOSE 50001 50002 50004 8000

# Команда запуска
CMD ["electrumx_server"]
