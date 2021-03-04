class Complex {
  final double real;
  final double imaginary;

  const Complex({
    required this.real,
    required this.imaginary,
  });
}

extension ComplexEx on Complex {
  double modulusSqr() => real * real + imaginary * imaginary;

  Complex sqr() => Complex(
        real: real * real - imaginary * imaginary,
        imaginary: 2 * real * imaginary,
      );

  Complex add(Complex other) => Complex(
        real: real + other.real,
        imaginary: imaginary + other.imaginary,
      );

  Complex operator +(Complex complex) => add(complex);
}
