import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/number_trivia_bloc.dart';
import '../widgets/message_display.dart';

class NumberTriviaPage extends StatelessWidget {
  NumberTriviaPage({Key? key}) : super(key: key);
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Trivia')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: constraints.maxHeight * 0.4,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 10.0,
                  ),
                  child: BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                    builder: (context, state) {
                      if (state is NumberTriviaEmpty) {
                        return const MessageDisplay(
                          message: 'Start searching',
                        );
                      } else if (state is NumberTriviaError) {
                        return MessageDisplay(message: state.message);
                      } else if (state is NumberTriviaLoading) {
                        return const CircularProgressIndicator();
                      } else if (state is NumberTriviaLoaded) {
                        return Text.rich(
                          TextSpan(
                            text: '${state.trivia.number}\n',
                            style: const TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: state.trivia.text,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                      return Container(
                        height: constraints.maxHeight * 0.4,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 10.0,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _getTrivia(context),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Input a number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
                      onPressed: () => _getTrivia(context),
                      color: Colors.blueAccent,
                      child: const Text(
                        'Search',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        context.read<NumberTriviaBloc>().add(
                              GetTriviaForRandomNumber(),
                            );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueAccent),
                      ),
                      child: const Text(
                        'Get andom trivia',
                      ),
                    )
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  void _getTrivia(BuildContext context) {
    context.read<NumberTriviaBloc>().add(
          GetTriviaForConcreteNumber(
            numberString: controller.text,
          ),
        );
    controller.clear();
  }
}
