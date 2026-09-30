import 'package:flutter/material.dart';

import '../api.dart';
import '../data.dart';
import '../legal_texts.dart';
import '../main.dart';
import 'legal_screen.dart';
import 'shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _age = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _lastName.dispose();
    _firstName.dispose();
    _age.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez valider les conditions d'accès pour continuer."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final fullName = '${_firstName.text.trim()} ${_lastName.text.trim()}'.trim();
      final ageNum = int.tryParse(_age.text.trim()) ?? 18;
      await Repo.register(fullName, _email.text.trim(), _password.text, age: ageNum);
      await app.refresh();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Shell()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _googleSignUp(BuildContext context) async {
    final googleEmail = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              _GoogleGIcon(),
              SizedBox(width: 10),
              Text('Inscription Google', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sélectionnez ou saisissez votre compte Google :', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'votre.nom@gmail.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Continuer'),
            ),
          ],
        );
      },
    );
    if (googleEmail == null || googleEmail.isEmpty || !googleEmail.contains('@')) return;

    // Pré-remplir l'email et un mot de passe par défaut pour simplifier
    setState(() {
      _email.text = googleEmail;
      final parts = googleEmail.split('@')[0].split('.');
      if (parts.isNotEmpty) {
        _firstName.text = parts[0][0].toUpperCase() + parts[0].substring(1);
      }
      if (parts.length > 1) {
        _lastName.text = parts[1][0].toUpperCase() + parts[1].substring(1);
      }
      _password.text = 'GooglePass2026!';
      _confirm.text = 'GooglePass2026!';
      _acceptTerms = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compte Google pré-rempli. Veuillez renseigner votre âge.')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              children: [
                Center(
                  child: Column(
                    children: [
                      const Logo(height: 80),
                      const SizedBox(height: 8),
                      const Text(
                        'BAOU FINANCE',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Créer un compte',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Rejoignez BAOU Finance en quelques secondes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // 1. Bouton Inscription Google
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _googleSignUp(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  icon: const _GoogleGIcon(),
                  label: const Text(
                    "S'inscrire avec Google",
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 18),

                // Séparateur
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OU AVEC UN EMAIL',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Nom & Prénom
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _lastName,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Nom requis' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _firstName,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Prénom'),
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Prénom requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. Âge
                TextFormField(
                  controller: _age,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Âge',
                    hintText: 'Ex: 25',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null) return 'Âge requis';
                    if (n < 18) return 'Vous devez avoir au moins 18 ans';
                    if (n > 120) return 'Âge invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // 4. E-mail
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => (v ?? '').contains('@') ? null : 'E-mail valide requis',
                ),
                const SizedBox(height: 12),

                // 5. Mot de passe (1ère fois)
                TextFormField(
                  controller: _password,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  validator: (v) => (v ?? '').length >= 4 ? null : '4 caractères minimum',
                ),
                const SizedBox(height: 12),

                // 6. Confirmer le mot de passe (2ème fois)
                TextFormField(
                  controller: _confirm,
                  obscureText: _hideConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_hideConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                    ),
                  ),
                  validator: (v) => v == _password.text ? null : 'Les mots de passe ne correspondent pas',
                ),
                const SizedBox(height: 16),

                // 7. Validation des conditions d'accès
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _acceptTerms ? brandGreen.withValues(alpha: 0.5) : Colors.grey.shade200),
                  ),
                  child: CheckboxListTile(
                    value: _acceptTerms,
                    onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                    activeColor: brandGreen,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      "J'ai lu et je valide les conditions générales d'accès et d'utilisation de BAOU Finance.",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    subtitle: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: "Conditions d'accès & CGU",
                            text: cguText,
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "Voir les mentions légales et conditions d'accès",
                          style: TextStyle(fontSize: 12, color: brandOrange, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 8. Bouton de validation
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer mon compte'),
                ),
                const SizedBox(height: 12),

                // Déjà un compte ?
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "Vous avez déjà un compte ? ", style: TextStyle(color: Colors.black54)),
                          TextSpan(text: "Se connecter", style: TextStyle(color: brandGreen, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _GoogleGIcon extends StatelessWidget {
  const _GoogleGIcon();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: _GoogleLogoPainter(),
        ),
      );
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final stroke = size.width * 0.22;

    final red = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.stroke..strokeWidth = stroke;
    final yellow = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.stroke..strokeWidth = stroke;
    final green = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.stroke..strokeWidth = stroke;
    final blue = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.stroke..strokeWidth = stroke;

    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    canvas.drawArc(rect, 3.14 * 1.15, 3.14 * 0.7, false, red);
    canvas.drawArc(rect, 3.14 * 0.65, 3.14 * 0.5, false, yellow);
    canvas.drawArc(rect, 3.14 * 0.15, 3.14 * 0.5, false, green);
    canvas.drawArc(rect, 3.14 * 1.85, 3.14 * 0.3, false, blue);

    final barPaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(center.dx - 1, center.dy - stroke / 2, radius, stroke), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
