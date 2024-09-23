const bool isProduction = bool.fromEnvironment('dart.vm.product');

const String developmentUrl = '192.168.0.11';

const String productionUrl = 'personal-trx-api.devmind.com.br';

const baseUrl = isProduction ? productionUrl : developmentUrl;
