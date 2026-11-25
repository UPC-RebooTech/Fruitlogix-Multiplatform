/// Deployed FruitLogix platform API (Render). Override at build time with
/// `--dart-define=FRUITLOGIX_API_URL=https://...` (e.g. a local backend).
const String fruitLogixApiUrl = String.fromEnvironment(
  'FRUITLOGIX_API_URL',
  defaultValue: 'https://rebootech-fruitlogix-api.onrender.com',
);
