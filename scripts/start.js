const process = require("child_process");
const chokidar = require("chokidar");

build();
serve();

chokidar.watch("src/**/*", { ignoreInitial: true }).on("all", build);

function build() {
  process.spawn("sh", ["scripts/build.sh"], { stdio: "inherit" });
}

function serve() {
  process.spawn("npx", ["http-server", "-c-1", "public"], { stdio: "inherit" });
}
