import type { Config } from "jest";

import { createDefaultPreset } from "ts-jest";

const tsJestTransformCfg = createDefaultPreset().transform;

const config: Config = {
  coverageReporters: ["text", "text-summary", "html", "json", "json-summary"],
  coverageDirectory: "tests/jest/coverage",
  testEnvironment: "node",
  transform: {
    ...tsJestTransformCfg,
  },
  notify: true
};

export default config