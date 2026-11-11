import type FS from 'node:fs'
import type Path from 'node:path'
import type { SyncResolver } from "jest-resolve";

const fs = require("node:fs") as typeof FS;
const path = require("node:path") as typeof Path;

function isWithinDirectory(
  directory: string,
  candidate: string,
): boolean {
  if (!directory || !candidate) {
    return false;
  }

  const relativePath = path.relative(
    path.resolve(directory),
    path.resolve(candidate),
  );

  return (
    relativePath === "" ||
    (
      relativePath !== ".." &&
      !relativePath.startsWith(`..${path.sep}`) &&
      !path.isAbsolute(relativePath)
    )
  );
}

const resolver: SyncResolver = (request, options) => {
  const { basedir, rootDir, defaultResolver } = options;

  const isRelativeRequest =
    request.startsWith("./") || request.startsWith("../");

  const isProjectSource =
    typeof rootDir === "string" &&
    isWithinDirectory(rootDir, basedir) &&
    !basedir.split(path.sep).includes("node_modules");

  if (
    isRelativeRequest &&
    isProjectSource &&
    request.endsWith(".cjs")
  ) {
    const sourceRequest = path.resolve(
      basedir,
      `${request.slice(0, -4)}.cts`,
    );

    if (fs.existsSync(sourceRequest)) {
      return defaultResolver(sourceRequest, options);
    }
  }

  return defaultResolver(request, options);
};

module.exports = resolver;