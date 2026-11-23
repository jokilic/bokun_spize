/** Reads an optional positive integer from the Functions environment */
export function getAIIntegerSetting(name: string, defaultValue: number): number {
  const value = Number(process.env[name] ?? defaultValue);

  if (!Number.isSafeInteger(value) || value < 1) {
    throw new Error(`${name} must be a positive integer`);
  }

  return value;
}
