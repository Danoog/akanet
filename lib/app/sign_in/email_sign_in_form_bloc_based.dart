import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:akanet/app/sign_in/email_sign_in_model.dart';
import 'package:akanet/app/sign_in/email_sing_in_bloc.dart';
import 'package:akanet/common_widgets/form_submit_button.dart';
import 'package:akanet/common_widgets/show_exception_alert_dialog.dart';
import 'package:akanet/services/auth.dart';

class EmailSignInFormBlocBased extends StatefulWidget {
  EmailSignInFormBlocBased({@required this.bloc});
  final EmailSignInBloc bloc;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Provider<EmailSignInBloc>(
      create: (_) => EmailSignInBloc(auth: auth),
      child: Consumer<EmailSignInBloc>(
        builder: (_, bloc, __) => EmailSignInFormBlocBased(
          bloc: bloc,
        ),
      ),
      dispose: (_, bloc) => bloc.dispose(),
    );
  }

  @override
  _EmailSignInFormBlocBasedState createState() =>
      _EmailSignInFormBlocBasedState();
}

class _EmailSignInFormBlocBasedState extends State<EmailSignInFormBlocBased> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      await widget.bloc.submit();
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      showExceptionAlertDialog(
        context,
        title: "Sign in Faild",
        exception: e,
      );
    }
  }

  void _emailEditingComplete(EmailSignInModel model) {
    final newFocus = model.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _toggleForm() {
    widget.bloc.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChirlder(EmailSignInModel model) {
    return [
      _buildEmailTextField(model),
      SizedBox(
        height: 10.0,
      ),
      _buildPasswordTextField(model),
      SizedBox(
        height: 20.0,
      ),
      FormSubmitButton(
        onPressed: model.canSubmit ? _submit : null,
        text: model.primaryButtonText,
      ),
      SizedBox(
        height: 10.0,
      ),
      TextButton(
        onPressed: !model.isLoading ? _toggleForm : null,
        child: Text(model.secondaryButtonText),
      ),
    ];
  }

  TextField _buildPasswordTextField(EmailSignInModel model) {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
        labelText: "Password",
        errorText: model.passwordErrorText,
        enabled: model.isLoading == false,
      ),
      textInputAction: TextInputAction.done,
      obscureText: true,
      onEditingComplete: _submit,
      onChanged: widget.bloc.updatePasswor,
    );
  }

  TextField _buildEmailTextField(EmailSignInModel model) {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "test@test.com",
        errorText: model.emailErrorText ,
        enabled: model.isLoading == false,
      ),
      // autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _emailEditingComplete(model),
      onChanged: widget.bloc.updateEmail,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EmailSignInModel>(
        stream: widget.bloc.modelStream,
        initialData: EmailSignInModel(),
        builder: (context, snapshot) {
          final EmailSignInModel model = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: _buildChirlder(model),
            ),
          );
        });
  }
}
