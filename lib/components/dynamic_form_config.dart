// lib/components/dynamic_form_config.dart

enum FormFieldType { text, number, date, dropdown }

class FormFieldConfig {
  final String key;
  final String label;
  final FormFieldType type;
  final bool isRequired;
  final List<String>? dropdownOptions; // Only needed if type == FormFieldType.dropdown

  const FormFieldConfig({
    required this.key,
    required this.label,
    this.type = FormFieldType.text,
    this.isRequired = true,
    this.dropdownOptions,
  });
}