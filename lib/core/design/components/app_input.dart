import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/tokens.dart';

/// A modern text input field with floating label and validation
class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final bool autocorrect;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: AppAnimation.fast,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceElevatedDarkMode
                : AppColors.surface,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : _hasFocus
                      ? AppColors.primary
                      : (isDark ? AppColors.borderDarkMode : AppColors.border),
              width: _hasFocus || hasError ? 2 : 1.5,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            validator: widget.validator,
            textCapitalization: widget.textCapitalization,
            autocorrect: widget.autocorrect,
            style: AppTypography.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDarkMode
                  : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: _hasFocus
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textSecondaryDarkMode
                              : AppColors.textSecondary),
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                      onTap: widget.onSuffixTap,
                      child: widget.suffixIcon,
                    )
                  : null,
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: AppSpacing.inputPadding,
              labelStyle: AppTypography.bodyMedium.copyWith(
                color: _hasFocus
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textSecondaryDarkMode
                        : AppColors.textSecondary),
              ),
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDarkMode
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ),
        if (hasError || widget.helper != null) ...[
          AppSpacing.verticalXs,
          Text(
            hasError ? widget.error! : widget.helper!,
            style: AppTypography.bodySmall.copyWith(
              color: hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// A password input field with visibility toggle
class AppPasswordInput extends StatefulWidget {
  const AppPasswordInput({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint,
    this.error,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? error;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  State<AppPasswordInput> createState() => _AppPasswordInputState();
}

class _AppPasswordInputState extends State<AppPasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppInput(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      error: widget.error,
      enabled: widget.enabled,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
      focusNode: widget.focusNode,
      prefixIcon: Icons.lock_outline,
      suffixIcon: Icon(
        _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: AppColors.textSecondary,
      ),
      onSuffixTap: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }
}

/// A dropdown/select input field
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.enabled = true,
    this.prefixIcon,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final String? error;
  final bool enabled;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = error != null && error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceElevatedDarkMode
                : AppColors.surface,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : (isDark ? AppColors.borderDarkMode : AppColors.border),
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: enabled ? onChanged : null,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: 20,
                      color: isDark
                          ? AppColors.textSecondaryDarkMode
                          : AppColors.textSecondary,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: AppSpacing.inputPadding,
              labelStyle: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDarkMode
                    : AppColors.textSecondary,
              ),
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDarkMode
                    : AppColors.textTertiary,
              ),
            ),
            dropdownColor:
                isDark ? AppColors.surfaceElevatedDarkMode : AppColors.surface,
            borderRadius: AppRadius.radiusMd,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark
                  ? AppColors.textSecondaryDarkMode
                  : AppColors.textSecondary,
            ),
            style: AppTypography.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDarkMode
                  : AppColors.textPrimary,
            ),
          ),
        ),
        if (hasError) ...[
          AppSpacing.verticalXs,
          Text(
            error!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// A search input field with clear button
class AppSearchInput extends StatefulWidget {
  const AppSearchInput({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<AppSearchInput> createState() => _AppSearchInputState();
}

class _AppSearchInputState extends State<AppSearchInput> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChange);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.removeListener(_handleTextChange);
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return AppInput(
      controller: _controller,
      hint: widget.hint,
      prefixIcon: Icons.search,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      suffixIcon: _hasText
          ? Icon(
              Icons.close,
              size: 20,
              color: AppColors.textSecondary,
            )
          : null,
      onSuffixTap: _handleClear,
    );
  }
}
