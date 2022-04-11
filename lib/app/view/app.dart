import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import '../../features/number_trivia/presentation/pages/number_trivia_page.dart';
import '../../injection_container.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NumberTriviaBloc>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NumberTriviaPage(),
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.blueAccent,
          colorScheme: ColorScheme.fromSwatch(
            accentColor: Colors.blueAccent,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          useMaterial3: true,
          primaryColor: Colors.blueAccent,
          colorScheme: ColorScheme.fromSwatch(
            accentColor: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
