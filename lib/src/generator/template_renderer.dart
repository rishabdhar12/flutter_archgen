class TemplateRenderer {
  const TemplateRenderer();

  String render(String template, Map<String, String> variables) {
    var output = template;
    for (final entry in variables.entries) {
      output = output.replaceAll('{{${entry.key}}}', entry.value);
    }
    return output;
  }
}
