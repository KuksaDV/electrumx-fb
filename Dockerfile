FROM python:3.7-alpine3.11

COPY ./bin /usr/local/bin

RUN chmod a+x /usr/local/bin/* && \
    apk add --no-cache git build-base openssl cmake bash linux-headers libc6-compat curl \
        gflags-dev snappy-dev zlib-dev bzip2-dev lz4-dev && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.11/main leveldb-dev && \
    echo "=== Building RocksDB from source ===" && \
    curl -L -o rocksdb.tar.gz https://github.com/facebook/rocksdb/archive/refs/tags/v6.29.5.tar.gz && \
    tar -xzf rocksdb.tar.gz && \
    cd rocksdb-6.29.5 && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DWITH_SNAPPY=ON \
          -DWITH_LZ4=ON \
          -DWITH_ZLIB=ON \
          -DWITH_BZ2=ON \
          -DWITH_GFLAGS=ON .. && \
    make -j$(nproc) && \
    make install && \
    cd ../.. && rm -rf rocksdb* && \
    echo "=== RocksDB installed successfully ===" && \
    pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir Cython==0.29.33 && \
    env CXXFLAGS="-std=c++14" pip install --no-cache-dir --force-reinstall --no-binary :all: python-rocksdb && \
    pip install aiohttp pylru plyvel websockets uvloop && \
    git clone https://github.com/KuksaDV/electrumx-fb.git && \
    cd electrumx-fb && \
    python setup.py install && \
    apk del git build-base cmake && \
    rm -rf /tmp/*

VOLUME ["/data"]
ENV HOME /data
ENV ALLOW_ROOT 1
ENV EVENT_LOOP_POLICY uvloop
ENV DB_DIRECTORY /data
ENV SERVICES=tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000
ENV SSL_CERTFILE=${DB_DIRECTORY}/electrumx.crt
ENV SSL_KEYFILE=${DB_DIRECTORY}/electrumx.key
ENV HOST ""
WORKDIR /data

EXPOSE 50001 50002 50004 8000

CMD ["init"]
