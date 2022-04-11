import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/utils/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([
  GetConcreteNumberTrivia,
  GetRandomNumberTrivia,
  InputConverter,
])
void main() {
  late NumberTriviaBloc myBloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    myBloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initialState should be empty', () {
    expect(myBloc.state, equals(NumberTriviaEmpty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '123';
    const tNumberParsed = 123;
    const tNumberTrivia = NumberTrivia(text: 'Test trivia', number: 123);

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(const Right(tNumberParsed));
    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should call the inputConverter to validate and convert the string to an unsigned integer',
      build: () => myBloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
      },
      act: (bloc) async {
        bloc.add(
          const GetTriviaForConcreteNumber(numberString: tNumberString),
        );
      },
      verify: (_) {
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [NumberTriviaError] when the input is invalid',
      build: () => myBloc,
      setUp: () {
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));
      },
      act: (bloc) async {
        bloc.add(
          const GetTriviaForConcreteNumber(numberString: tNumberString),
        );
      },
      expect: () => [isA<NumberTriviaError>()],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should get data from the concrete usecase',
      build: () => myBloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
      },
      act: (bloc) async {
        bloc.add(
          const GetTriviaForConcreteNumber(numberString: tNumberString),
        );
      },
      verify: (_) {
        verify(
          mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)),
        );
      },
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [NumberTriviaLoading, NumberTriviaLoaded] when data is gotten successfully',
      build: () => myBloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
      },
      act: (bloc) async {
        bloc.add(
          const GetTriviaForConcreteNumber(numberString: tNumberString),
        );
      },
      expect: () => [
        isA<NumberTriviaLoading>(),
        isA<NumberTriviaLoaded>(),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [NumberTriviaLoading, NumberTriviaError] when getting data fails',
      build: () => myBloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
      },
      act: (bloc) async {
        bloc.add(
          const GetTriviaForConcreteNumber(numberString: tNumberString),
        );
      },
      expect: () => [
        isA<NumberTriviaLoading>(),
        isA<NumberTriviaError>()
            .having((e) => e.message, 'message', kServerFailureMessage),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [NumberTriviaLoading, NumberTriviaError] with a proper message for the error when getting data fails',
      build: () => myBloc,
      setUp: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
      },
      act: (bloc) async {
        bloc.add(
          const GetTriviaForConcreteNumber(numberString: tNumberString),
        );
      },
      expect: () => [
        isA<NumberTriviaLoading>(),
        isA<NumberTriviaError>()
            .having((e) => e.message, 'message', kCacheFailureMessage),
      ],
    );
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(text: 'Test trivia', number: 123);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should get data from the concrete usecase',
      build: () => myBloc,
      setUp: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
      },
      act: (bloc) async {
        bloc.add(GetTriviaForRandomNumber());
      },
      verify: (_) {
        verify(
          mockGetRandomNumberTrivia(const NoParams()),
        );
      },
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [NumberTriviaLoading, NumberTriviaLoaded] when data is gotten successfully',
      build: () => myBloc,
      setUp: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
      },
      act: (bloc) async {
        bloc.add(GetTriviaForRandomNumber());
      },
      expect: () => [
        isA<NumberTriviaLoading>(),
        isA<NumberTriviaLoaded>(),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [NumberTriviaLoading, NumberTriviaError] when getting data fails',
      build: () => myBloc,
      setUp: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
      },
      act: (bloc) async {
        bloc.add(GetTriviaForRandomNumber());
      },
      expect: () => [
        isA<NumberTriviaLoading>(),
        isA<NumberTriviaError>()
            .having((e) => e.message, 'message', kServerFailureMessage),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [NumberTriviaLoading, NumberTriviaError] with a proper message for the error when getting data fails',
      build: () => myBloc,
      setUp: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
      },
      act: (bloc) async {
        bloc.add(GetTriviaForRandomNumber());
      },
      expect: () => [
        isA<NumberTriviaLoading>(),
        isA<NumberTriviaError>()
            .having((e) => e.message, 'message', kCacheFailureMessage),
      ],
    );
  });
}
