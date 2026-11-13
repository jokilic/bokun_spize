import {defineConfig} from "vitest/config";

/**
 * Vitest configuration for pure scheduling tests and Firestore emulator coverage
 */
export default defineConfig({
  test: {
    // Firebase Admin and Luxon run in Node rather than a browser-like environment
    environment: "node",
    coverage: {
      // Measure production Functions code without counting test setup
      include: ["src/**/*.ts"],
    },
  },
});
