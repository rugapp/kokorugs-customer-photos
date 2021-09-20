const process = require("child_process");
const chokidar = require("chokidar");

build();
serve();

chokidar.watch("src/**/*", { ignoreInitial: true }).on("all", build);

function build() {
  process.spawn("sh", ["scripts/build.sh"], { stdio: "inherit" });
}

function serve() {
  process.spawn(
    "firebase",
    ["emulators:start", "--only", "hosting,functions"],
    { stdio: "inherit" }
  );
}
