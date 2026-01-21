/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 21/01/2026
 * Copyright :  S.Hamblett
 */

import 'package:cbor/src/utils/float_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Float16 (half-precision) encoding - toFloat16Bytes', () {
    group('Special values', () {
      test('NaN encodes to canonical NaN (0x7e00)', () {
        expect(toFloat16Bytes(double.nan), [0x7e, 0x00]);
      });

      test('+Infinity encodes to 0x7c00', () {
        expect(toFloat16Bytes(double.infinity), [0x7c, 0x00]);
      });

      test('-Infinity encodes to 0xfc00', () {
        expect(toFloat16Bytes(double.negativeInfinity), [0xfc, 0x00]);
      });

      test('+0.0 encodes to 0x0000', () {
        expect(toFloat16Bytes(0.0), [0x00, 0x00]);
      });

      test('-0.0 encodes to 0x8000', () {
        expect(toFloat16Bytes(-0.0), [0x80, 0x00]);
      });
    });

    group('Normal positive values', () {
      test('1.0 encodes to 0x3c00', () {
        expect(toFloat16Bytes(1.0), [0x3c, 0x00]);
      });

      test('1.5 encodes to 0x3e00', () {
        expect(toFloat16Bytes(1.5), [0x3e, 0x00]);
      });

      test('2.0 encodes to 0x4000', () {
        expect(toFloat16Bytes(2.0), [0x40, 0x00]);
      });

      test('0.5 encodes to 0x3800', () {
        expect(toFloat16Bytes(0.5), [0x38, 0x00]);
      });

      test('65504.0 (max normal) encodes to 0x7bff', () {
        expect(toFloat16Bytes(65504.0), [0x7b, 0xff]);
      });

      test('0.00006103515625 (min positive normal) encodes to 0x0400', () {
        expect(toFloat16Bytes(0.00006103515625), [0x04, 0x00]);
      });
    });

    group('Normal negative values', () {
      test('-1.0 encodes to 0xbc00', () {
        expect(toFloat16Bytes(-1.0), [0xbc, 0x00]);
      });

      test('-1.5 encodes to 0xbe00', () {
        expect(toFloat16Bytes(-1.5), [0xbe, 0x00]);
      });

      test('-2.0 encodes to 0xc000', () {
        expect(toFloat16Bytes(-2.0), [0xc0, 0x00]);
      });

      test('-4.0 encodes to 0xc400', () {
        expect(toFloat16Bytes(-4.0), [0xc4, 0x00]);
      });

      test('-65504.0 (min normal) encodes to 0xfbff', () {
        expect(toFloat16Bytes(-65504.0), [0xfb, 0xff]);
      });
    });

    group('Subnormal values', () {
      test('5.960464477539063e-8 (smallest subnormal) encodes to 0x0001', () {
        expect(toFloat16Bytes(5.960464477539063e-8), [0x00, 0x01]);
      });

      test('6.097555160522461e-5 (largest subnormal) encodes to 0x03ff', () {
        expect(toFloat16Bytes(6.097555160522461e-5), [0x03, 0xff]);
      });
    });

    group('Overflow to infinity', () {
      test('65536.0 overflows to +Infinity', () {
        expect(toFloat16Bytes(65536.0), [0x7c, 0x00]);
      });

      test('100000.0 overflows to +Infinity', () {
        expect(toFloat16Bytes(100000.0), [0x7c, 0x00]);
      });

      test('-100000.0 overflows to -Infinity', () {
        expect(toFloat16Bytes(-100000.0), [0xfc, 0x00]);
      });
    });

    group('Underflow to zero', () {
      test('Very small positive value underflows to +0', () {
        expect(toFloat16Bytes(1e-10), [0x00, 0x00]);
      });

      test('Very small negative value underflows to -0', () {
        expect(toFloat16Bytes(-1e-10), [0x80, 0x00]);
      });
    });

    group('RFC 8949 Appendix A test vectors', () {
      // These are the exact values from RFC 8949
      test('0.0', () => expect(toFloat16Bytes(0.0), [0x00, 0x00]));
      test('-0.0', () => expect(toFloat16Bytes(-0.0), [0x80, 0x00]));
      test('1.0', () => expect(toFloat16Bytes(1.0), [0x3c, 0x00]));
      test('1.5', () => expect(toFloat16Bytes(1.5), [0x3e, 0x00]));
      test('65504.0', () => expect(toFloat16Bytes(65504.0), [0x7b, 0xff]));
      test('5.960464477539063e-8', () {
        expect(toFloat16Bytes(5.960464477539063e-8), [0x00, 0x01]);
      });
      test('0.00006103515625', () {
        expect(toFloat16Bytes(0.00006103515625), [0x04, 0x00]);
      });
      test('-4.0', () => expect(toFloat16Bytes(-4.0), [0xc4, 0x00]));
    });
  });

  group('Float16 (half-precision) decoding - fromFloat16Bytes', () {
    group('Special values', () {
      test('0x7e00 decodes to NaN', () {
        expect(fromFloat16Bytes([0x7e, 0x00]).isNaN, true);
      });

      test('0x7c01 (NaN with payload) decodes to NaN', () {
        expect(fromFloat16Bytes([0x7c, 0x01]).isNaN, true);
      });

      test('0x7c00 decodes to +Infinity', () {
        expect(fromFloat16Bytes([0x7c, 0x00]), double.infinity);
      });

      test('0xfc00 decodes to -Infinity', () {
        expect(fromFloat16Bytes([0xfc, 0x00]), double.negativeInfinity);
      });

      test('0x0000 decodes to +0.0', () {
        final result = fromFloat16Bytes([0x00, 0x00]);
        expect(result, 0.0);
        expect(result.isNegative, false);
      });

      test('0x8000 decodes to -0.0', () {
        final result = fromFloat16Bytes([0x80, 0x00]);
        expect(result, 0.0);
        expect(result.isNegative, true);
      });
    });

    group('Normal positive values', () {
      test('0x3c00 decodes to 1.0', () {
        expect(fromFloat16Bytes([0x3c, 0x00]), 1.0);
      });

      test('0x3e00 decodes to 1.5', () {
        expect(fromFloat16Bytes([0x3e, 0x00]), 1.5);
      });

      test('0x4000 decodes to 2.0', () {
        expect(fromFloat16Bytes([0x40, 0x00]), 2.0);
      });

      test('0x3800 decodes to 0.5', () {
        expect(fromFloat16Bytes([0x38, 0x00]), 0.5);
      });

      test('0x7bff decodes to 65504.0', () {
        expect(fromFloat16Bytes([0x7b, 0xff]), 65504.0);
      });

      test('0x0400 decodes to 0.00006103515625', () {
        expect(fromFloat16Bytes([0x04, 0x00]), 0.00006103515625);
      });
    });

    group('Normal negative values', () {
      test('0xbc00 decodes to -1.0', () {
        expect(fromFloat16Bytes([0xbc, 0x00]), -1.0);
      });

      test('0xbe00 decodes to -1.5', () {
        expect(fromFloat16Bytes([0xbe, 0x00]), -1.5);
      });

      test('0xc000 decodes to -2.0', () {
        expect(fromFloat16Bytes([0xc0, 0x00]), -2.0);
      });

      test('0xc400 decodes to -4.0', () {
        expect(fromFloat16Bytes([0xc4, 0x00]), -4.0);
      });

      test('0xfbff decodes to -65504.0', () {
        expect(fromFloat16Bytes([0xfb, 0xff]), -65504.0);
      });
    });

    group('Subnormal values', () {
      test('0x0001 decodes to smallest subnormal', () {
        expect(fromFloat16Bytes([0x00, 0x01]), 5.960464477539063e-8);
      });

      test('0x03ff decodes to largest subnormal', () {
        expect(fromFloat16Bytes([0x03, 0xff]), 6.097555160522461e-5);
      });
    });
  });

  group('Float16 round-trip tests', () {
    test('All representable values round-trip correctly', () {
      final testValues = [
        0.0,
        -0.0,
        1.0,
        -1.0,
        1.5,
        -1.5,
        2.0,
        -2.0,
        0.5,
        -0.5,
        0.25,
        -0.25,
        65504.0,
        -65504.0,
        0.00006103515625,
        -0.00006103515625,
        5.960464477539063e-8,
        double.infinity,
        double.negativeInfinity,
      ];

      for (final value in testValues) {
        final bytes = toFloat16Bytes(value);
        final decoded = fromFloat16Bytes(bytes);
        if (value.isNaN) {
          expect(decoded.isNaN, true, reason: 'NaN should round-trip');
        } else {
          expect(decoded, value, reason: '$value should round-trip');
        }
      }
    });

    test('NaN round-trips', () {
      final bytes = toFloat16Bytes(double.nan);
      expect(fromFloat16Bytes(bytes).isNaN, true);
    });
  });

  group('isFloat16Lossless', () {
    group('Values that can be represented', () {
      test('Special values', () {
        expect(isFloat16Lossless(0.0), true);
        expect(isFloat16Lossless(-0.0), true);
        expect(isFloat16Lossless(double.nan), true);
        expect(isFloat16Lossless(double.infinity), true);
        expect(isFloat16Lossless(double.negativeInfinity), true);
      });

      test('Exact representable values', () {
        expect(isFloat16Lossless(1.0), true);
        expect(isFloat16Lossless(-1.0), true);
        expect(isFloat16Lossless(1.5), true);
        expect(isFloat16Lossless(2.0), true);
        expect(isFloat16Lossless(65504.0), true);
        expect(isFloat16Lossless(0.00006103515625), true);
        expect(isFloat16Lossless(5.960464477539063e-8), true);
      });
    });

    group('Values that cannot be represented', () {
      test('Values too large', () {
        expect(isFloat16Lossless(100000.0), false);
        expect(isFloat16Lossless(65536.0), false);
      });

      test('Values with too much precision', () {
        expect(isFloat16Lossless(1.1), false);
        expect(isFloat16Lossless(3.14159), false);
        expect(isFloat16Lossless(1.0001), false);
      });

      test('Values too small (non-zero)', () {
        expect(isFloat16Lossless(1e-10), false);
      });
    });
  });

  group('Float32 (single-precision) encoding - toFloat32Bytes', () {
    group('Special values', () {
      test('NaN encodes correctly', () {
        final bytes = toFloat32Bytes(double.nan);
        expect(bytes.length, 4);
        // NaN has exponent all 1s and non-zero mantissa
        expect(bytes[0] & 0x7F, 0x7F); // High bit of exponent
        expect(bytes[1] & 0x80, 0x80); // Low bit of exponent
      });

      test('+Infinity encodes to 0x7f800000', () {
        expect(toFloat32Bytes(double.infinity), [0x7f, 0x80, 0x00, 0x00]);
      });

      test('-Infinity encodes to 0xff800000', () {
        expect(toFloat32Bytes(double.negativeInfinity), [
          0xff,
          0x80,
          0x00,
          0x00,
        ]);
      });

      test('+0.0 encodes to 0x00000000', () {
        expect(toFloat32Bytes(0.0), [0x00, 0x00, 0x00, 0x00]);
      });

      test('-0.0 encodes to 0x80000000', () {
        expect(toFloat32Bytes(-0.0), [0x80, 0x00, 0x00, 0x00]);
      });
    });

    group('Normal values', () {
      test('1.0 encodes to 0x3f800000', () {
        expect(toFloat32Bytes(1.0), [0x3f, 0x80, 0x00, 0x00]);
      });

      test('-1.0 encodes to 0xbf800000', () {
        expect(toFloat32Bytes(-1.0), [0xbf, 0x80, 0x00, 0x00]);
      });

      test('2.0 encodes to 0x40000000', () {
        expect(toFloat32Bytes(2.0), [0x40, 0x00, 0x00, 0x00]);
      });

      test('0.5 encodes to 0x3f000000', () {
        expect(toFloat32Bytes(0.5), [0x3f, 0x00, 0x00, 0x00]);
      });

      test('100000.0 encodes to 0x47c35000', () {
        expect(toFloat32Bytes(100000.0), [0x47, 0xc3, 0x50, 0x00]);
      });

      test('3.4028234663852886e+38 (max float32)', () {
        expect(toFloat32Bytes(3.4028234663852886e+38), [
          0x7f,
          0x7f,
          0xff,
          0xff,
        ]);
      });
    });
  });

  group('Float32 (single-precision) decoding - fromFloat32Bytes', () {
    group('Special values', () {
      test('0x7fc00000 decodes to NaN', () {
        expect(fromFloat32Bytes([0x7f, 0xc0, 0x00, 0x00]).isNaN, true);
      });

      test('0x7f800000 decodes to +Infinity', () {
        expect(fromFloat32Bytes([0x7f, 0x80, 0x00, 0x00]), double.infinity);
      });

      test('0xff800000 decodes to -Infinity', () {
        expect(
          fromFloat32Bytes([0xff, 0x80, 0x00, 0x00]),
          double.negativeInfinity,
        );
      });

      test('0x00000000 decodes to +0.0', () {
        expect(fromFloat32Bytes([0x00, 0x00, 0x00, 0x00]), 0.0);
      });

      test('0x80000000 decodes to -0.0', () {
        final result = fromFloat32Bytes([0x80, 0x00, 0x00, 0x00]);
        expect(result, 0.0);
        expect(result.isNegative, true);
      });
    });

    group('Normal values', () {
      test('0x3f800000 decodes to 1.0', () {
        expect(fromFloat32Bytes([0x3f, 0x80, 0x00, 0x00]), 1.0);
      });

      test('0xbf800000 decodes to -1.0', () {
        expect(fromFloat32Bytes([0xbf, 0x80, 0x00, 0x00]), -1.0);
      });

      test('0x47c35000 decodes to 100000.0', () {
        expect(fromFloat32Bytes([0x47, 0xc3, 0x50, 0x00]), 100000.0);
      });

      test('0x7f7fffff decodes to max float32', () {
        expect(
          fromFloat32Bytes([0x7f, 0x7f, 0xff, 0xff]),
          closeTo(3.4028234663852886e+38, 1e31),
        );
      });
    });
  });

  group('Float32 round-trip tests', () {
    test('Values round-trip correctly', () {
      final testValues = [
        0.0,
        -0.0,
        1.0,
        -1.0,
        2.0,
        0.5,
        100000.0,
        -100000.0,
        3.14159,
        -3.14159,
        1e10,
        1e-10,
        double.infinity,
        double.negativeInfinity,
      ];

      for (final value in testValues) {
        final bytes = toFloat32Bytes(value);
        final decoded = fromFloat32Bytes(bytes);
        if (value.isNaN) {
          expect(decoded.isNaN, true, reason: 'NaN should round-trip');
        } else if (value.isInfinite) {
          expect(decoded, value, reason: '$value should round-trip');
        } else {
          // Float32 has limited precision, so use closeTo for normal values
          expect(
            decoded,
            closeTo(value, value.abs() * 1e-6 + 1e-10),
            reason: '$value should round-trip',
          );
        }
      }
    });
  });

  group('isFloat32Lossless', () {
    test('Special values', () {
      expect(isFloat32Lossless(0.0), true);
      expect(isFloat32Lossless(-0.0), true);
      expect(isFloat32Lossless(double.nan), true);
      expect(isFloat32Lossless(double.infinity), true);
      expect(isFloat32Lossless(double.negativeInfinity), true);
    });

    test('Values that fit in float32', () {
      expect(isFloat32Lossless(1.0), true);
      expect(isFloat32Lossless(-1.0), true);
      expect(isFloat32Lossless(100000.0), true);
      expect(isFloat32Lossless(3.4028234663852886e+38), true);
    });

    test('Values that do not fit in float32', () {
      // Very large values
      expect(isFloat32Lossless(1e300), false);
      // Values with too much precision
      expect(isFloat32Lossless(1.0000000001), false);
    });
  });

  group('Float64 (double-precision) encoding - toFloat64Bytes', () {
    group('Special values', () {
      test('NaN encodes correctly', () {
        final bytes = toFloat64Bytes(double.nan);
        expect(bytes.length, 8);
      });

      test('+Infinity encodes to 0x7ff0000000000000', () {
        expect(toFloat64Bytes(double.infinity), [
          0x7f,
          0xf0,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
        ]);
      });

      test('-Infinity encodes to 0xfff0000000000000', () {
        expect(toFloat64Bytes(double.negativeInfinity), [
          0xff,
          0xf0,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
        ]);
      });

      test('+0.0 encodes to all zeros', () {
        expect(toFloat64Bytes(0.0), [
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
        ]);
      });

      test('-0.0 encodes to 0x8000000000000000', () {
        expect(toFloat64Bytes(-0.0), [
          0x80,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
        ]);
      });
    });

    group('Normal values', () {
      test('1.0 encodes to 0x3ff0000000000000', () {
        expect(toFloat64Bytes(1.0), [
          0x3f,
          0xf0,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
        ]);
      });

      test('-1.0 encodes to 0xbff0000000000000', () {
        expect(toFloat64Bytes(-1.0), [
          0xbf,
          0xf0,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
        ]);
      });

      test('1e300 encodes correctly', () {
        expect(toFloat64Bytes(1e300), [
          0x7e,
          0x37,
          0xe4,
          0x3c,
          0x88,
          0x00,
          0x75,
          0x9c,
        ]);
      });
    });
  });

  group('Float64 (double-precision) decoding - fromFloat64Bytes', () {
    group('Special values', () {
      test('NaN decodes correctly', () {
        expect(
          fromFloat64Bytes([
            0x7f,
            0xf8,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
          ]).isNaN,
          true,
        );
      });

      test('+Infinity decodes correctly', () {
        expect(
          fromFloat64Bytes([0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
          double.infinity,
        );
      });

      test('-Infinity decodes correctly', () {
        expect(
          fromFloat64Bytes([0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
          double.negativeInfinity,
        );
      });

      test('+0.0 decodes correctly', () {
        expect(
          fromFloat64Bytes([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
          0.0,
        );
      });

      test('-0.0 decodes correctly', () {
        final result = fromFloat64Bytes([
          0x80,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
        ]);
        expect(result, 0.0);
        expect(result.isNegative, true);
      });
    });

    group('Normal values', () {
      test('1.0 decodes correctly', () {
        expect(
          fromFloat64Bytes([0x3f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
          1.0,
        );
      });

      test('-1.0 decodes correctly', () {
        expect(
          fromFloat64Bytes([0xbf, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
          -1.0,
        );
      });

      test('1e300 decodes correctly', () {
        expect(
          fromFloat64Bytes([0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c]),
          1e300,
        );
      });
    });
  });

  group('Float64 round-trip tests', () {
    test('All values round-trip exactly', () {
      final testValues = [
        0.0,
        -0.0,
        1.0,
        -1.0,
        2.0,
        0.5,
        1.1,
        3.14159265358979323846,
        1e300,
        1e-300,
        double.infinity,
        double.negativeInfinity,
        // Edge cases
        double.minPositive,
        double.maxFinite,
        -double.maxFinite,
      ];

      for (final value in testValues) {
        final bytes = toFloat64Bytes(value);
        final decoded = fromFloat64Bytes(bytes);
        if (value.isNaN) {
          expect(decoded.isNaN, true, reason: 'NaN should round-trip');
        } else {
          expect(decoded, value, reason: '$value should round-trip exactly');
        }
      }
    });
  });

  group('isFloat64Lossless', () {
    test('Always returns true', () {
      expect(isFloat64Lossless(0.0), true);
      expect(isFloat64Lossless(-0.0), true);
      expect(isFloat64Lossless(1.0), true);
      expect(isFloat64Lossless(double.nan), true);
      expect(isFloat64Lossless(double.infinity), true);
      expect(isFloat64Lossless(double.negativeInfinity), true);
      expect(isFloat64Lossless(1e300), true);
      expect(isFloat64Lossless(double.minPositive), true);
      expect(isFloat64Lossless(double.maxFinite), true);
    });
  });

  group('Cross-platform consistency (JS-specific bugs)', () {
    // These tests verify fixes for issues with the ieee754 package on JS
    test('Negative values encode correctly (sign bit handling)', () {
      // -4.0 was incorrectly encoded on JS due to setInt16 sign extension
      expect(toFloat16Bytes(-4.0), [0xc4, 0x00]);
      expect(fromFloat16Bytes([0xc4, 0x00]), -4.0);
    });

    test('Negative zero encodes correctly', () {
      // Negative zero was problematic on some platforms
      final bytes = toFloat16Bytes(-0.0);
      expect(bytes, [0x80, 0x00]);
      final decoded = fromFloat16Bytes(bytes);
      expect(decoded, 0.0);
      expect(decoded.isNegative, true);
    });

    test('Large positive values with high bit set decode correctly', () {
      // Values like 65504 have high bit set in some representations
      expect(fromFloat16Bytes([0x7b, 0xff]), 65504.0);
    });

    test('Large negative values decode correctly', () {
      // -65504 was incorrectly decoded on JS
      expect(fromFloat16Bytes([0xfb, 0xff]), -65504.0);
    });
  });

  group('Edge cases', () {
    test('Byte arrays are the correct length', () {
      expect(toFloat16Bytes(1.0).length, 2);
      expect(toFloat32Bytes(1.0).length, 4);
      expect(toFloat64Bytes(1.0).length, 8);
    });

    test('Bytes are in big-endian order', () {
      // Float16: 1.0 = 0x3c00, so first byte should be 0x3c
      expect(toFloat16Bytes(1.0)[0], 0x3c);
      expect(toFloat16Bytes(1.0)[1], 0x00);

      // Float32: 1.0 = 0x3f800000, so first byte should be 0x3f
      expect(toFloat32Bytes(1.0)[0], 0x3f);
      expect(toFloat32Bytes(1.0)[3], 0x00);

      // Float64: 1.0 = 0x3ff0000000000000, so first byte should be 0x3f
      expect(toFloat64Bytes(1.0)[0], 0x3f);
      expect(toFloat64Bytes(1.0)[7], 0x00);
    });
  });
}
