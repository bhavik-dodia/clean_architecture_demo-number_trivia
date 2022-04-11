import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String kServerFailureMessage = 'Server Failure';
const String kCacheFailureMessage = 'Cache Failure';
const String kInvalidInputFailureMessage =
    'Invalid Input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required GetConcreteNumberTrivia concrete,
    required GetRandomNumberTrivia random,
    required this.inputConverter,
  })  : getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(NumberTriviaEmpty()) {
    on<GetTriviaForConcreteNumber>((event, emit) async {
      inputConverter.stringToUnsignedInteger(event.numberString).fold(
        (failure) async =>
            emit(const NumberTriviaError(message: kServerFailureMessage)),
        (integer) async {
          emit(NumberTriviaLoading());
          final failureOrTrivia = await getConcreteNumberTrivia(
            Params(number: integer),
          );
          await _eitherLoadedOrErrorState(failureOrTrivia, emit);
        },
      );
    });

    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(NumberTriviaLoading());
      final failureOrTrivia = await getRandomNumberTrivia(const NoParams());
      await _eitherLoadedOrErrorState(failureOrTrivia, emit);
    });
  }

  Future<void> _eitherLoadedOrErrorState(
    Either<Failure, NumberTrivia> failureOrTrivia,
    Emitter<NumberTriviaState> emit,
  ) async {
    failureOrTrivia.fold(
      (failure) async => emit(
        NumberTriviaError(
          message: _mapFailureToMessage(failure),
        ),
      ),
      (trivia) async => emit(NumberTriviaLoaded(trivia: trivia)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return kServerFailureMessage;
      case CacheFailure:
        return kCacheFailureMessage;
      default:
        return kInvalidInputFailureMessage;
    }
  }
}
