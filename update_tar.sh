echo "请输入发布环境:"
read ENV
echo "请输入升级后的版本号:"
read VERSION

MIX_ENV=$ENV mix release --env=$ENV --upgrade

if [ ! -e "tars/$ENV" ]; then
    mkdir -p tars/$ENV
fi

mv ./_build/$ENV/rel/bf_game/releases/$VERSION/bf_game.tar.gz ./tars/$ENV/bf_game-$VERSION.tar.gz
