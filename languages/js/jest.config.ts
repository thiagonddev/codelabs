import type { Config } from "jest";

import { createDefaultPreset } from "ts-jest";

const tsJestTransformCfg = createDefaultPreset().transform;

const config: Config = {
  coverageReporters: ["text", "text-summary", "html", "json", "json-summary"],
  coverageDirectory: "tests/jest/coverage",
  testEnvironment: "node",

  resolver: "<rootDir>/jest.resolver.ts",

  transform: {
    ...tsJestTransformCfg,
    "^.+\\.cts$": "ts-jest",
  },

  notify: true,
};

export default config;