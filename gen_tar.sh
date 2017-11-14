echo "请输入发布环境:"
read ENV

APP=$(grep 'app:' mix.exs | cut -d: -f3 | cut -d, -f1)
VERSION=$(grep 'version' mix.exs | cut -d\" -f2)
echo $APP
echo $VERSION

MIX_ENV=$ENV mix release --env=$ENV

if [ ! -e "tars/$ENV" ]; then
	mkdir -p tars/$ENV
fi

cp ./_build/$ENV/rel/$APP/releases/$VERSION/$APP.tar.gz ./tars/$ENV/$APP-$VERSION.tar.gz
