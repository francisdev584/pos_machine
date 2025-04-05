class FormatUtils {
  /// Formata um valor double para o formato de moeda brasileiro (R$ 0,00)
  static String formatCurrency(double value) {
    String valueStr = value.toStringAsFixed(2);
    return valueStr.replaceAll('.', ',');
  }

  /// Formata um valor double para o formato de moeda brasileiro com o símbolo (R$ 0,00)
  static String formatCurrencyWithSymbol(double value) {
    return 'R\$ ${formatCurrency(value)}';
  }
}
