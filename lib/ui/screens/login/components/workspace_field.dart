import 'package:flutter/material.dart';

import '../../../../core/resources/constants.dart';
import 'login_styles.dart';

/// Workspace (tenant). Fixed to [AppConstants.defaultTenantSlug] in this app,
/// so it is shown read-only.
class WorkspaceField extends StatelessWidget {
  const WorkspaceField({super.key});

  @override
  Widget build(BuildContext context) {
    const String slug = AppConstants.defaultTenantSlug;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LoginFieldLabel("Workspace"),
        TextFormField(
          initialValue: slug,
          readOnly: true,
          enableInteractiveSelection: false,
          style: LoginStyle.fieldText,
          decoration: LoginStyle.input(
              hint: "Workspace", icon: Icons.apartment_outlined),
        ),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.check_circle_outline,
              color: LoginStyle.success, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(TextSpan(
              style: const TextStyle(color: LoginStyle.success, fontSize: 15),
              children: const [
                TextSpan(
                    text: slug, style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: " workspace selected"),
              ],
            )),
          ),
        ]),
      ],
    );
  }
}
