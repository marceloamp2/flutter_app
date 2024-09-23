class ApiExceptions implements Exception {
  final Map<String, dynamic> errors;

  const ApiExceptions(this.errors);

  @override
  String toString() {
    String message = 'Ocorreu um erro inesperado!';

    errors.forEach((key, value) {
      message = '';
      for (int i = 0; i < value.length; i++) {
        message += value[i] + '\r\n';
      }
    });

    return message;
  }
}
