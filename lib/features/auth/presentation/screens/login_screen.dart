import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../validators.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailCtrl = useTextEditingController();
    final passCtrl = useTextEditingController();
    final obscurePass = useState(true);
    final isValid = useState(false);
    final status = ref.watch(loginStatusProvider);

    // Recalcular validez en cada cambio.
    void recomputeValid() {
      final emailErr = LoginValidators.email(emailCtrl.text);
      final passErr = LoginValidators.password(passCtrl.text);
      isValid.value = emailErr == null && passErr == null;
    }

    useEffect(() {
      emailCtrl.addListener(recomputeValid);
      passCtrl.addListener(recomputeValid);
      return () {
        emailCtrl.removeListener(recomputeValid);
        passCtrl.removeListener(recomputeValid);
      };
    }, const []);

    Future<void> submit() async {
      if (status.loading) return;
      if (!(formKey.currentState?.validate() ?? false)) return;

      ref.read(loginStatusProvider.notifier).setLoading(true);
      final err = await ref.read(authControllerProvider.notifier).login(
            email: emailCtrl.text.trim(),
            password: passCtrl.text,
          );
      if (!context.mounted) return;
      if (err == null) {
        ref.read(loginStatusProvider.notifier).reset();
        // El router redirige automáticamente al cambiar el estado a Authenticated.
      } else {
        ref.read(loginStatusProvider.notifier).setError('Acceso denegado');
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_outline, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      'Iniciar sesión',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: emailCtrl,
                      enabled: !status.loading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      maxLength: 254,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                      validator: LoginValidators.email,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passCtrl,
                      enabled: !status.loading,
                      obscureText: obscurePass.value,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      maxLength: 64,
                      onFieldSubmitted: (_) => submit(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.password_outlined),
                        counterText: '',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: obscurePass.value ? 'Mostrar' : 'Ocultar',
                          icon: Icon(obscurePass.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              obscurePass.value = !obscurePass.value,
                        ),
                      ),
                      validator: LoginValidators.password,
                    ),
                    const SizedBox(height: 16),
                    if (status.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          status.errorMessage!,
                          key: const Key('login-error'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    FilledButton(
                      key: const Key('login-submit'),
                      onPressed: (isValid.value && !status.loading) ? submit : null,
                      child: status.loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                              ),
                            )
                          : const Text('Iniciar sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
