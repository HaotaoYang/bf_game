echo "请输入版本号:"
read VERSION

MIX_ENV=prod mix release --env=prod 

if [ ! -e "tars" ]; then
	mkdir tars
fi

mv ./_build/prod/rel/bf_game/releases/$VERSION/bf_game.tar.gz ./tars/$VERSION.tar.gz

