#set( $symbol_dollar = '$' )
#!/bin/sh

export COMPOSE_FILE_PATH="${symbol_dollar}{PWD}/target/classes/docker/docker-compose.yml"

if [ -z "${symbol_dollar}{M2_HOME}" ]; then
  export MVN_EXEC="mvn"
else
  export MVN_EXEC="${symbol_dollar}{M2_HOME}/bin/mvn"
fi

start() {
    docker volume create ${rootArtifactId}-acs-volume
    docker volume create ${rootArtifactId}-db-volume
    docker volume create ${rootArtifactId}-ass-volume
    docker-compose -f "${symbol_dollar}COMPOSE_FILE_PATH" up --build -d
}

down() {
    if [ -f "${symbol_dollar}COMPOSE_FILE_PATH" ]; then
        docker-compose -f "${symbol_dollar}COMPOSE_FILE_PATH" down
    fi
}

purge() {
    docker volume rm -f ${rootArtifactId}-acs-volume
    docker volume rm -f ${rootArtifactId}-db-volume
    docker volume rm -f ${rootArtifactId}-ass-volume
}

build() {
    if ! ${symbol_dollar}MVN_EXEC clean package
    then
        echo mvn clean package failed
        exit 1
    fi
}

tail() {
    docker-compose -f "${symbol_dollar}COMPOSE_FILE_PATH" logs -f
}

tail_all() {
    docker-compose -f "${symbol_dollar}COMPOSE_FILE_PATH" logs --tail="all"
}

prepare_test() {
    if ! ${symbol_dollar}MVN_EXEC verify -DskipTests=true
    then
        echo mvn verify -DskipTests=true failed
        exit 1
    fi
}

test() {
    if ${symbol_dollar}MVN_EXEC verify
    then
        echo mvn verify failed
        exit 1
    fi
}

case "${symbol_dollar}1" in
  build_start)
    down
    build
    start
    tail
    ;;
  build_start_it_supported)
    down
    build
    prepare_test
    start
    tail
    ;;
  start)
    start
    tail
    ;;
  stop)
    down
    ;;
  purge)
    down
    purge
    ;;
  tail)
    tail
    ;;
  build_test)
    down
    build
    prepare_test
    start
    test
    tail_all
    down
    ;;
  test)
    test
    ;;
  *)
    echo "Usage: ${symbol_dollar}0 {build_start|build_start_it_supported|start|stop|purge|tail|build_test|test}"
esac
