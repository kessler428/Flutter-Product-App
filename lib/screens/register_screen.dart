import 'package:flutter/material.dart';
import 'package:flutter_products_app/providers/login_form_provider.dart';
import 'package:flutter_products_app/services/services.dart';
import 'package:flutter_products_app/ui/input_decorations.dart';
import 'package:flutter_products_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 180),
              CardContainer(
                  child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text('Registrarse',
                      style: Theme.of(context).textTheme.headline4),
                  const SizedBox(height: 30),

                  ChangeNotifierProvider(
                    create: ( _ ) => LoginFormProvider(),
                    child:  _LoginForm(),
                  )
                ],
              )),
              const SizedBox(height: 50),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, 'login'),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all( Colors.indigo.withOpacity(0.1)),
                  shape: MaterialStateProperty.all( StadiumBorder() )
                ),
                child: const Text(
                  'Ya tienes una cuenta?',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  final loginForm = Provider.of<LoginFormProvider>(context);
    return Form(
      key: loginForm.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: inputDecorations.authInputdecoration(
                  labelText: 'Correo electronico',
                  hintText: 'a@expample.com',
                  prefixIcon: Icons.alternate_email_outlined),
              onChanged: ( value ) => loginForm.email = value,
              validator: (value) {
                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp = RegExp(pattern);

                return regExp.hasMatch(value ?? '')
                    ? null
                    : 'Ingrese un correo valido ';
              },
            ),
            const SizedBox(height: 30),
            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              decoration: inputDecorations.authInputdecoration(
                  labelText: 'Contrase??a',
                  hintText: '******',
                  prefixIcon: Icons.lock_outline_sharp),
              onChanged: ( value ) => loginForm.password = value,
              validator: (value) {
                return (value != null && value.length >= 6)
                    ? null
                    : 'La contrase??a debe ser de 6 caracteres';
              },
            ),
            const SizedBox(height: 30),
            MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.deepPurple,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15),
                    child: Text(
                      loginForm.isLoading
                      ? 'Ingresando'
                      : 'Ingresar',
                      style: const TextStyle(color: Colors.white),
                    )),
                onPressed: loginForm.isLoading ? null : () async {

                  FocusScope.of(context).unfocus();

                  final authService = Provider.of<AuthService>(context, listen: false);

                  if(!loginForm.isValidForm()) return;

                  loginForm.isLoading = true;

                  final String? errorMessage = await authService.createUser(
                    loginForm.email,
                    loginForm.password
                  );

                  if ( errorMessage == null) {
                    Navigator.pushReplacementNamed(context, 'home');
                  } else {
                    loginForm.isLoading = false;
                  }
                })
          ],
        ));
  }
}
