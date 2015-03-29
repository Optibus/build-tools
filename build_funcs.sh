e() {
    echo $(date -u) $1
}

export IMAGE_PREFIX=d.optibus

push() {
    img=d.optibus/$1:$TAG
    e "Pushing $img"
    docker push $img
}

set_tag() {
    if [[ -z "$TAG" ]]; then
        export TAG=$(git show | head -1 | awk '{ print $2 }')
    fi
}

build() {

    export FROM_IMAGE=$IMAGE_PREFIX/$FROM_IMAGE
    export IMAGE=$IMAGE_PREFIX/$IMAGE

    BUILD_TOOLS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    JJ2=$BUILD_TOOLS_DIR/jj2

    if [[ -e "Dockerfile.j2" ]]; then
        e "Generating Dockerfile from template"
        $JJ2 -o Dockerfile -v IMAGE=$IMAGE -v FROM_IMAGE=$FROM_IMAGE Dockerfile.j2
    fi

    e "Building $IMAGE based on $FROM_IMAGE"
    if [ "$NO_DOCKER_CACHE" = true ]; then
        e "Building without docker cache (this will take longer than usual)"
        docker build --no-cache=true $@ -t $IMAGE .
    else    
        docker build $@ -t $IMAGE .
    fi
    e "$IMAGE built."
}

export BUILD_TOOLS_LOADED=1
